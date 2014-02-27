require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'

module VisitorFactory
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../../parameter/visitor_factory_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../../parameter/environment.yml"
  $staging = "production"
  $debugging = false
  attr_reader :assign_new_visitor_listening_port,
              :assign_return_visitor_listening_port,
              :firefox_path,
              :home, #détermine si on est à la maison ou au bouloit pour utiliser le bon geolocation
              :debug_outbound_queries #determine si on envoie les requetes googleanalytics vers FakeProxy pour débugger ou directement (usage au boulot, Home alors utilise mitmproxy)

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_details
    attr :logger

    def initialize(visitor_details, logger)
      begin
        @visitor_details = visitor_details
        @logger = logger
      rescue Exception => e
        p e.message
      end
    end
    def post_init
      begin
        send_object @visitor_details
        @logger.an_event.info "assignement of visitor is asked to VisitorFactory"
      rescue Exception => e
        p e.message
      end
    end

  end
  class AssignReturnVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_details
    attr :q, :logger

    def initialize(visitor_details, q, logger)
      @q = q
      @visitor_details = visitor_details
      @logger = logger
    end

    def receive_object(visitor_id)
      @q.push visitor_id
    end

    def post_init
      send_object @visitor_details
      @logger.an_event.info "assignement of a return visitor is asked to VisitorFactory"
    end

  end

  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def assign_new_visitor(visitor_details, logger)
    begin
      load_parameter()
      EM.connect '127.0.0.1', @assign_new_visitor_listening_port, AssignNewVisitorClient, visitor_details, logger
    rescue Exception => e
      logger.an_event.debug e
    end
  end

  def assign_return_visitor(visitor_details, logger)
    begin
      load_parameter()
      q = EM::Queue.new
      EM.connect '127.0.0.1', @assign_return_visitor_listening_port, AssignReturnVisitorClient, visitor_details, q, logger
      q
    rescue Exception => e
      @@logger.an_event.debug e
    end
  end







  def load_parameter
    @listening_port = 9203 # port d'ecoute
    begin
      environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
      $staging = environment["staging"] unless environment["staging"].nil?
    rescue Exception => e
      STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
    end

    begin
      params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
      @assign_new_visitor_listening_port = params[$staging]["assign_new_visitor_listening_port"] unless params[$staging]["assign_new_visitor_listening_port"].nil?
      @assign_return_visitor_listening_port = params[$staging]["assign_return_visitor_listening_port"] unless params[$staging]["assign_return_visitor_listening_port"].nil?
      @firefox_path = params[$staging]["firefox_path"] unless params[$staging]["firefox_path"].nil?
      @home = params[$staging]["home"] unless params[$staging]["home"].nil?
      @debug_outbound_queries = params[$staging]["debug_outbound_queries"] unless params[$staging]["debug_outbound_queries"].nil?

      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end


  module_function :assign_new_visitor
  module_function :assign_return_visitor
  module_function :load_parameter


end