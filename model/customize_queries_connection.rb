require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative '../lib/logging'
require_relative 'custom_gif_request/custom_gif_request'


require 'em-http-server'
require 'em-http-request'
module CustomizeQueries
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/customize_queries_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  @@logger = nil
  attr_reader :visitor_listening_port, :page_listening_port,
              :proxy_listening_port

  @@sem_visitors = Mutex.new
  @@sem_pages = Mutex.new
  @@visitors = {}
  @@pages = {}
  $staging = "production"
  $debugging = false
  class HTTPHandler < EM::HttpServer::Server
    class HTTPHandlerException < StandardError
    end
    attr :logger

    def process_http_request
      @@logger.an_event.info "visitor #{@http[:user_agent]} browse #{@http_request_uri}}"
      @@logger.an_event.debug @http
      @@logger.an_event.debug @http_request_uri
      custom_gif_request = nil
      begin
        custom_gif_request = @@visitors[@http[:user_agent]]
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@http[:user_agent]} is unknown in repository"
      end
      @@logger.an_event.debug "custom_gif_request : #{custom_gif_request}"
      begin
        case @http[:host]
          when "www.google-analytics.com"
            custom_gif_request.relay_to(@http_request_uri, @http)

          when "safebrowsing.clients.google.com"

          else
            header = custom_gif_request.header.customize(@http)
            relay_direct(@http_request_uri, header)
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@http[:user_agent]} cannot send query to #{@http_request_uri}"
      end
    end

    def relay_direct(query, header)
      @@logger.an_event.debug query
      @@logger.an_event.debug header
      http = EM::HttpRequest.new(query).get :redirects => 5, :head => header
      http.callback {
        response = EM::DelegatedHttpResponse.new(self)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
      http.errback {
        @@logger.an_event.debug "#{http.error}/#{http.response}"
        #raise  HTTPHandlerException, query
      }
    end
  end

  class VisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @logger = logger
    end

    def receive_object(custom_gif_request)
      @logger.an_event.info "add custom gif request of visitor #{custom_gif_request.visitor_id} to repository"
      @logger.an_event.debug custom_gif_request
      @@sem_visitors.synchronize {
        @@visitors[custom_gif_request.visitor_id] = custom_gif_request
      }
    end
  end
  class PageConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @logger = logger
    end

    def receive_object(obj)
      obj.display
    end
  end
  class ClientVisitor < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor

    def initialize(obj)
      @visitor = obj
    end

    def obj
      obj
    end

    def receive_object(visitor)
      @visitor = visitor
      @visitor.display
      close_connection
    end

    def post_init
      send_object @visitor
    end
  end
  class ClientPage < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    #TODO en pricnipe pas besoin de cette connexion, visitor devrait etre suffisant.
    def initialize(obj)
      @obj = obj
    end

    def receive_object(obj)
      obj.display

      close_connection
    end

    def post_init
      send_object @obj
    end


  end


  def send_visitor_properties(obj)
    load_parameter()
    EM.connect "localhost", @visitor_listening_port, ClientVisitor, obj
  end

  def send_page_properties(obj)
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    load_parameter()
    EM.connect "localhost", @page_listening_port, ClientPage, obj
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
      @visitor_listening_port = params[$staging]["visitor_listening_port"] unless params[$staging]["visitor_listening_port"].nil?
      @page_listening_port = params[$staging]["page_listening_port"] unless params[$staging]["page_listening_port"].nil?
      @proxy_listening_port = params[$staging]["proxy_listening_port"] unless params[$staging]["proxy_listening_port"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  module_function :send_visitor_properties
  module_function :send_page_properties
  module_function :load_parameter
end
