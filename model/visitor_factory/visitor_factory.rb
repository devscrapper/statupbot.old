require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require 'pathname'

module VisitorFactory
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@free_visitors = []
  @@sem_free_visitors = Mutex.new
  @@listening_port_proxy = 9999
  @@visitor_succ = 0
  @@visitor_cannot_die = 0
  @@visitor_cannot_close_browser = 0
  @@visitor_cannot_open_browser = 0
  @@visitor_cannot_continue_visit = 0
  @@visitor_die_dirty = 0
  @@visitor_start_failed = 0
  @@visitor_failed = 0
  @@count_visit = 0
  @@visitor_not_found_landing_page = 0
  @@visitor_cannot_die_arr = []
  @@visitor_cannot_close_browser_arr = []
  @@visitor_cannot_open_browser_arr = []
  @@visitor_cannot_continue_visit_arr = []
  @@visitor_die_dirty_arr = []
  @@visitor_start_failed_arr = []
  @@visitor_failed_arr = []
  @@count_visit_arr = []
  @@visitor_not_found_landing_page_arr = []

  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  DIR_VISITORS = File.join(File.dirname(__FILE__), '..', '..', 'visitors')
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
      @@logger.an_event.debug "receive visit filename #{filename_visit}"
      port_proxy = listening_port_proxy
      port_visitor_bot = listening_port_visitor_bot
      @@count_visit +=1
      cr = execute_visit(filename_visit, port_proxy, port_visitor_bot)
      @@sem_busy_visitors.synchronize {
        case cr
          when 0
            @@visitor_succ += 1
          when 1
            @@visitor_cannot_die +=1
          when 2
            @@visitor_cannot_close_browser +=1
          when 3
            @@visitor_cannot_continue_visit +=1
          when 4
            @@visitor_die_dirty +=1
          when 5
            @@visitor_cannot_open_browser +=1
          when 6
            @@visitor_not_found_landing_page +=1
          when -1
            @@visitor_failed +=1
          when -2
            @@visitor_start_failed +=1
        end
        p "count visit #{@@count_visit}"
        p "count visit success #{@@visitor_succ}"
        p "count visitor cannot die #{@@visitor_cannot_die} : #{@@visitor_cannot_die_arr}"
        p "count visitor cannot close browser #{@@visitor_cannot_close_browser} : #{@@visitor_cannot_close_browser_arr}"
        p "count visitor cannot open browser #{@@visitor_cannot_open_browser} : #{@@visitor_cannot_open_browser_arr}"
        p "count visitor cannot surf #{@@visitor_cannot_continue_visit} : #{@@visitor_cannot_continue_visit_arr}"
        p "count visitor die dirty #{@@visitor_die_dirty} : #{@@visitor_die_dirty_arr}"
        p "count start visitor bot failed #{@@visitor_start_failed} : #{@@visitor_start_failed_arr}"
        p "count die visitor bot failed #{@@visitor_failed} : #{@@visitor_failed_arr}"
        p "count visitor not found landing page #{@@visitor_not_found_landing_page} : #{@@visitor_not_found_landing_page_arr}"
        @@busy_visitors[port_proxy] = port_visitor_bot
        @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"

      }


      @@sem_busy_visitors.synchronize {
        @@busy_visitors[port_proxy] = port_visitor_bot
        @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"
      }

      @@logger.an_event.debug @@busy_visitors
      close_connection
    end
  end
  class AssignReturnVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger, geolocation)
      @@logger = logger
    end

    def receive_object(filename_visit)
      close_connection
      visitor_id = nil
      @@sem_free_visitors.synchronize {
        if @@free_visitors.empty?
          @@logger.an_event.debug "receive visit filename #{filename_visit}"
          port_proxy = listening_port_proxy
          port_visitor_bot = listening_port_visitor_bot
          @@count_visit +=1
          cr = execute_visit(filename_visit, port_proxy, port_visitor_bot)
          case cr
            when 0
              @@visitor_succ += 1
            when 1
              @@visitor_cannot_die +=1
            when 2
              @@visitor_cannot_close_browser +=1
            when 3
              @@visitor_cannot_continue_visit +=1
            when 4
              @@visitor_die_dirty +=1
            when 5
              @@visitor_cannot_open_browser += 1
            when 6
              @@visitor_not_found_landing_page += 1
            when -1
              @@visitor_failed +=1
            when -2
              @@visitor_start_failed +=1
          end
          @@sem_busy_visitors.synchronize {
            @@busy_visitors[port_proxy] = port_visitor_bot
            @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"
          }
          p "count visit #{@@count_visit}"
          p "count success #{@@visitor_succ}"
          p "count cannot die #{@@visitor_cannot_die}"
          p "count cannot close browser #{@@visitor_cannot_close_browser}"
          p "count cannot continue visit #{@@visitor_cannot_continue_visit}"
          p "count die dirty #{@@visitor_die_dirty}"
          p "count start visitor bot failed #{@@visitor_start_failed}"
          p "count die visitor bot failed #{@@visitor_failed}"


          @@logger.an_event.debug @@busy_visitors
        else
          #TODO meo du reveil d'un visitor_bot pour un return visitor
          port_visitor_bot = @@free_visitors.shift[1]
          @@logger.an_event.info "remove visitor #{port_visitor_bot} from free visitors"
          @@logger.an_event.debug @@free_visitors
          @@sem_busy_visitors.synchronize { @@busy_visitors[port_proxy] = port_visitor_bot }
          @@logger.an_event.info "add visitor #{port_visitor_bot} to busy visitors"
          @@logger.an_event.debug @@busy_visitors
          #TODO Connect to visitor_bot port_visitor_bot et lui envoyer le filename_visit
          close_connection_after_writing
        end
      }

    end
  end

  def execute_visit(file_name, listening_port_sahi, listening_port_visitor_bot)
    #TODO meo asservissement en passant par parametre le listening_port_visitor_bot
    visitor_bot = File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")
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
      if status.exitstatus > 0
        visit_file = File.open(file_name, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)
        visit_file.close

        case status.exitstatus
          when 1 #Visitors::Visitor::VisitorException::CANNOT_DIE
            @@visitor_cannot_die_arr << [visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
            @@logger.an_event.error "visitor_bot cannot die"
          when 2 #Visitors::Visitor::VisitorException::CANNOT_CLOSE_BROWSER
            @@logger.an_event.error "visitor_bot cannot close his browser"
            @@visitor_cannot_close_browser_arr<< [visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
            browser_exe = "chrome.exe" if visit_details[:visitor][:browser][:name] == "Chrome"
            browser_exe = "iexplore.exe" if visit_details[:visitor][:browser][:name] == "Internet Explorer"
            browser_exe = "firefox.exe" if visit_details[:visitor][:browser][:name] == "Firefox"
            pid = Process.spawn("taskkill /F /IM #{browser_exe}")
            Process.wait2(pid, 0)
            @@logger.an_event.info "Visitor_Factory close all browser #{browser_exe}"
            FileUtils.rm_r(Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id])).realpath) if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
            @@logger.an_event.info "delete #{Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id]))}" if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
          when 3 #Visitors::Visitor::VisitorException::CANNOT_CONTINUE_SURF
            @@logger.an_event.error "visitor_bot cannnot continue surf"
            @@visitor_cannot_continue_visit_arr <<[visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
          when 4 #Visitors::Visitor::VisitorException::DIE_DIRTY
            @@logger.an_event.error "visitor_bot die dirty"
            @@visitor_die_dirty_arr <<[visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
            FileUtils.rm_r(Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id])).realpath) if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
            @@logger.an_event.info "delete #{Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id]))}"  if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
          when 5 #Visitors::Visitor::VisitorException::CANNOT_OPEN_BROWSER
            @@visitor_cannot_open_browser_arr <<[visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
          when 6 # Visitors::Visitor::VisitorException::NOT_FOUND_LANDING_PAGE
            @@visitor_not_found_landing_page_arr <<[visit_details[:visitor][:id], visit_details[:visitor][:browser][:name]]
            FileUtils.rm_r(Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id])).realpath) if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
            @@logger.an_event.info "delete #{Pathname(File.join(DIR_VISITORS, visit_details[:visitor][:id]))}"  if Dir.exists?(File.join(DIR_VISITORS, visit_details[:visitor][:id]))
        end
      end
      return status.exitstatus
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error "factory server cannot start visitor_bot"
    end
    return -2
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