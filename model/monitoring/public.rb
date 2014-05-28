require_relative '../error'
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
    attr :logger, :stop

    def initialize(return_code, visit_details, logger, stop)
      begin
        @data = {:return_code => return_code, :visit_details => visit_details}
        @stop = stop
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
        @logger.an_event.error "not send return code #{@data[:return_code].code} and details of visit to monitoring server : #{e.message}"
      end
    end

    def unbind
      EM.stop if @stop
    end

  end


  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def send_return_code(return_code, visit_details, logger)
    begin

      load_parameter()
      stop_EM = false
      EM.connect '127.0.0.1', @return_code_listening_port, ReturnCodeClient, return_code.to_super, visit_details, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          EventMachine.run {
            stop_EM = true
            EM.connect '127.0.0.1', @return_code_listening_port, ReturnCodeClient, return_code.to_super, visit_details, logger, stop_EM
          }
        else
          logger.an_event.error "not sent success code to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent return code #{return_code.code} and details of visit #{visit_details[:id_visit]} to monitoring server : #{e.message}"
    end
  end

  def send_success(logger)
    begin
      load_parameter()
      # par defaut on considere que EM est déjà actif => stop_EM = false
      # cas d'usage  : visitor_factory_server ; il ne faut pas stoper la boucle EM avec EM.stop localisé dans unbind (ci-dessus)
      stop_EM = false
      EM.connect '127.0.0.1', @return_code_listening_port, ReturnCodeClient, Errors::Error.new(0), {}, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          # EM n'est pas actif ; une exception a été levée alors on lance EM => stop_EM = true
          # cas d'usage : visitor_bot ; il faut arrter la boucle EM au moyen del 'EM.stop localisé dans unbind(ci-dessus)
          EM.run {
            stop_EM = true
            EM.connect '127.0.0.1', @return_code_listening_port, ReturnCodeClient, Errors::Error.new(0), {}, logger, stop_EM
          }
        else
          logger.an_event.error "not sent success code to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent success code to monitoring server : #{e.message}"

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
  module_function :send_success
  module_function :return_code_listening_port
  module_function :http_server_listening_port
  module_function :load_parameter


end