require 'rubygems' # if you use RubyGems
require 'socket'
require 'timeout'
require 'eventmachine'
require_relative 'webdriver'
require_relative 'browser/browser'
require_relative 'browser/chrome'
require_relative 'browser/internet_explorer'
require_relative 'browser/firefox'
require_relative 'browser/safari'


module WebdriverFactory
  #--------------------------------------------------------------------------------------------------------------------
  # INIT
  #--------------------------------------------------------------------------------------------------------------------
  PARAMETERS = File.dirname(__FILE__) + "/../parameter/webdriver_factory_server.yml"
  ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
  DIR_LOG = File.dirname(__FILE__) + "/../log"
  DIR_COOKIES = File.dirname(__FILE__) + "/../cookies"
  @@proxy_listening_port = 9230
  @@free_webdrivers = []
  @@busy_webdrivers = {}
  @@sem_webdrivers = Mutex.new
  @@next_port = @start_phantomjs_port
  @@sem_next_port = Mutex.new
  attr_reader :assign_browser_listening_port,
              :unassign_browser_listening_port,
              :host_phantomjs,
              :start_phantomjs_port,
              :free_browsers_listening_port,
              :busy_browsers_listening_port

  $staging = "production"
  $debugging = false
  #--------------------------------------------------------------------------------------------------------------------
  # CLASS
  #--------------------------------------------------------------------------------------------------------------------
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignBrowserConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
      @host_phantomjs = "localhost"
    end

    def receive_object(browser)
      browser.display
      browser.webdriver = rents_browser(browser)
      @logger.an_event.info "assign webdriver #{browser.webdriver.port} to browser #{browser.id}"
      send_object browser
    end
  end
  class FreeBrowsersConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def post_init()
      @logger.an_event.info "send repository free browsers(#{@@free_webdrivers.size})"
      send_object @@free_webdrivers
    end
  end
  class BusyBrowsersConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def post_init()
      @logger.an_event.info "send repository busy browsers(#{@@busy_webdrivers.size})"
      send_object @@busy_webdrivers
    end
  end
  class UnAssignBrowserConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @logger = logger
    end

    def receive_object(browser)
      frees_browser(browser)
      close_connection
    end
  end
  #--------------------------------------------------------------------------------------------------------------------
  # CLIENT
  #--------------------------------------------------------------------------------------------------------------------
  class AssignBrowserClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :browser
    attr :q

    def initialize(browser, q)
      @browser = browser
      @q = q
    end

    def receive_object(browser)
      @q.push browser
      close_connection
    end

    def post_init
      send_object @browser
    end
  end
  class FreeBrowsersClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :q

    def initialize(q)
      @q = q
    end

    def receive_object(free_browsers)
      @q.push free_browsers
      close_connection
    end
  end
  class BusyBrowsersClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr :q

    def initialize(q)
      @q = q
    end

    def receive_object(busy_browsers)
      @q.push busy_browsers
      close_connection
    end
  end
  class UnAssignBrowserClient < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    attr_accessor :browser

    def initialize(browser)
      @browser = browser
    end

    def post_init
      send_object @browser
    end
  end
  #--------------------------------------------------------------------------------------------------------------------
  # MODULE FUNCTION                                           --proxy=\"127.0.0.1:9230\"
  #--------------------------------------------------------------------------------------------------------------------
  def frees_browser(browser)
    @@sem_webdrivers.synchronize {
      @@free_webdrivers << browser.webdriver
      @@busy_webdrivers.delete(browser.webdriver.port)
    }
    p "free webdriver : #{@@free_webdrivers}"
    p "busy webdriver : #{@@busy_webdrivers}"
  end

  def rents_browser(browser)
    @@sem_webdrivers.synchronize {
      webdriver = nil
      if @@free_webdrivers.empty?
        port = chose_port()
        @logger.an_event.debug  @@proxy_listening_port
        @logger.an_event.debug "d:\\phantomjs\\phantomjs                                                     \
                                  --cookies-file=#{DIR_COOKIES}/cookies_#{port}.txt                         \
                                  --debug=#{$debugging}                                                     \
                                  --webdriver=127.0.0.1:#{port}                                             \
                                  --webdriver-logfile=#{DIR_LOG}/phantomjs_#{port}.txt                      \
                                  --webdriver-loglevel=DEBUG --proxy=127.0.0.1:#{@@proxy_listening_port} \
                                  --proxy-type=http"
        pid = Process.spawn("d:\\phantomjs\\phantomjs                                               \
                          --cookies-file=#{DIR_COOKIES}/cookies_#{port}.txt                         \
                          --debug=#{$debugging}                                                     \
                          --webdriver=127.0.0.1:#{port}                                             \
                          --webdriver-logfile=#{DIR_LOG}/phantomjs_#{port}.txt                      \
                          --webdriver-loglevel=DEBUG --proxy=127.0.0.1:#{@@proxy_listening_port}    \
                          --proxy-type=http")
        webdriver = Webdriver.new(@host_phantomjs, port, browser.visitor_id, pid)
      else
        webdriver = @@free_webdrivers.shift
      end
      @@busy_webdrivers[webdriver.port] = webdriver
      p "free webdriver : #{@@free_webdrivers}"
      p "busy webdriver : #{@@busy_webdrivers}"
      webdriver
    }
  end

  def assign_browser(browser, q)
    load_parameter()
    EM.connect "localhost", @assign_browser_listening_port, AssignBrowserClient, browser, q
  end

  def unassign_browser(browser)
    p "unassign browser #{browser.id}"
    load_parameter()
    EM.connect "localhost", @unassign_browser_listening_port, UnAssignBrowserClient, browser
  end

  def free_browsers()
    load_parameter()
    q = EM::Queue.new
    EM.connect "localhost", @free_browsers_listening_port, FreeBrowsersClient, q
    q
  end

  def busy_browsers()
    load_parameter()
    q = EM::Queue.new
    EM.connect "localhost", @busy_browsers_listening_port, BusyBrowsersClient, q
    q
  end

  def load_parameter()
    @listening_port = 9203 # port d'ecoute
    @start_phantomjs_port = 8910 #debut de la plage des ports d'ecoute phantomjs
    @free_browsers_listening_port = 9222
    @busy_browsers_listening_port = 9223
    begin
      environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
      $staging = environment["staging"] unless environment["staging"].nil?
    rescue Exception => e
      STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
    end

    begin
      params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
      @unassign_browser_listening_port = params[$staging]["unassign_browser_listening_port"] unless params[$staging]["unassign_browser_listening_port"].nil?
      @assign_browser_listening_port = params[$staging]["assign_browser_listening_port"] unless params[$staging]["assign_browser_listening_port"].nil?
      @start_phantomjs_port = params[$staging]["start_phantomjs_port"] unless params[$staging]["start_phantomjs_port"].nil?
      @@proxy_listening_port = params[$staging]["proxy_listening_port"] unless params[$staging]["proxy_listening_port"].nil?
      @free_browsers_listening_port = params[$staging]["free_browsers_listening_port"] unless params[$staging]["free_browsers_listening_port"].nil?
      @busy_browsers_listening_port = params[$staging]["busy_browsers_listening_port"] unless params[$staging]["busy_browsers_listening_port"].nil?
      @@next_port = @start_phantomjs_port
      $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
    rescue Exception => e
      STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
    end
  end

  def chose_port()
    @@sem_next_port.synchronize {
      @@next_port += 1 while port_open?("localhost", @@next_port, 3)
    }
    @@next_port
  end

  def port_open?(ip, port, seconds=1)
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def stop_phantomjs()
    #pas nécessaire car quand on arreter le serveur webdriver_factory, toutes les instances de phantomjs s'arretent
    for webdriver in @@free_webdrivers
      begin
        pid = webdriver.pid
        p "kill #{pid}"
        Process.kill("KILL", pid)
      rescue Exception => e
        p e
        p e.backtrace
      end
    end
    for webdriver in @@busy_webdrivers
      begin
        pid = webdriver.pid
        p "kill #{pid}"
        Process.kill("KILL", pid)
      rescue Exception => e
        p e
        p e.backtrace
      end
    end
  end

  def proxy_listening_port
    @@proxy_listening_port
  end
  module_function :proxy_listening_port
  module_function :free_browsers
  module_function :busy_browsers
  module_function :stop_phantomjs
  module_function :port_open?
  module_function :chose_port
  module_function :rents_browser
  module_function :frees_browser
  module_function :assign_browser
  module_function :unassign_browser
  module_function :load_parameter
end