require 'rubygems' # if you use RubyGems
require 'eventmachine'


module VisitFactory
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../../parameter/visit_factory_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../../parameter/environment.yml"

  attr_reader :listening_port
  $staging = "production"
  $debugging = false

  class Client < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(obj)
      @obj = obj
    end

    def post_init
      send_object @obj
    end

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


  #--------------------------------------------------------------------------------------------------------------------
  # functions publiques
  #--------------------------------------------------------------------------------------------------------------------
  def plan(visits_details)
    load_parameter()
    EM.connect "localhost", @listening_port, Client, visits_details
  end

  def plan_force_start_time_visit(visits_details, start_date_time_visit)
    visits_details["start_date_time"] = start_date_time_visit.to_s
     plan(visits_details)
  end
  module_function :plan
  module_function :plan_force_start_time_visit
  module_function :load_parameter
end