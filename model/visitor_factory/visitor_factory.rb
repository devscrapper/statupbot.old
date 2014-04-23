require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require 'pathname'

module VisitorFactory
  #--------------------------------------------------------------------------------------------------------------------
  # return code Visitor_Bot
  #--------------------------------------------------------------------------------------------------------------------
  VISIT_NOT_BUILT = 10
  VISIT_FILE_NOT_LOADED = 11
  VISIT_MEDIUM_REFERER_UNKNOWN = 12
  VISIT_ENGINE_REFERER_UNKNOWN = 13
  VISIT_BAD_PROPERTIES = 14
  VISITOR_IS_NOT_BORN = 20
  VISITOR_IS_NOT_BORN_CONFIG_ERROR = 21
  VISITOR_IS_NOT_BORN_TECHNICAL_ERROR = 22
  VISITOR_NOT_OPEN_BROWSER = 30
  VISITOR_NOT_EXECUTE_VISIT = 40
  SERVER_START_PAGE_IS_NOT_STARTED = 41
  VISITOR_NOT_FOUND_LANDING_PAGE = 42
  VISITOR_NOT_SURF_COMPLETLY = 43
  VISITOR_NOT_CLOSE_BROWSER = 50
  VISITOR_NOT_DIE = 60
  VISITOR_NOT_INHUME = 70


  #--------------------------------------------------------------------------------------------------------------------
  # Global variables
  #--------------------------------------------------------------------------------------------------------------------
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@free_visitors = []
  @@sem_free_visitors = Mutex.new
  @@listening_port_proxy = 9999

  #--------------------------------------------------------------------------------------------------------------------
  # Statistics
  #--------------------------------------------------------------------------------------------------------------------
  @@statistics = []
  STAT_COUNT_VISIT = 0
  STAT_VISIT_SUCCESS = 1
  STAT_VISIT_ERROR_NOT_LOADED = 2
  STAT_VISIT_ERROR_NOT_BUILT = 3
  STAT_VISIT_ERROR_BAD_PROPERTIES = 4
  STAT_VISIT_NOT_EXECUTE = 5
  STAT_VISITOR_ERROR_NOT_BORN = 6
  STAT_VISITOR_ERROR_NOT_OPEN_BROWSER = 7
  STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE = 8
  STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER = 9
  STAT_VISITOR_ERROR_NOT_DIE = 10
  STAT_VISITOR_ERROR_DIE_DIRTY = 11
  @@statistics[STAT_COUNT_VISIT]=[0, []]
  @@statistics[STAT_VISIT_SUCCESS]=[0, []]
  @@statistics[STAT_VISIT_ERROR_NOT_LOADED]=[0, []]
  @@statistics[STAT_VISIT_ERROR_NOT_BUILT]=[0, []]
  @@statistics[STAT_VISIT_ERROR_BAD_PROPERTIES]=[0, []]
  @@statistics[STAT_VISIT_NOT_EXECUTE]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_NOT_BORN]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_NOT_OPEN_BROWSER]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_NOT_DIE]=[0, []]
  @@statistics[STAT_VISITOR_ERROR_DIE_DIRTY]=[0, []]


  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :default_ip_geo,
         :default_port_geo,
         :default_user_geo,
         :default_pwd_geo,
         :default_type_geo,
         :browser_type_repository


    def initialize(browser_type_repository, logger, geolocation)
      @@logger = logger
      @default_type_geo = geolocation[:proxy_type]
      @browser_type_repository = browser_type_repository
      if @default_type_geo != "none"
        @default_ip_geo = geolocation[:proxy_ip]
        @default_port_geo = geolocation[:proxy_port]
        @default_user_geo = geolocation[:proxy_user]
        @default_pwd_geo = geolocation[:proxy_pwd]
      end
    end


    def receive_object(filename_visit)
      if filename_visit != ""
        filename_visit = Pathname(filename_visit).realpath
        @@logger.an_event.debug "receive visit filename #{filename_visit}"
        #port_proxy = listening_port_proxy
        port_visitor_bot = listening_port_visitor_bot
        visit_file = File.open(filename_visit, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)
        os = visit_details[:visitor][:browser][:operating_system]
        @@logger.an_event.debug "os #{os}"
        os_version = visit_details[:visitor][:browser][:operating_system_version]
        @@logger.an_event.debug "os_version #{os_version}"

        browser = visit_details[:visitor][:browser][:name]
        @@logger.an_event.debug "browser #{browser}"

        browser_version = visit_details[:visitor][:browser][:version]
        @@logger.an_event.debug "browser_version #{browser_version}"

        id_visitor = visit_details[:visitor][:id]
        @@logger.an_event.debug "id_visitor #{id_visitor}"

        id_visit = visit_details[:id_visit]
        @@logger.an_event.debug "id_visit #{id_visit}"

        begin
          proxy_system = @browser_type_repository.proxy_system?(os, os_version, browser, browser_version) == true ? "yes" : "no"
          @@logger.an_event.debug "proxy_system #{proxy_system}"

          port_proxy = @browser_type_repository.listening_port_proxy(os, os_version, browser, browser_version)[0]
          @@logger.an_event.debug "port_proxy #{port_proxy}"

          @@statistics[STAT_COUNT_VISIT][0] +=1
          @@statistics[STAT_COUNT_VISIT][1] << id_visit

          execute_visit(filename_visit, port_proxy, port_visitor_bot, proxy_system, id_visitor, id_visit)

          @@sem_busy_visitors.synchronize {
            @@busy_visitors[port_proxy] = port_visitor_bot
            @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"
          }

        rescue Exception => e
          @@logger.an_event.error e.message
            # EM.stop
        ensure
          @@logger.an_event.debug @@busy_visitors
          close_connection
        end
      else
        @@logger.an_event.error "visit file is empty"
        close_connection
      end
    end
  end


  def execute_visit(file_name, listening_port_sahi, listening_port_visitor_bot, proxy_system, id_visitor, id_visit)
    #TODO intégrer browser_type
    #TODO meo asservissement en passant par parametre le listening_port_visitor_bot

    visitor_bot = Pathname(File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")).realpath
    geolocation = "" if @default_type_geo == "none"
    geolocation = "-r #{@default_type_geo} -o #{@default_ip_geo} -x #{@default_port_geo} -y #{@default_user_geo} -w #{@default_pwd_geo}" unless @default_type_geo == "none"
    #TODO déterminer la localisation du runtime ruby par parametrage ou automatiquement
    #TODO assurer que le port d'ecoute de sahi n'est pas occupé par une exécution du proxy non terminé (ou planté) si c'est le cas lors utilisé un autre numero de port issue d'un pool de secours
    ruby = File.join("d:", "ruby193", "bin", "ruby.exe")
    begin
      cmd = "#{ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{visitor_bot} -v #{file_name} -t #{listening_port_sahi} -p #{proxy_system} #{geolocation}"
      sleep(2)
      status = 0
      pid = Process.spawn(cmd)
      pid, status = Process.wait2(pid, 0)

      @@sem_busy_visitors.synchronize {
        case status.exitstatus
          when 0
            @@statistics[STAT_VISIT_SUCCESS][0] +=1
            @@statistics[STAT_VISIT_SUCCESS][1] << id_visit
            dir = Pathname(File.join(File.dirname(__FILE__), "..", '..', "log")).realpath
            files = File.join(dir, "visitor_bot_#{id_visitor}.{*}")
            FileUtils.rm_r(Dir.glob(files), :force => true)


          when VISITOR_NOT_LOADED_VISIT_FILE
            @@statistics[STAT_VISIT_ERROR_NOT_LOADED][0] +=1
            @@statistics[STAT_VISIT_ERROR_NOT_LOADED][1] << id_visit
          when VISITOR_NOT_BUILT_VISIT
            @@statistics[STAT_VISIT_ERROR_NOT_BUILT][0] +=1
            @@statistics[STAT_VISIT_ERROR_NOT_BUILT][1] << id_visit
          when VISITOR_NOT_BUILT_VISIT_BAD_PROPERTIES
            @@statistics[STAT_VISIT_ERROR_BAD_PROPERTIES][0] +=1
            @@statistics[STAT_VISIT_ERROR_BAD_PROPERTIES][1] << id_visit
          when VISITOR_IS_NOT_BORN
            @@statistics[STAT_VISITOR_ERROR_NOT_BORN][0] +=1
            @@statistics[STAT_VISITOR_ERROR_NOT_BORN][1] << id_visit
          when VISITOR_NOT_OPEN_BROWSER
            @@statistics[STAT_VISITOR_ERROR_NOT_OPEN_BROWSER][0] +=1
            @@statistics[STAT_VISITOR_ERROR_NOT_OPEN_BROWSER][1] << id_visit
          when SERVER_START_PAGE_IS_NOT_STARTED
            @@logger.an_event.fatal "server start page is not started"
          when VISITOR_NOT_EXECUTE_VISIT
            @@statistics[STAT_VISIT_NOT_EXECUTE][0] +=1
            @@statistics[STAT_VISIT_NOT_EXECUTE][1] << id_visit
          when VISITOR_NOT_FOUND_LANDING_PAGE
            @@statistics[STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE][0] +=1
            @@statistics[STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE][1] << id_visit
          when VISITOR_NOT_SURF_COMPLETLY
            @@statistics[STAT_VISIT_NOT_EXECUTE][0] +=1
            @@statistics[STAT_VISIT_NOT_EXECUTE][1] << id_visit
          when VISITOR_NOT_CLOSE_BROWSER
            @@statistics[STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER][0] +=1
            @@statistics[STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER][1] << id_visit
          when VISITOR_NOT_DIE
            @@statistics[STAT_VISITOR_ERROR_NOT_DIE][0] +=1
            @@statistics[STAT_VISITOR_ERROR_NOT_DIE][1] << id_visit
        end
        @@logger.an_event.info "count visit                          => #{@@statistics[STAT_COUNT_VISIT][0]} | #{@@statistics[STAT_COUNT_VISIT][1]}"
        @@logger.an_event.info "count visit success                  => #{@@statistics[STAT_VISIT_SUCCESS][0]} | #{@@statistics[STAT_VISIT_SUCCESS][1]}"
        @@logger.an_event.info "count visit file oaded               => #{@@statistics[STAT_VISIT_ERROR_NOT_LOADED][0]} | #{@@statistics[STAT_VISIT_ERROR_NOT_LOADED][1]}"
        @@logger.an_event.info "count visit not built                => #{@@statistics[STAT_VISIT_ERROR_NOT_BUILT][0]} | #{@@statistics[STAT_VISIT_ERROR_NOT_BUILT][1]}"
        @@logger.an_event.info "count bad properties in visit        => #{@@statistics[STAT_VISIT_ERROR_BAD_PROPERTIES][0]} | #{@@statistics[STAT_VISIT_ERROR_BAD_PROPERTIES][1]}"
        @@logger.an_event.info "count visitor not born               => #{@@statistics[STAT_VISITOR_ERROR_NOT_BORN][0]} | #{@@statistics[STAT_VISITOR_ERROR_NOT_BORN][1]}"
        @@logger.an_event.info "count visitor not open browser       => #{@@statistics[STAT_VISITOR_ERROR_NOT_OPEN_BROWSER][0]} | #{@@statistics[STAT_VISITOR_ERROR_NOT_OPEN_BROWSER][1]}"
        @@logger.an_event.info "count visitor not found landing page => #{@@statistics[STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE][0]} | #{@@statistics[STAT_VISITOR_ERROR_NOT_FOUND_LANDING_PAGE][1]}"
        @@logger.an_event.info "count visitor not execute visit      => #{@@statistics[STAT_VISIT_NOT_EXECUTE][0]} | #{@@statistics[STAT_VISIT_NOT_EXECUTE][1]}"
        @@logger.an_event.info "count visitor not close browser      => #{@@statistics[STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER][0]} | #{@@statistics[STAT_VISITOR_ERROR_NOT_CLOSE_BROWSER][1]}"
        @@logger.an_event.info "count visitor not die                => #{@@statistics[STAT_VISITOR_ERROR_NOT_DIE][0]} | #{@@statistics[STAT_VISITOR_ERROR_NOT_DIE][1]}"
        @@logger.an_event.info "count visitor die dirty              => #{@@statistics[STAT_VISITOR_ERROR_DIE_DIRTY][0]} | #{@@statistics[STAT_VISITOR_ERROR_DIE_DIRTY][1]}"
      }
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error "factory server catch an error from visitor_bot"
      raise e
    end
  end


  def garbage_free_visitors
    begin
      @@logger.an_event.info "garbage free visitors is start"
      @@logger.an_event.debug "before cleaning, count free visitors : #{@@free_visitors.size}"
      @@logger.an_event.debug @@free_visitors
      size = @@free_visitors.size
      @@free_visitors.delete_if { |visitor|
        if visitor[0] < Time.now - (5 + 5 + 5) * 60
          @@logger.an_event.info "visitor #{visitor[1].id} is killed"
          @@logger.an_event.debug "remove visitor #{visitor[1].id}"
          visitor[1].close_browser
          true
        end
      }
      @@logger.an_event.debug "after cleaning, count free visitors : #{@@free_visitors.size}"
      @@logger.an_event.debug @@free_visitors
      @@logger.an_event.info "garbage free visitors is over, #{size - @@free_visitors.size} visitor(s) was(were) garbage"
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error e.message
    end

  end

  def listening_port_visitor_bot
    #TODO calculer le listening port de visitor bot pour l"asservissemnt"
    10000
  end

  def logger(logger)
    @@logger = logger
  end

  module_function :execute_visit
  module_function :garbage_free_visitors
  #  module_function :listening_port_proxy #le port d'écoute du proxy sahi ou webdriver
  module_function :listening_port_visitor_bot #le port d'écoute du visitor_bot qd il est asservi pour gérer les returnVisitor
  module_function :logger


end