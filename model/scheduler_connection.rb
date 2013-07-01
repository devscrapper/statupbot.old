require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require 'rufus-scheduler'
require_relative 'visit'

module Scheduler
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/scheduler_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  @@scheduler = Rufus::Scheduler::start_new
  attr_reader :listening_port
  $staging = "production"
  $debugging = false


  class Connection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :scheduler

    def initialize(logger)
      @logger = logger
    end

    def receive_object(obj)
      close_connection
      @logger.an_event.debug obj
      begin
        if obj.start_date_time > Time.now
          obj.plan(@@scheduler)
          @logger.an_event.info "#{obj.class} #{obj.id} is planed at #{obj.start_date_time}"
        else
          @logger.an_event.warn "#{obj.class} #{obj.id} is not planed, because too old"
        end
      rescue Exception => e
        @logger.an_event.debug e
        @logger.an_event.error "#{obj.class} #{obj.id} is not planed"
      end

    end
  end


  class Client < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(obj)
      @obj = obj
    end

    def post_init
      send_object @obj
    end

  end

  def plan(obj)
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    load_parameter()
     EM.connect "localhost", @listening_port, Client, obj
  end

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

  module_function :plan
  module_function :load_parameter
end