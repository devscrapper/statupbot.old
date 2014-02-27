require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'



module VisitorFactory
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@free_visitors = []
  @@sem_free_visitors = Mutex.new
  @@listening_port_proxy = 9999
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
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
      execute_visit(filename_visit, port_proxy, port_visitor_bot)
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

      visitor_id = nil
      @@sem_free_visitors.synchronize {
        if @@free_visitors.empty?
          @@logger.an_event.debug "receive visit filename #{filename_visit}"
          port_proxy = listening_port_proxy
          port_visitor_bot = listening_port_visitor_bot
          execute_visit(filename_visit, port_proxy, port_visitor_bot)
          @@sem_busy_visitors.synchronize {
            @@busy_visitors[port_proxy] = port_visitor_bot
            @@logger.an_event.info "add visitor listening port visitor #{port_visitor_bot} to busy visitors"
          }

          @@logger.an_event.debug @@busy_visitors
          close_connection
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
    @@logger.an_event.info "execute visit is starting"
    visitor_bot = File.join(File.dirname(__FILE__), "..", "..", "run", "visitor_bot.rb")
    geolocation = "" if @default_type_geo == "none"
    geolocation = "-p #{@default_type_geo} -r #{@default_ip_geo} -o #{@default_port_geo} -x #{@default_user_geo} -y #{@default_pwd_geo}" unless @default_type_geo == "none"
    #TODO déterminer la localisation du runtime ruby par parametrage ou automatiquement
    ruby = File.join("d:", "ruby193", "bin", "ruby.exe")
    begin
      cmd = "#{ruby} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{visitor_bot} -v #{file_name} -t #{listening_port_sahi} #{geolocation}"
      sleep(2)
      status = 0
      Process.spawn(cmd)
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error "factory server cannot start visitor_bot"
    end
    @@logger.an_event.info "execute visit is stopped"
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