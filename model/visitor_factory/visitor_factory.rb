require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require 'pathname'

module VisitorFactory
  VISITOR_NOT_LOADED_VISIT_FILE = 1
  VISITOR_NOT_BUILT_VISIT = 2
  VISITOR_IS_NOT_BORN = 10
  VISITOR_NOT_OPEN_BROWSER = 20
  VISITOR_NOT_EXECUTE_VISIT = 30
  VISITOR_NOT_FOUND_LANDING_PAGE = 31
  VISITOR_NOT_SURF_COMPLETLY = 32
  VISITOR_NOT_CLOSE_BROWSER = 40
  VISITOR_NOT_DIE = 50
  VISITOR_NOT_CLOSE_BROWSER_AND_NOT_DIE = 60
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@free_visitors = []
  @@sem_free_visitors = Mutex.new
  @@listening_port_proxy = 9999
  @@visitor_succ = 0
  @@visitor_not_loaded_visit_file = 0
  @@visitor_not_built_visit = 0
  @@visitor_is_not_born = 0
  @@visitor_cannot_die = 0
  @@visitor_cannot_close_browser = 0
  @@visitor_cannot_open_browser = 0
  @@visitor_not_execute_visit= 0
  @@visitor_cannot_continue_visit = 0
  @@visitor_die_dirty = 0
  @@visitor_start_failed = 0
  @@visitor_failed = 0
  @@count_visit = 0
  @@visitor_not_found_landing_page = 0
  @@visitor_not_close_visitor_and_not_die = 0

  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  DIR_VISITORS = Pathname(File.join(File.dirname(__FILE__), '..', '..', 'visitors')).realpath

  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :default_ip_geo,
         :default_port_geo,
         :default_user_geo,
         :default_pwd_geo,
         :default_type_geo


    def initialize(logger, geolocation)
      @@logger = logger
      @default_type_geo = geolocation[:proxy_type]
      if @default_type_geo != "none"
        @default_ip_geo = geolocation[:proxy_ip]
        @default_port_geo = geolocation[:proxy_port]
        @default_user_geo = geolocation[:proxy_user]
        @default_pwd_geo = geolocation[:proxy_pwd]
      end
    end


    def receive_object(filename_visit)
      filename_visit = Pathname(filename_visit).realpath
      @@logger.an_event.info "receive visit filename #{filename_visit}"
      port_proxy = listening_port_proxy
      port_visitor_bot = listening_port_visitor_bot
      @@count_visit +=1
      execute_visit(filename_visit, port_proxy, port_visitor_bot)
      @@sem_busy_visitors.synchronize {
        @@busy_visitors[port_proxy] = port_visitor_bot
        @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"
      }

      @@logger.an_event.debug @@busy_visitors
      close_connection
    end
  end


  def execute_visit(file_name, listening_port_sahi, listening_port_visitor_bot)
    #TODO meo asservissement en passant par parametre le listening_port_visitor_bot
    visitor_bot = Pathname(File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")).realpath
    geolocation = "" if @default_type_geo == "none"
    geolocation = "-p #{@default_type_geo} -r #{@default_ip_geo} -o #{@default_port_geo} -x #{@default_user_geo} -y #{@default_pwd_geo}" unless @default_type_geo == "none"
    #TODO déterminer la localisation du runtime ruby par parametrage ou automatiquement
    ruby = File.join("d:", "ruby193", "bin", "ruby.exe")
    begin
      cmd = "#{ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{visitor_bot} -v #{file_name} -t #{listening_port_sahi} #{geolocation}"
      sleep(2)
      status = 0
      pid = Process.spawn(cmd)
      pid, status = Process.wait2(pid, 0)

      @@sem_busy_visitors.synchronize {
        case status.exitstatus
          when 0
            @@visitor_succ += 1
          when VISITOR_NOT_LOADED_VISIT_FILE
             @@visitor_not_loaded_visit_file +=1
          when VISITOR_NOT_BUILT_VISIT
             @@visitor_not_built_visit +=1
          when VISITOR_IS_NOT_BORN
             @@visitor_is_not_born +=1
          when VISITOR_NOT_OPEN_BROWSER
            @@visitor_cannot_open_browser +=1
          when VISITOR_NOT_EXECUTE_VISIT
             @@visitor_not_execute_visit +=1
          when VISITOR_NOT_FOUND_LANDING_PAGE
            @@visitor_not_found_landing_page +=1
          when VISITOR_NOT_SURF_COMPLETLY
            @@visitor_cannot_continue_visit +=1
          when VISITOR_NOT_CLOSE_BROWSER
            @@visitor_cannot_close_browser +=1
          when VISITOR_NOT_DIE
            @@visitor_cannot_die +=1
          when VISITOR_NOT_CLOSE_BROWSER_AND_NOT_DIE
            @@visitor_not_close_visitor_and_not_die += 1
        end
        @@logger.an_event.info "count visit #{@@count_visit}"
        @@logger.an_event.info "count visit success #{@@visitor_succ}"
        @@logger.an_event.info "count visitor not loaded visit file #{@@visitor_not_loaded_visit_file}"
        @@logger.an_event.info "count visitor not built visit #{@@visitor_not_built_visit}"
        @@logger.an_event.info "count visitor not born #{@@visitor_is_not_born}"
        @@logger.an_event.info "count visitor cannot open browser #{@@visitor_cannot_open_browser}"
        @@logger.an_event.info "count visitor not execute visit #{@@visitor_not_execute_visit}"
        @@logger.an_event.info "count visitor not found landing page #{@@visitor_not_found_landing_page}"
        @@logger.an_event.info "count visitor cannot surf completly#{@@visitor_cannot_continue_visit}"
        @@logger.an_event.info "count visitor cannot close browser #{@@visitor_cannot_close_browser}"
        @@logger.an_event.info "count visitor cannot die #{@@visitor_cannot_die}"
        @@logger.an_event.info "count visitor not close browser and not die #{@@visitor_not_close_visitor_and_not_die}"
      }
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error "factory server cannot start visitor_bot"
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

  def listening_port_proxy
    #TODO calculer le listening port du proxy webdriver ou sahi
    @@listening_port_proxy-=1
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
  module_function :listening_port_proxy #le port d'écoute du proxy sahi ou webdriver
  module_function :listening_port_visitor_bot #le port d'écoute du visitor_bot qd il est asservi pour gérer les returnVisitor
  module_function :logger


end