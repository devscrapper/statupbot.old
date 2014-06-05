require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'

module VisitFactory
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../../parameter/visit_factory_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../../parameter/environment.yml"
  $staging = "production"
  $debugging = false
  attr_reader :listening_port

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class Client < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visit_details
    attr :logger

    def initialize(visit_details, logger)
      begin
        @visit_details = visit_details
        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @visit_details
        @logger.an_event.info "send visit details #{@visit_details} to VisitFactory"
      rescue Exception => e
        @logger.an_event.error "not send visit details #{@visit_details} to VisitFactory#{e.message}"
      end
    end

    def unbind
      EM.stop
    end
  end


  #--------------------------------------------------------------------------------------------------------------------
  # functions publiques
  #--------------------------------------------------------------------------------------------------------------------
  def load_parameter()
    @listening_port = 9210 # port d'ecoute
    begin
      environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
      $staging = environment["staging"] unless environment["staging"].nil?
    rescue Exception => e
      STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
    end

    begin
      params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
      @listening_port = params[$staging]["listening_port"] unless params[$staging]["listening_port"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  def plan(device_visitor, visit_details, website, logger)
    begin
      load_parameter()

      data = {:website_label => website,
              :visit_details => visit_details}
      logger.an_event.debug "data #{data}"
      logger.an_event.debug "device_visitor #{device_visitor}"
      logger.an_event.debug "listening_port #{@listening_port}"

      EventMachine.run {
        EM.connect device_visitor, @listening_port, Client, data, logger
      }
    rescue Exception => e
      logger.an_event.error "not sent visit details #{visit_details["id_visit"]} to Visitor Factory server : #{e.message}"
    end

  end

  def plan_force_start_time_visit(device_visitor, visit_details, website, start_date_time_visit, logger)
      visit_details["start_date_time"] = start_date_time_visit.to_s
      logger.an_event.debug "visit_details #{visit_details}"
      plan(device_visitor, visit_details, website, logger)
  end


  module_function :plan
  module_function :plan_force_start_time_visit
  module_function :load_parameter
end