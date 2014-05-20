require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'

module Monitoring
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../../parameter/monitoring_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../../parameter/environment.yml"
  $staging = "production"
  $debugging = false
  attr_reader :return_code_listening_port, :http_server_listening_port

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class ReturnCodeClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :data
    attr :logger

    def initialize(return_code, visit_details, logger)
      begin
        @data = {:return_code => return_code, :visit_details => visit_details}

        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @data
        @logger.an_event.info "send return code #{@data[:return_code].code} and details of visit to monitoring server"
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def unbind
      EM.stop
    end

  end


  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def send_return_code(return_code, visit_details, logger)
    begin

      load_parameter()
      EventMachine.run {
        EM.connect '127.0.0.1', @return_code_listening_port, ReturnCodeClient, return_code.to_super, visit_details, logger
      }
    rescue Exception => e
      logger.an_event.error "not sent return code #{return_code.code} and details of visit #{visit_details[:id_visit]} to monitoring server : #{e.message}"
    end
  end

  def load_parameter
    @listening_port = 9230 # port d'ecoute
    begin
      environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
      $staging = environment["staging"] unless environment["staging"].nil?
    rescue Exception => e
      STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
    end

    begin
      params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
      @return_code_listening_port = params[$staging]["return_code_listening_port"] unless params[$staging]["return_code_listening_port"].nil?
      @http_server_listening_port = params[$staging]["http_server_listening_port"] unless params[$staging]["http_server_listening_port"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  def return_code_listening_port
    @return_code_listening_port
  end

  module_function :send_return_code
  module_function :return_code_listening_port
  module_function :http_server_listening_port
  module_function :load_parameter


end