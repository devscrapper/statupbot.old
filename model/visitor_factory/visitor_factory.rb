require 'trollop'
require 'eventmachine'
require 'yaml'
require 'em/threaded_resource'
require_relative '../../lib/flow'
require_relative '../../lib/logging'
require_relative '../../lib/error'
require_relative '../../lib/monitoring'
require_relative '../geolocation/geolocation_factory'

class VisitorFactory
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include EM::Deferrable
  include Errors
  include Geolocations
  #----------------------------------------------------------------------------------------------------------------
  # Exception message
  #----------------------------------------------------------------------------------------------------------------

  ARGUMENT_UNDEFINE = 1000
  RUNTIME_BROWSER_PATH_NOT_FOUND = 1001
  #----------------------------------------------------------------------------------------------------------------
  # constant
  #----------------------------------------------------------------------------------------------------------------
  VISITOR_BOT = Pathname(File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")).realpath
  TMP = Pathname(File.join(File.dirname(__FILE__), "..", "..", "tmp")).realpath

  OK = 0
  KO = 1
  NO_AD = 2
  NO_LANDING = 3
  OVER_TTL = 4
  NO_CLOSE = 5
  NO_DIE = 6

  #----------------------------------------------------------------------------------------------------------------
  # attribut
  #----------------------------------------------------------------------------------------------------------------
  attr :pattern,
       :use_proxy_system,
       :port_proxy_sahi,
       :runtime_ruby,
       :delay_out_of_time,
       :geolocation_factory,
       :browser_not_properly_close,
       :max_count_current_visit,
       :logger

  #----------------------------------------------------------------------------------------------------------------
  # class methods
  #----------------------------------------------------------------------------------------------------------------
  @@mutex = Mutex.new
  @@count_current_visit = 0
  #----------------------------------------------------------------------------------------------------------------
  # instance methods
  #----------------------------------------------------------------------------------------------------------------

  #-----------------------------------------------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------------------------------------------
  # input : hash decrivant les propriétés du browser de la visit
  # :name : Internet Explorer
  # :version : '9.0'
  # :operating_system : Windows
  # :operating_system_version : '7'
  # :flash_version : 11.7 r700   -- not use
  # :java_enabled : 'Yes'        -- not use
  # :screens_colors : 32-bit     -- not use
  # :screen_resolution : 1600 x900
  # output : un objet Browser
  # exception :
  # StandardError :
  # si le listening_port_proxy n'est pas defini
  # si la resoltion d'ecran du browser n'est pas definie
  #-----------------------------------------------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------------------------------------------
  def initialize(browser, version, use_proxy_system, port_proxy_sahi, runtime_ruby, delay_periodic_scan, delay_out_of_time, max_count_current_visit, geolocation_factory, logger)
    @use_proxy_system = use_proxy_system
    @port_proxy_sahi = port_proxy_sahi
    @runtime_ruby = runtime_ruby
    @pattern = "#{browser} #{version}" # ne pas supprimer le blanc
    @pool = EM::Pool.new
    @delay_periodic_scan = delay_periodic_scan
    @delay_out_of_time = delay_out_of_time
    @logger = logger
    @geolocation_factory = geolocation_factory
    @max_count_current_visit = max_count_current_visit
    @@count_current_visit = @max_count_current_visit
    @browser_not_properly_close = false
    @port_proxy_sahi.each { |port|
      visitor_instance = EM::ThreadedResource.new do
        {:pattern => @pattern, :port_proxy_sahi => port}
      end
      @pool.add visitor_instance
    }
    @logger.an_event.info "Visitor Factory #{@pattern} is on"
  end

  #-----------------------------------------------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------------------------------------------
  # input : hash decrivant les propriétés du browser de la visit
  # :name : Internet Explorer
  # :version : '9.0'
  # :operating_system : Windows
  # :operating_system_version : '7'
  # :flash_version : 11.7 r700   -- not use
  # :java_enabled : 'Yes'        -- not use
  # :screens_colors : 32-bit     -- not use
  # :screen_resolution : 1600 x900
  # output : un objet Browser
  # exception :
  # StandardError :
  # si le listening_port_proxy n'est pas defini
  # si la resoltion d'ecran du browser n'est pas definie
  #-----------------------------------------------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------------------------------------------
  def scan_visit_file
    begin
      EM::PeriodicTimer.new(@delay_periodic_scan) do
        tmp_flow_visit = Flow.first(TMP, {:type_flow => @pattern, :ext => "yml"}, @logger)

        if !tmp_flow_visit.nil?
          @logger.an_event.info "visit flow #{tmp_flow_visit.basename} selected"
          # si la date de planificiation de la visite portée par le nom du fichier est dépassée de 15mn alors la visit est out of time et ne sera jamais executé
          # ceci afin de ne pas dénaturer la planification calculer par enginebot.
          # pour pallier à cet engorgement, il faut augmenter le nombre d'instance concurrente de navigateur dans le fichier browser_type.csv
          # un jour peut être ce fonctionnement sera revu pour adapter automatiquement le nombre d'instance concurrente d'un nivagteur (cela nécessite de prévoir un pool de numero de port pour sahi proxy)
          # ajout 18/05/2016 : si delay_out_of_time == 0 alors les visits ne sont jamais hors delais comme developpement
          # qq soient la policy (seaattack, traffic, rank).
          # Demain cela pourrait être conditionné en fonction du type de visit qui nécessite absoluement de suivre
          # la planifiication comme Traffic pour ne pas dénaturé les statisitique GA du website
          start_time_visit = tmp_flow_visit.date.split(/-/)

          if $staging == "development" or  # en developpement => pas de visit hors delais
              @delay_out_of_time == 0 or # si delay_out_of_time == 0 => pas de visit hors délais
              ($staging != "development" and Time.now - Time.local(start_time_visit[0],
                                                                                               start_time_visit[1],
                                                                                               start_time_visit[2],
                                                                                               start_time_visit[3],
                                                                                               start_time_visit[4],
                                                                                               start_time_visit[5]) <= @delay_out_of_time * 60) # huere de déclenchement de la visit doit être dans le délaus imparti par @delay_out_of_time

            @pool.perform do |dispatcher|
              dispatcher.dispatch do |details|
                if @@count_current_visit > 0
                  tmp_flow_visit.archive
                  @logger.an_event.info "visit flow #{tmp_flow_visit.basename} archived"

                  details[:visit_file] = tmp_flow_visit.absolute_path
                  start_visitor_bot(details)


                else
                  @@logger.an_event.info "visit flow #{tmp_flow_visit.basename} not start, only #{@@count_current_visit} visit concurrent executions"

                end
              end
            end

          else
            # la date de planification de la visit est dépassée
            tmp_flow_visit.archive
            @logger.an_event.info "visit flow #{tmp_flow_visit.basename} archived"

            visit = YAML::load(tmp_flow_visit.read)[:visit]
            tmp_flow_visit.close
            #envoie de l'etat out fo time à statupweb
            begin
              Monitoring.change_state_visit(visit[:id], Monitoring::OUTOFTIME)

            rescue Exception => e
              @logger.an_event.warn e.message

            end
            @logger.an_event.warn "visit #{tmp_flow_visit.basename} for #{@pattern} is out of time."

          end
        end

      end
    rescue Exception => e
      @logger.an_event.error "scan visit file for #{@pattern} catch exception : #{e.message} => restarting"
      retry

    end
  end

  def pool_size
    @pool.num_waiting
  end

  #-----------------------------------------------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------------------------------------------
  # pour sandboxer l'execution d'un visitor_bot :
  # @runtime_start_sandbox = "C:\Program Files\Sandboxie\Start.exe"
  # @sand_box_id = n(3)
  # /nosbiectrl  ne lance pas le panneau de controle de sanbox
  # /silent  bloque l'affichage des messages
  # /elevate augmente les droits d'execution au niveau administrateur
  # /wait attend que le programme soit terminé
  # sandbox = "#{@runtime_start_sandbox} /box:#{@sand_box_id}  /nosbiectrl  /silent  /elevate /env:VariableName=VariableValueWithoutSpace /wait"
  # cmd = "#{sandbox} #{@runtime_ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{VISITOR_BOT} -v #{details[:visit_file]} -t #{details[:port_proxy_sahi]} -p #{@use_proxy_system} #{geolocation}"
  #-----------------------------------------------------------------------------------------------------------------
  def start_visitor_bot(details)
    begin
      @@mutex.synchronize { @@count_current_visit -= 1 }

      @logger.an_event.info "start visitor_bot with browser #{details[:pattern]} and visit file #{details[:visit_file]}"

      # si pas d'avert alors :  [:advert][:advertising] = "none"
      # sinon le nom de l'advertising, exemple adsense

      visit_details = YAML::load(File.open(details[:visit_file], "r:BOM|UTF-8:-").read)
      visit = visit_details[:visit]
      visitor = visit_details[:visitor]

      with_advertising = visit[:advert][:advertising] != :none
      with_google_engine = visitor[:browser][:engine_search] == :google && visit[:referrer][:medium] == :organic

      cmd = "#{@runtime_ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  \
      #{VISITOR_BOT} \
                              -v #{details[:visit_file]} \
                              -t #{details[:port_proxy_sahi]} \
                              -p #{@use_proxy_system} \
      #{geolocation(with_advertising, with_google_engine)}"


      @logger.an_event.debug "cmd start visitor_bot #{cmd}"

      visitor_bot_pid = 0
      visitor_bot_pid = Process.spawn(cmd)
      visitor_bot_pid, status = Process.wait2(visitor_bot_pid, 0)

    rescue Exception => e
      @logger.an_event.error "lauching visitor_bot with browser #{details[:pattern]} and visit file #{details[:visit_file]} : #{e.message}"
      change_visit_state(visit[:id], Monitoring::NEVERSTARTED)

    else
      @logger.an_event.info "visitor_bot with browser #{details[:pattern]} and visit file #{details[:visit_file]} over : exit status #{status.exitstatus}"

      if status.exitstatus == OK
        delete_log_file(visitor[:id])

      elsif status.exitstatus == NO_CLOSE
        @browser_not_properly_close = true
      end

    ensure
      @@mutex.synchronize {
        @@count_current_visit += 1

        # on tue tous les browser du pattern qui ne se sont pas fermés => nettoyage  qd aucune visit est en cours pour ce type de browser
        # @browser_not_properly_close est maj dans kill_all_browser_from_pattern
        kill_all_browser_from_pattern(visitor[:browser][:name]) if @browser_not_properly_close and @@count_current_visit == @max_count_current_visit
      }

    end
  end

  #-----------------------------------------------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------------------------------------------
  # input :
  # output : parametre de lacement de visitor_bot pour la geolocation
  # exception :   RAS
  #-----------------------------------------------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------------------------------------------
  def geolocation(with_advertising, with_google_engine)
    # si exception pour le get : NONE_GEOLOCATION => pas de geolocalisation
    # si exception pour le get_french : GEO_NONE_FRENCH => pas de geolocation francaise
    # sinon retour d'une geolocation qui est  :
    # soit issu d'une liste de proxy
    # soit le proxy par defaut de l'entreprise  passé en paramètre de visitorfactory_server : geolocation = "-r http -o muz11-wbsswsg.ca-technologies.fr -x 8080 -y ET00752 -w Bremb@15"
    # si la visit contient un advert alors on essaie de recuperer un geolocation francais.
    # si le moteur de recherche est google alors on essaie de recuperer une geolocation qui s'appuie sur https
    # sinon un geolocation.

    begin
              #TODO attention aton besoin de cette fonctionnalité sur la geolocation
      # geo = @geolocation_factory.get(:country => with_advertising ? "fr" : nil,
      #                                :protocol => with_google_engine ? "https" : nil) unless @geolocation_factory.nil?
       geo = @geolocation_factory.get(:country => nil,
                                        :protocol =>  nil) unless @geolocation_factory.nil?
    rescue Exception => e
      @logger.an_event.warn e.message
      geo_to_s = ""

    else

      geo_to_s = "-r #{geo.protocol} -o #{geo.ip} -x #{geo.port}"
      geo_to_s += " -y #{geo.user}" unless geo.user.nil?
      geo_to_s += " -w #{geo.password}" unless geo.password.nil?

    ensure
      @logger.an_event.info "geolocation is <#{geo_to_s}>"

      return geo_to_s

    end
  end

  private

  def change_visit_state(visit_id, state)
    begin
      Monitoring.change_state_visit(visit_id, state)

    rescue Exception => e
      @logger.an_event.warn ("change state #{state} of visit #{visit_id} : #{e.message}")

    else
      @logger.an_event.info("change state #{state} of visit #{visit_id}")
    end
  end

  def delete_log_file(visitor_id)
    begin
      dir = Pathname(File.join(File.dirname(__FILE__), "..", '..', "log")).realpath
      files = File.join(dir, "visitor_bot_#{visitor_id}.{*}")
      FileUtils.rm_r(Dir.glob(files))

    rescue Exception => e
      @logger.an_event.error "log file of visitor_bot #{visitor_id} not delete : #{e.message}"

    else
      @logger.an_event.info "log file of visitor_bot #{visitor_id} delete"

    end
  end

  def kill_all_browser_from_pattern(name_browser)
    count_try = 3
    case name_browser
      when "Internet Explorer"
        image_name = "iexplore.exe"
      when "Firefox"
        image_name = "firefox.exe"
      when "Chrome"
        image_name = "chrome.exe"
      when "Opera"
        image_name = "opera.exe"
    end

    begin

      #TODO remplacer taskkill par kill pour linux
      res = IO.popen("taskkill /IM #{image_name}").read

      @@logger.an_event.debug "taskkill for #{name_browser} : #{res}"

    rescue Exception => e
      count_try -= 1
      if count_try > 0
        @@logger.an_event.debug "try #{count_try},kill browser type #{name_browser} : #{e.message}"
        sleep (1)
        retry

      else
        @@logger.an_event.error "kill browser type #{name_browser}  : #{e.message}"
        # lors de la prochaine visit qui stoppera alors à nouveau on tentera sur tuer les browser de ce type là
        # donc @browser_not_properly_close reste à true
      end

    else
      @@logger.an_event.debug "kill browser type #{name_browser}"
      # tous les browser sont mort donc on reinitialise la variable
      @browser_not_properly_close = false

    end
  end

end



