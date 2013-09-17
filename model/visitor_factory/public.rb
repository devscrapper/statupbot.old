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
  attr_reader :assign_new_visitor_listening_port,
               :assign_return_visitor_listening_port,
               :unassign_visitor_listening_port,
               :return_visitors_listening_port,
               :browse_url_listening_port,
               :click_url_listening_port,
               :search_url_listening_port,
               :firefox_path,
               :home, #détermine si on est à la maison ou au bouloit pour utiliser le bon geolocation
               :debug_outbound_queries #determine si on envoie les requetes googleanalytics vers FakeProxy pour débugger ou directement (usage au boulot, Home alors utilise mitmproxy)

  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_details
    attr :logger

    def initialize(visitor_details, logger)
      @visitor_details = visitor_details
      @logger = logger
    end

    def post_init
      send_object @visitor_details
      close_connection_after_writing
      @logger.an_event.info "assignement of visitor #{@visitor_details[:id]} is asked to VisitorFactory"
    end

  end
  class AssignReturnVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_details
    attr :q, :logger

    def initialize(visitor_details, q, logger)
      @q = q
      @visitor_details = visitor_details
      @logger = logger
    end

    def receive_object(visitor_id)
      @q.push visitor_id
      close_connection
    end

    def post_init
      send_object @visitor_details
      @logger.an_event.info "assignement of a return visitor is asked to VisitorFactory"
    end

  end

  class UnAssignVisitorClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :visitor_id, :logger


    def initialize(visitor_id, logger)
      @visitor_id = visitor_id
      @logger = logger
    end

    def post_init
      send_object @visitor_id
      close_connection_after_writing
      @logger.an_event.info "unassignement of visitor #{@visitor_id} is asked to VisitorFactory"
    end
  end
  class BrowseUrlClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_id, :url
    attr :logger


    def initialize(visitor_id, url, logger)
      @visitor_id = visitor_id
      @url = url
      @logger = logger
    end

    def post_init
      send_object({"visitor_id" => @visitor_id, "url" => @url})
      close_connection_after_writing
      @logger.an_event.info "browse of #{@url} by visitor #{@visitor_id} is asked to VisitorFactory"
    end
  end

  class ClickUrlClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_id, :url
    attr :logger


    def initialize(visitor_id, url, logger)
      @visitor_id = visitor_id
      @url = url
      @logger = logger
    end

    def post_init
      send_object({"visitor_id" => @visitor_id, "url" => @url})
      close_connection_after_writing
      @logger.an_event.info "click on #{@url} by visitor #{@visitor_id} is asked to VisitorFactory"
    end
  end
  class SearchUrlClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :visitor_id, :url_search_engine, :landing_page, :keywords, :sleeping_time, :count_max_page
    attr :logger

    def initialize(visitor_id, search_engine, landing_page_url, keywords, sleeping_time, count_max_page, logger)
      @visitor_id = visitor_id
      @search_engine = search_engine
      @landing_page_url = landing_page_url
      @keywords = keywords
      @sleeping_time = sleeping_time
      @count_max_page = count_max_page
      @logger = logger
    end

    def post_init
      send_object({"visitor_id" => @visitor_id,
                   "search_engine" => @search_engine,
                   "landing_page_url" => @landing_page_url,
                   "keywords" => @keywords,
                   "sleeping_time" => @sleeping_time,
                   "count_max_page" => @count_max_page})
      close_connection_after_writing
      @logger.an_event.info "search of #{@keywords} by visitor #{@visitor_id} on search engine #{@search_engine} is asked to VisitorFactory"
    end
  end
  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION
  #--------------------------------------------------------------------------------------------------------------------
  def assign_new_visitor(visitor_details, logger)
    begin
      load_parameter()
      EM.connect "localhost", @assign_new_visitor_listening_port, AssignNewVisitorClient, visitor_details, logger
    rescue Exception => e
      logger.an_event.debug e
    end
  end

  def assign_return_visitor(visitor_details, logger)
    begin
      load_parameter()
      q = EM::Queue.new
      EM.connect "localhost", @assign_return_visitor_listening_port, AssignReturnVisitorClient, visitor_details, q, logger
      q
    rescue Exception => e
      @@logger.an_event.debug e
    end
  end

  def browse_url(visitor_id, url, logger)
    begin
      load_parameter()
      EM.connect "localhost", @browse_url_listening_port, BrowseUrlClient, visitor_id, url, logger
    rescue Exception => e
      @@logger.an_event.debug e
    end
  end

  def click_url(visitor_id, url, logger)
    begin
      load_parameter()
      EM.connect "localhost", @click_url_listening_port, ClickUrlClient, visitor_id, url, logger
    rescue Exception => e
      @@logger.an_event.debug e
    end
  end

  #def return_visitors()
  #  load_parameter()
  #  q = EM::Queue.new
  #  EM.connect "localhost", @return_visitors_listening_port, ReturnVisitorsClient, q
  #  q
  #end

  def search_url(visitor_id, search_engine, landing_page_url, keywords, sleeping_time, count_max_page, logger)
    begin
      load_parameter()
      EM.connect "localhost", @search_url_listening_port, SearchUrlClient, visitor_id, search_engine, landing_page_url, keywords, sleeping_time, count_max_page, logger
    rescue Exception => e
      @@logger.an_event.debug e
    end
  end

  def unassign_visitor(visitor_id, logger)
    begin
      load_parameter()
      EM.connect "localhost", @unassign_visitor_listening_port, UnAssignVisitorClient, visitor_id, logger
    rescue Exception => e
      @@logger.an_event.debug e
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
      @unassign_visitor_listening_port = params[$staging]["unassign_visitor_listening_port"] unless params[$staging]["unassign_visitor_listening_port"].nil?
      @assign_new_visitor_listening_port = params[$staging]["assign_new_visitor_listening_port"] unless params[$staging]["assign_new_visitor_listening_port"].nil?
      @assign_return_visitor_listening_port = params[$staging]["assign_return_visitor_listening_port"] unless params[$staging]["assign_return_visitor_listening_port"].nil?
      @return_visitors_listening_port = params[$staging]["return_visitors_listening_port"] unless params[$staging]["return_visitors_listening_port"].nil?
      @browse_url_listening_port = params[$staging]["browse_url_listening_port"] unless params[$staging]["browse_url_listening_port"].nil?
      @click_url_listening_port = params[$staging]["click_url_listening_port"] unless params[$staging]["click_url_listening_port"].nil?
      @search_url_listening_port = params[$staging]["search_url_listening_port"] unless params[$staging]["search_url_listening_port"].nil?
      @firefox_path = params[$staging]["firefox_path"] unless params[$staging]["firefox_path"].nil?
      @home = params[$staging]["home"] unless params[$staging]["home"].nil?
      @debug_outbound_queries = params[$staging]["debug_outbound_queries"] unless params[$staging]["debug_outbound_queries"].nil?

      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end


#  module_function :return_visitors
  module_function :assign_new_visitor
  module_function :assign_return_visitor
  module_function :unassign_visitor
  module_function :load_parameter
  module_function :browse_url
  module_function :click_url
  module_function :search_url

end