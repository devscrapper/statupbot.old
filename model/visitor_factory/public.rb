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
  attr_reader :assign_new_visitor_listening_port, :runtime_ruby

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visit_filename
    attr :logger

    def initialize(visit_filename, logger)
      begin
        @visit_filename = visit_filename
        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @visit_filename
        @logger.an_event.info "send visit file #{@visit_filename} to VisitorFactory"
      rescue Exception => e
        @logger.an_event.error "not send visit file #{@visit_filename} to VisitorFactory#{e.message}"
      end
    end

    def unbind
      EM.stop
    end

  end


  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def assign_new_visitor(visit_filename, logger)
    begin
      load_parameter()
      EventMachine.run {
        EM.connect '127.0.0.1', @assign_new_visitor_listening_port, AssignNewVisitorClient, visit_filename, logger
      }
    rescue Exception => e
      logger.an_event.error "not sent visit filename #{visit_filename} to Visitor Factory server : #{e.message}"
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
      @runtime_ruby = params[$staging]["runtime_ruby"].join(File::SEPARATOR) unless params[$staging]["runtime_ruby"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end


  module_function :assign_new_visitor
  module_function :load_parameter


end