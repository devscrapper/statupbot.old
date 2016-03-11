require_relative 'parameter'
require_relative 'error'
require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'


module Monitoring
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../../parameter/monitoring_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../../parameter/environment.yml"
  START = :started
  SUCCESS = :success
  FAIL = :fail
  OUTOFTIME = :outoftime

  $staging = "production"
  $debugging = false
  attr_reader :return_code_listening_port,
              :pool_size_listening_port,
              :http_server_listening_port,
              :visit_out_of_time_listening_port,
              :advert_select_listening_port,
              :monitor_server_ip,
              :statupweb_server_ip,
              :statupweb_server_port

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
      #@logger.an_event.info "stop_EM=#{@stop}"
      EM.stop if @stop
    end

  end

  class PoolSizeClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :data
    attr :logger, :stop

    def initialize(visit_details, logger, stop)
      begin
        @data = visit_details
        @stop = stop
        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @data
        @logger.an_event.info "send visit out of time to monitoring server"
      rescue Exception => e
        @logger.an_event.error "not send visit out of time to monitoring server : #{e.message}"
      end
    end

    def unbind
      EM.stop if @stop
    end

  end


  class VisitOutOfTimeClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :data
    attr :logger, :stop

    def initialize(pool_size, logger, stop)
      begin
        @data = pool_size
        @stop = stop
        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @data
        @logger.an_event.info "send pool size to monitoring server"
      rescue Exception => e
        @logger.an_event.error "not send pool size to monitoring server : #{e.message}"
      end
    end

    def unbind
      EM.stop if @stop
    end

  end

  class AdvertSelectClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :data
    attr :logger, :stop

    def initialize(visit_details, logger, stop)
      begin
        @data = visit_details
        @stop = stop
        @logger = logger
      rescue Exception => e
        @logger.an_event.error "#{e.message}"
      end
    end

    def post_init
      begin
        send_object @data
        @logger.an_event.info "send advert select to monitoring server"
      rescue Exception => e
        @logger.an_event.error "not send advert select to monitoring server : #{e.message}"
      end
    end

    def unbind
      EM.stop if @stop
    end

  end
  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def send_advert_select(visit_details, logger)
    begin
      load_parameter()
      stop_EM = false
      EM.connect @monitor_server_ip, @advert_select_listening_port, AdvertSelectClient, visit_details, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          EventMachine.run {
            stop_EM = true
            EM.connect @monitor_server_ip, @advert_select_listening_port, AdvertSelectClient, visit_details, logger, stop_EM
          }
        else
          logger.an_event.error "not sent advert select of visit #{visit_details[:id_visit]} to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent advert select of visit #{visit_details[:id_visit]}to monitoring server : #{e.message}"
    end
  end

  def send_return_code(return_code, visit_details, logger)
    begin

      load_parameter()
      stop_EM = false
      EM.connect @monitor_server_ip, @return_code_listening_port, ReturnCodeClient, return_code, visit_details, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          EventMachine.run {
            stop_EM = true
            EM.connect @monitor_server_ip, @return_code_listening_port, ReturnCodeClient, return_code, visit_details, logger, stop_EM
          }
        else
          logger.an_event.error "not sent success code to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent return code  and details of visit #{visit_details[:id_visit]} to monitoring server : #{e.message}"
    end
  end

  def send_success(visit_details, logger)
    send_return_code(Errors::Error.new(0), visit_details, logger)
  end

  def send_failure(return_code, visit_details, logger)
    send_return_code(return_code, visit_details, logger)
  end


  def send_visit_out_of_time (pattern, logger)
    begin
      load_parameter()
      # par defaut on considere que EM est déjà actif => stop_EM = false
      # cas d'usage  : visitor_factory_server ; il ne faut pas stoper la boucle EM avec EM.stop localisé dans unbind (ci-dessus)
      stop_EM = false
      EM.connect @monitor_server_ip, @visit_out_of_time_listening_port, VisitOutOfTimeClient, pattern, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          # EM n'est pas actif ; une exception a été levée alors on lance EM => stop_EM = true
          # cas d'usage : visitor_bot ; il faut arrter la boucle EM au moyen del 'EM.stop localisé dans unbind(ci-dessus)
          EM.run {
            stop_EM = true
            EM.connect @monitor_server_ip, @visit_out_of_time_listening_port, VisitOutOfTimeClient, pattern, logger, stop_EM
          }
        else
          logger.an_event.error "not sent visit out of time #{pattern} to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent visit out of time #{pattern}to monitoring server : #{e.message}"

    end
  end

  def send_pool_size(pool_size, logger)
    begin
      load_parameter()
      # par defaut on considere que EM est déjà actif => stop_EM = false
      # cas d'usage  : visitor_factory_server ; il ne faut pas stoper la boucle EM avec EM.stop localisé dans unbind (ci-dessus)
      stop_EM = false
      EM.connect @monitor_server_ip, @pool_size_listening_port, PoolSizeClient, pool_size, logger, stop_EM

    rescue RuntimeError => e
      case e.message
        # la mahcine EM n'est pas démarrée
        when "eventmachine not initialized: evma_connect_to_server"
          # EM n'est pas actif ; une exception a été levée alors on lance EM => stop_EM = true
          # cas d'usage : visitor_bot ; il faut arrter la boucle EM au moyen del 'EM.stop localisé dans unbind(ci-dessus)
          EM.run {
            stop_EM = true
            EM.connect @monitor_server_ip, @pool_size_listening_port, PoolSizeClient, pool_size, logger, stop_EM
          }
        else
          logger.an_event.error "not sent pool size to monitoring server : #{e.message}"
      end
    rescue Exception => e
      logger.an_event.error "not sent pool size to monitoring server : #{e.message}"

    end
  end



  def change_state_visit(visit_id, state)


    begin
      load_parameter()

      response = RestClient.patch "http://#{@statupweb_server_ip}:#{@statupweb_server_port}/visits/#{visit_id}",
                                  JSON.generate({:state => state}),
                                  :content_type => :json,
                                  :accept => :json
      raise response.content if response.code != 201

    rescue Exception => e
      raise "cannot change  state to #{state} of visit #{visit_id} (#{@statupweb_server_ip}:#{@statupweb_server_port}) => #{e.message}"

    else

    ensure

    end
  end

  private


  def load_parameter
    begin
      parameters = Parameter.new("monitoring_server.rb")
    rescue Exception => e
      raise "cannot load parameter #{e.message}"
    else
      $staging = parameters.environment
      $debugging = parameters.debugging
      @monitor_server_ip = parameters.monitor_server_ip
      @return_code_listening_port = parameters.return_code_listening_port
      @pool_size_listening_port = parameters.pool_size_listening_port
      @visit_out_of_time_listening_port = parameters.visit_out_of_time_listening_port
      @http_server_listening_port = parameters.http_server_listening_port
      @advert_select_listening_port = parameters.advert_select_listening_port
      @statupweb_server_ip = parameters.statupweb_server_ip
      @statupweb_server_port = parameters.statupweb_server_port
    end

  end


  module_function :send_advert_select
  module_function :send_return_code
  module_function :send_failure
  module_function :send_success
  module_function :send_pool_size
  module_function :send_visit_out_of_time
  module_function :change_state_visit
  module_function :load_parameter


end