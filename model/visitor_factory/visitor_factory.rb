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

  #----------------------------------------------------------------------------------------------------------------
  # attribut
  #----------------------------------------------------------------------------------------------------------------
  attr :pattern,
       :use_proxy_system,
       :port_proxy_sahi,
       :runtime_ruby,
       :delay_out_of_time,
       :geolocation_factory,
       :logger

  #----------------------------------------------------------------------------------------------------------------
  # class methods
  #----------------------------------------------------------------------------------------------------------------


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
  def initialize(browser, version, use_proxy_system, port_proxy_sahi, runtime_ruby, delay_periodic_scan, delay_out_of_time, geolocation_factory, logger)
    @use_proxy_system = use_proxy_system
    @port_proxy_sahi = port_proxy_sahi
    @runtime_ruby = runtime_ruby
    @pattern = "#{browser} #{version}" # ne pas supprimer le blanc
    @pool = EM::Pool.new
    @delay_periodic_scan = delay_periodic_scan
    @delay_out_of_time = delay_out_of_time
    @logger = logger
    @geolocation_factory = geolocation_factory

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
          # si la date de planificiation de la visite portée par le nom du fichier est dépassée de 15mn alors la visit est out of time et ne sera jamais executé
          # ceci afin de ne pas dénaturer la planification calculer par enginebot.
          # pour pallier à cet engorgement, il faut augmenter le nombre d'instance concurrente de navigateur dans le fichier browser_type.csv
          # un jour peut être ce fonctionnement sera revu pour adapter automatiquement le nombre d'instance concurrente d'un nivagteur (cela nécessite de prévoir un pool de numero de port pour sahi proxy)
          start_time_visit = tmp_flow_visit.date.split(/-/)

          if $staging == "development" or ($staging != "development" and Time.now - Time.local(start_time_visit[0],
                                                                                               start_time_visit[1],
                                                                                               start_time_visit[2],
                                                                                               start_time_visit[3],
                                                                                               start_time_visit[4],
                                                                                               start_time_visit[5]) <= @delay_out_of_time * 60)

            @pool.perform do |dispatcher|
              dispatcher.dispatch do |details|
                tmp_flow_visit.archive
                @logger.an_event.info "visit flow #{tmp_flow_visit.basename} archived"
                details[:visit_file] = tmp_flow_visit.absolute_path
                start_visitor_bot(details)
              end
            end
          else
            tmp_flow_visit.archive
            @logger.an_event.info "visit flow #{tmp_flow_visit.basename} archived"

            visit = YAML::load(tmp_flow_visit.read)[:visit]
            tmp_flow_visit.close
            begin
              Monitoring.change_state_visit(visit[:id], Monitoring::OUTOFTIME)
            rescue Exception => e
              @logger.an_event.warn e.message
            end
            Monitoring.send_visit_out_of_time(@pattern, logger)
            @logger.an_event.warn "visit #{tmp_flow_visit.basename} for #{@pattern} is out of time."

          end
        end
      end
      EM::PeriodicTimer.new(5 * 60) do
        @logger.an_event.info "size pool for #{@pattern} #{@pool.num_waiting} "
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

      begin
        Monitoring.change_state_visit(visit[:id], Monitoring::START)
      rescue Exception => e
        @logger.an_event.warn e.message
      end


      pid = Process.spawn(cmd)
      pid, status = Process.wait2(pid, 0)

    rescue Exception => e

      @logger.an_event.error "start visitor_bot with browser #{details[:pattern]} and visit file #{details[:visit_file]} failed : #{e.message}"

    else

      @logger.an_event.debug "browser #{details[:pattern]} and visit file #{details[:visit_file]} : exit status #{status.exitstatus}"

      if status.exitstatus == OK
        begin
          Monitoring.change_state_visit(visit[:id], Monitoring::SUCCESS)
        rescue Exception => e
          @logger.an_event.warn e.message
        end

        @logger.an_event.info "visitor_bot browser #{details[:pattern]} port #{details[:port_proxy_sahi]} send success to monitoring"
        begin

          visitor_id = visitor[:id]
          dir = Pathname(File.join(File.dirname(__FILE__), "..", '..', "log")).realpath
          files = File.join(dir, "visitor_bot_#{visitor_id}.{*}")
          FileUtils.rm_r(Dir.glob(files))

        rescue Exception => e
          @logger.an_event.error "log file of visitor_bot #{visitor_id} not delete : #{e.message}"

        else
          @logger.an_event.debug "log file of visitor_bot #{visitor_id} delete"

        end

      else
        begin
        Monitoring.change_state_visit(visit[:id], Monitoring::FAIL)
        rescue Exception => e
          @logger.an_event.warn e.message
        end
        @logger.an_event.info "visitor_bot browser #{details[:pattern]} port #{details[:port_proxy_sahi]} send an error to monitoring"

      end

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

      geo = @geolocation_factory.get(:country => with_advertising ? "fr" : nil,
                                     :protocol => with_google_engine ? "https" : nil) unless @geolocation_factory.nil?

    rescue Exception => e
      @logger.an_event.warn e.message
      geo_to_s = ""

    else

      geo_to_s = "-r #{geo.protocol} -o #{geo.ip} -x #{geo.port}"
      geo_to_s += " -y #{geo.user}" unless geo.user
      geo_to_s += " -w #{geo.password}" unless geo.password

    ensure
      @logger.an_event.info "geolocation is <#{geo_to_s}>"

      return geo_to_s

    end
  end
end



