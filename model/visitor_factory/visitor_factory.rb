require_relative '../../model/monitoring/public'
require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require 'pathname'

module VisitorFactory
  #--------------------------------------------------------------------------------------------------------------------
  # constant
  #--------------------------------------------------------------------------------------------------------------------
  VISITOR_BOT = Pathname(File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")).realpath
  #--------------------------------------------------------------------------------------------------------------------
  # return code Visitor_Bot
  #--------------------------------------------------------------------------------------------------------------------
  OK = 0

  #--------------------------------------------------------------------------------------------------------------------
  # Global variables
  #--------------------------------------------------------------------------------------------------------------------
  @@logger = nil

  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    # geolocalisation par defaut globale à toutes les visites, qui permet de tester derriere un proxy entreprise (:proxy_type == :http) ou à la maison (:proxy_type == :none)
    # Pour adapter la geolocalisation à chaque visit il faut
    # soit developper un module de geolocation utilisé par VisitorFactory,
    # soit apporté ces informations dans le fichier décrivant la visit
    attr :default_ip_geo,
         :default_port_geo,
         :default_user_geo,
         :default_pwd_geo,
         :default_type_geo,
         :browser_type_repository,
         :runtime_ruby


    def initialize(browser_type_repository, runtime_ruby, logger, geolocation)
      @@logger = logger
      @default_type_geo = geolocation[:proxy_type]
      @browser_type_repository = browser_type_repository
      @runtime_ruby = runtime_ruby
      if @default_type_geo != "none"
        @default_ip_geo = geolocation[:proxy_ip]
        @default_port_geo = geolocation[:proxy_port]
        @default_user_geo = geolocation[:proxy_user]
        @default_pwd_geo = geolocation[:proxy_pwd]
      end
    end


    def receive_object(filename_visit)
      @@logger.an_event.debug "BEGIN AssignNewVisitorConnection.receive_object"
      @@logger.an_event.debug "filename_visit #{filename_visit}"

      close_connection

      begin
        raise "visit file undefine" if filename_visit == ""

        filename_visit = Pathname(filename_visit).realpath
        @@logger.an_event.debug "filename #{filename_visit}"

        visit_file = File.open(filename_visit, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)

        @@logger.an_event.debug "visit file #{filename_visit} load"

        id_visitor ||= visit_details[:visitor][:id]
        id_visit ||= visit_details[:id_visit]

        @@logger.an_event.debug "id_visitor #{id_visitor}"
        @@logger.an_event.debug "id_visit #{id_visit}"

        proxy_system, port_proxy = browser_belongs_to_repository(visit_details[:visitor][:browser])

        @@logger.an_event.debug "browser belong to repository"

        execute_visit(filename_visit, port_proxy, proxy_system, @runtime_ruby)

        @@logger.an_event.info "visit #{id_visit} execute"

        delete_log_files_visitor(id_visitor)

        @@logger.an_event.debug "delete log file visitor id  #{id_visitor}"

      rescue Exception => e

        @@logger.an_event.error "Visitor Factory not execute visit #{id_visit} : #{e.message}"

      else

      ensure

        @@logger.an_event.debug "END AssignNewVisitorConnection.receive_object"
      end
    end
  end

  def browser_belongs_to_repository(browser_details)
    @@logger.an_event.debug "BEGIN browser_belongs_to_repository"
    @@logger.an_event.debug "os #{browser_details[:operating_system]}"
    @@logger.an_event.debug "os_version #{browser_details[:operating_system_version]}"
    @@logger.an_event.debug "browser #{browser_details[:name]}"
    @@logger.an_event.debug "browser_version #{browser_details[:version]}"


    begin

      proxy_system = @browser_type_repository.proxy_system?(browser_details[:operating_system],
                                                            browser_details[:operating_system_version],
                                                            browser_details[:name],
                                                            browser_details[:version]) == true ? "yes" : "no"
      @@logger.an_event.debug "proxy_system #{proxy_system}"

      port_proxy = @browser_type_repository.listening_port_proxy(browser_details[:operating_system],
                                                                  browser_details[:operating_system_version],
                                                                  browser_details[:name],
                                                                  browser_details[:version])[0]
      @@logger.an_event.debug "port_proxy #{port_proxy}"

    rescue Exception => e

      @@logger.an_event.error "browser not belong to repository browser type : #{e.message}"
      raise "browser not belong to repository browser type"

    else

      return [proxy_system, port_proxy]

    ensure
      @@logger.an_event.debug "END browser_belongs_to_repository"
    end
  end


  def execute_visit(file_name, listening_port_sahi, proxy_system, runtime_ruby)
    @@logger.an_event.debug "BEGIN execute_visit"
    @@logger.an_event.debug "listening_port_sahi #{listening_port_sahi}"
    @@logger.an_event.debug "filename #{file_name}"
    @@logger.an_event.debug "proxy_system #{proxy_system}"


    begin
      geolocation = "" if @default_type_geo == "none"
      geolocation = "-r #{@default_type_geo} -o #{@default_ip_geo} -x #{@default_port_geo} -y #{@default_user_geo} -w #{@default_pwd_geo}" unless @default_type_geo == "none"

      @@logger.an_event.debug "geolocation #{geolocation}"

      #TODO assurer que le port d'ecoute de sahi n'est pas occupé par une exécution du proxy non terminé (ou planté) si c'est le cas lors utilisé un autre numero de port issue d'un pool de secours

      @@logger.an_event.debug "runtime ruby #{runtime_ruby}"

      cmd = "#{runtime_ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{VISITOR_BOT} -v #{file_name} -t #{listening_port_sahi} -p #{proxy_system} #{geolocation}"

      @@logger.an_event.debug "cmd visitor_bot #{cmd}"

      sleep(2)
      status = OK
      pid = Process.spawn(cmd)
      pid, status = Process.wait2(pid, 0)

      raise "visitor_bot send an error to monitoring" unless status.exitstatus == OK
      Monitoring.send_success(@@logger)

    rescue Exception => e

      @@logger.an_event.error "visitor factory not execute visitor_bot : #{e.message}"
      raise "visitor factory not execute visitor_bot"

    ensure
      @@logger.an_event.debug "END execute_visit"
    end
  end

  def delete_log_files_visitor(id_visitor)
    @@logger.an_event.debug "BEGIN delete_log_files_visitor"
    begin

      dir = Pathname(File.join(File.dirname(__FILE__), "..", '..', "log")).realpath
      files = File.join(dir, "visitor_bot_#{id_visitor}.{*}")
      FileUtils.rm_r(Dir.glob(files), :force => true)

    rescue Exception => e

      @@logger.an_event.error "not delete log file visitor #{id_visitor} : #{e.message}"
      raise "not delete log file visitor #{id_visitor}"

    ensure
      @@logger.an_event.debug "END delete_log_files_visitor"
    end
  end

  def logger(logger)
    @@logger = logger
  end


  module_function :browser_belongs_to_repository
  module_function :delete_log_files_visitor
  module_function :execute_visit
  module_function :logger
end