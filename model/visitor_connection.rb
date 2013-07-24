require 'rubygems' # if you use RubyGems
require 'eventmachine'
require_relative 'visitor'


module Visitors
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/visitor_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  attr_reader :listening_port

  $staging = "production"
  $debugging = false
  #--------------------------------------------------------------------------------------------------------------------
  # CLASS
  #--------------------------------------------------------------------------------------------------------------------
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class VisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def receive_object(visitor_url)
      close_connection
      visitor = visitor_url["visitor"]
      @logger.an_event.debug visitor.to_s
      url = "http://#{visitor_url["url"]}"
      @logger.an_event.debug url
      begin
        visitor.browser.go url
        @logger.an_event.info "visitor #{visitor.id} browse #{url} with browser #{visitor.browser.id} and webdriver #{visitor.browser.webdriver} with access #{visitor.geolocation.class}"
      rescue Exception => e
        @logger.an_event.error "visitor #{visitor.id} cannot browse url #{url} with browser #{visitor.browser.id} and webdriver #{visitor.browser.webdriver} with access #{visitor.geolocation.class}"
        @logger.an_event.debug e
      end
    end
  end
  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class VisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor, :url


    def initialize(visitor, url)
      @visitor = visitor
      @url = url
    end

    def post_init
      send_object({"visitor" => @visitor, "url" => @url})
    end
  end

  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------

  def browse_url(visitor, url)
    load_parameter()
    EM.connect "localhost", @listening_port, VisitorClient, visitor, url
  end


  def load_parameter()
    @listening_port = 9240
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


  module_function :browse_url
  module_function :load_parameter
end