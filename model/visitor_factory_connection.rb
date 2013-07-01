require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative 'visitor'
require_relative 'webdriver_factory_connection'

module VisitorFactory
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/visitor_factory_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  @@return_visitors = []
  @@sem_return_visitors = Mutex.new
  attr_reader :assign_new_visitor_listening_port,
              :assign_return_visitor_listening_port,
              :unassign_visitor_listening_port,
              :return_visitors_listening_port
  $staging = "production"
  $debugging = false
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def receive_object(visitor)
      kill_old_return_visitors()
      @logger.an_event.debug "receive visitor #{visitor}"

      q = EM::Queue.new
      WebdriverFactory.assign_browser(visitor.browser, q)
      q.pop { |browser|
        @logger.an_event.debug "pop browser #{browser.id} with webdriver #{browser.webdriver.uri} from queue #{q}"
        visitor.browser = browser
        @logger.an_event.info "assign browser #{browser.id} to visitor #{visitor.id}"
        visitor.browser.open()
        @logger.an_event.info "open browser #{browser.id}"
        send_object visitor
        @logger.an_event.debug "return visitor #{visitor}"
      }
    end
  end
  class AssignReturnVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def receive_object(visitor)
      @logger.an_event.debug "visitor receive #{visitor.to_s}"
      @@sem_return_visitors.synchronize {
        kill_old_return_visitors()

        if @@return_visitors.empty?
          @logger.an_event.warn "repository return visitors is empty"
          q = EM::Queue.new
          WebdriverFactory.assign_browser(visitor.browser, q)
          q.pop { |browser|
            visitor.browser = browser
            @logger.an_event.info "assign browser #{browser.id} to visitor #{visitor.id}"
            visitor.browser.open()
            @logger.an_event.info "open browser #{browser.id}"

            send_object visitor }
        else
          return_visitor = @@return_visitors.shift[1]
          @logger.an_event.info "select return visitor #{return_visitor.id}"
          send_object return_visitor
          @logger.an_event.debug "return visitor #{return_visitor}"
        end
      }
    end
  end
  class ReturnVisitorsConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @logger = logger
    end

    def post_init()
      @logger.an_event.info "send repository return visitors(#{@@return_visitors.size})"
      send_object @@return_visitors
    end
  end
  class UnAssignVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def receive_object(visitor)
      @logger.an_event.debug "receive visitor #{visitor}"
      @@sem_return_visitors.synchronize {
        @@return_visitors << [Time.now, visitor]
        @logger.an_event.info "add visitor #{visitor.id} to repository"
        @logger.an_event.debug "data repository return visitors #{@@return_visitors}"
      }
      close_connection
      @logger.an_event.debug "close connection"
    end

    def unbind
    end
  end

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor
    attr :q

    def initialize(visitor, q)
      @q = q
      @visitor = visitor
    end

    def receive_object(visitor)
      @q.push visitor
      close_connection
    end

    def post_init
      send_object @visitor
    end

    def unbind

    end
  end
  class AssignReturnVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor
    attr :q

    def initialize(visitor, q)
      @q = q
      @visitor = visitor
    end

    def receive_object(visitor)
      @q.push visitor
      close_connection
    end

    def post_init
      send_object @visitor
    end

    def unbind

    end
  end
  class ReturnVisitorsClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :q

    def initialize(q)
      @q = q
    end

    def receive_object(return_visitors)
      @q.push return_visitors
      close_connection
    end
  end
  class UnAssignVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :visitor

    def initialize(visitor)
      @visitor = visitor
    end

    def post_init
      send_object @visitor
    end
  end
  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def assign_new_visitor(visitor)
    load_parameter()
    q = EM::Queue.new
    EM.connect "localhost", @assign_new_visitor_listening_port, AssignNewVisitorClient, visitor, q
    q
  end

  def assign_return_visitor(visitor)
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    load_parameter()
    q = EM::Queue.new
    EM.connect "localhost", @assign_return_visitor_listening_port, AssignReturnVisitorClient, visitor, q
    q
  end

  def return_visitors()
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    load_parameter()
    q = EM::Queue.new
    EM.connect "localhost", @return_visitors_listening_port, ReturnVisitorsClient, q
    q
  end

  def unassign_visitor(visitor)
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    load_parameter()
    EM.connect "localhost", @unassign_visitor_listening_port, UnAssignVisitorClient, visitor
  end

  def load_parameter()
    @listening_port = 9203 # port d'ecoute
    begin
      environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
      $staging = environment["staging"] unless environment["staging"].nil?
    rescue Exception => e
      STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
    end

    begin
      params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
      @unassign_visitor_listening_port = params[$staging]["unassign_visitor_listening_port"] unless params[$staging]["unassign_visitor_listening_port"].nil?
      @assign_new_visitor_listening_port = params[$staging]["assign_new_visitor_listening_port"] unless params[$staging]["assign_new_visitor_listening_port"].nil?
      @assign_return_visitor_listening_port = params[$staging]["assign_return_visitor_listening_port"] unless params[$staging]["assign_return_visitor_listening_port"].nil?
      @return_visitors_listening_port = params[$staging]["return_visitors_listening_port"] unless params[$staging]["return_visitors_listening_port"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  def kill_old_return_visitors()
    @logger.an_event.debug "before cleaning, count return visitor : #{@@return_visitors.size}"
    old_return_visitors = @@return_visitors.select{ |x| x[0] < Time.now - (5 + 5 + 5) * 60 }
    @logger.an_event.debug "old return visitors(#{old_return_visitors.size}) : #{old_return_visitors}"
    @@return_visitors = @@return_visitors.select{ |x| x[0] > Time.now - (5 + 5 + 5) * 60}
    @logger.an_event.debug "kept return visitors(#{@@return_visitors.size}) : #{@@return_visitors}"

    old_return_visitors.each { |x|
      @logger.an_event.info "close browser #{x[1].browser.id} of visitor #{x[1].id}"
      x[1].browser.close
      @logger.an_event.info "unassign browser #{x[1].browser.id} of visitor #{x[1].id}"
      WebdriverFactory.unassign_browser(x[1].browser)
      #TODO supprimer le customgif du visitor chez customize_queries_server
    }
    @logger.an_event.debug "after cleaning, count return visitor : #{@@return_visitors.size}"
  end

  module_function :return_visitors
  module_function :kill_old_return_visitors
  module_function :assign_new_visitor
  module_function :assign_return_visitor
  module_function :unassign_visitor
  module_function :load_parameter

end