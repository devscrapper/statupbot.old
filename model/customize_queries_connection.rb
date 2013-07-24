require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative '../lib/logging'
require_relative 'custom_gif_request/custom_gif_request'
require_relative 'referer/referer'
require 'em-http-server'
require 'em-http-request'
module CustomizeQueries
  class CustomizeQueriesException < StandardError
  end
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/customize_queries_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  @@logger = nil
  attr_reader :add_customgif_listening_port, :delete_customgif_listening_port,
              :proxy_listening_port

  @@sem_visitors = Mutex.new

  @@visitors = {}
  $staging = "production"
  $debugging = false
  class HTTPHandler < EM::HttpServer::Server

    attr :logger

    def process_http_request
      @@logger.an_event.debug "aim host : #{@http[:host]}"
      @@logger.an_event.debug "uri : #{@http_request_uri}"
      @@logger.an_event.debug "user agent : #{@http[:user_agent]}"


      if !@@visitors.has_key?(@http[:user_agent])
        @@logger.an_event.warn "visitor #{@http[:user_agent]} is unknown in repository"
        @@logger.an_event.debug @@visitors
        relay_direct(@http_request_uri, @http)
      else
        custom_gif_request = @@visitors[@http[:user_agent]]
        @@logger.an_event.debug "custom gif request : #{custom_gif_request.to_s}"

        case @http[:host]
          when "www.google-analytics.com"
            custom_gif_request.relay_to(@http_request_uri, @http_query_string, @http, self, @@logger)
          when "safebrowsing.clients.google.com"
          else
            header = custom_gif_request.header.customize(@http)
            relay_direct(@http_request_uri, header)
        end
      end
    end

    def relay_direct(query, header)
      @@logger.an_event.debug "query : #{query}"
      @@logger.an_event.debug "header : #{header}"
      #header.delete(:accept)
      #header["Accept"] = "text/html"
      p "query : #{query}"
      p "hedaer : #{header}"

      #http = EM::HttpRequest.new(query).get :redirects => 5, :head => header
      http = EM::HttpRequest.new("http://localhost:8080/my_portable_files/index.html").get :redirects => 5, :head => header, :connect_timeout => 30
      http.callback {
        p "ok"
        @@logger.an_event.info "visitor #{header["User-Agent"]} browse #{query}"
        response = EM::DelegatedHttpResponse.new(self)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
      http.errback {
        p "ko"
        @@logger.an_event.debug "#{http.error}/#{http.response}"
        @@logger.an_event.error "visitor #{header["User-Agent"]} cannot browse #{query}"
        response = EM::DelegatedHttpResponse.new(self)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
    end
  end

  class AddCustomGifConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @logger = logger
    end

    def receive_object(custom_gif_request)
      @logger.an_event.debug custom_gif_request
      @@sem_visitors.synchronize {
        @@visitors[custom_gif_request.visitor_id] = custom_gif_request
      }
      @logger.an_event.info "add custom gif request of visitor #{custom_gif_request.visitor_id} to repository"
      close_connection
    end
  end
  class DeleteCustomGifConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @logger = logger
    end

    def receive_object(visitor_id)
      @logger.an_event.debug visitor_id
      @@sem_visitors.synchronize {
        @@visitors.delete(visitor_id) { |v| @logger.an_event.info "delete custom gif request of visitor #{v} from repository" }
      }

      close_connection
    end
  end
  class AddCustomGifClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :custom_gif

    def initialize(custom_gif)
      @custom_gif = custom_gif
    end

    def post_init
      send_object @custom_gif
    end
  end

  class DeleteCustomGifClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :custom_gif

    def initialize(custom_gif)
      @custom_gif = custom_gif
    end

    def post_init
      send_object @custom_gif
    end
  end

  def add_custom_gif(custom_gif)
    load_parameter()
    EM.connect "localhost", @add_customgif_listening_port, AddCustomGifClient, custom_gif
  end

  def delete_custom_gif(visitor_id)
    load_parameter()
    EM.connect "localhost", @delete_customgif_listening_port, DeleteCustomGifClient, visitor_id
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
      @add_customgif_listening_port = params[$staging]["add_customgif_listening_port"] unless params[$staging]["add_customgif_listening_port"].nil?
      @delete_customgif_listening_port = params[$staging]["delete_customgif_listening_port"] unless params[$staging]["delete_customgif_listening_port"].nil?
      @proxy_listening_port = params[$staging]["proxy_listening_port"] unless params[$staging]["proxy_listening_port"].nil?
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  module_function :add_custom_gif
  module_function :delete_custom_gif
  module_function :load_parameter
end
