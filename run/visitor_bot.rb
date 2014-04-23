require_relative '../model/visitor/visitor'
require_relative '../model/visit/visit'
require_relative '../lib/logging'
require 'uri'
require 'trollop'
require 'eventmachine'
include Visits
include Visitors
#bot which surf on website
#
#Usage:
#       visitor_bot [options]
#where [options] are:
#--visit-file-name, -v <s>:   Path and name of visit file to browse
#            --slave, -s <s>:   Visitor
#                               is slave
#                               of
#                               Visitor
#                               Factory
#                               (yes/no)
#                               (default:
#                               no)
#     --proxy-system, -p <s>:   browser
#                               use
#                               proxy
#                               system
#                               of
#                               windows
#                               (yes/no)
#                               (default:
#                               no)
#--listening-port-visitor-factory, -l <i>:   Listening port of Visitor Factory (default: 9220)
#   --listening-port, -i <i>:   Listening port of Visitor Bot (default: 9800)
#--listening-port-sahi-proxy, -t <i>:   Listening port of Sahi proxy (default: 9999)
#       --proxy-type, -r <s>:   Type of geolocation
#                               proxy use
#                               (none|http|https|socks)
#                               (default:
#                               none)
#         --proxy-ip, -o <s>:   @ip of geolocation proxy
#       --proxy-port, -x <i>:   Port of geolocation proxy
#       --proxy-user, -y <s>:   Identified user of geolocation proxy
#        --proxy-pwd, -w <s>:   Authentified pwd of geolocation proxy
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#              --version, -e:   Print version and exit
#                 --help, -h:   Show this message
# sample :
# Visitor_bot is no slave without geolocation : visitor_bot -v d:\toto\visit.yaml -t 9998
# Visitor_bot is slave : visitor_bot -v d:\toto\visit.yaml -s yes -l 9220 -i 9800

opts = Trollop::options do
  version "test 0.12 (c) 2013 Dave Scrapper"
  banner <<-EOS
bot which surf on website

Usage:
       visitor_bot [options]
where [options] are:
  EOS
  opt :visit_file_name, "Path and name of visit file to browse", :type => :string
  opt :slave, "Visitor is slave of Visitor Factory (yes/no)", :type => :string, :default => "no"
  opt :proxy_system, "browser use proxy system of windows (yes/no)", :type => :string, :default => "no"
  opt :listening_port_visitor_factory, "Listening port of Visitor Factory", :type => :integer, :default => 9220
  opt :listening_port, "Listening port of Visitor Bot", :type => :integer, :default => 9800
  opt :listening_port_sahi_proxy, "Listening port of Sahi proxy", :type => :integer, :default => 9999
  opt :proxy_type, "Type of geolocation proxy use (none|http|https|socks)", :type => :string, :default => "none"
  opt :proxy_ip, "@ip of geolocation proxy", :type => :string
  opt :proxy_port, "Port of geolocation proxy", :type => :integer
  opt :proxy_user, "Identified user of geolocation proxy", :type => :string
  opt :proxy_pwd, "Authentified pwd of geolocation proxy", :type => :string

  #opt depends(:slave, :listening_port, :listening_port_visitor_factory)
  opt depends(:proxy_type, :proxy_ip)
  opt depends(:proxy_type, :proxy_port)
  opt depends(:proxy_user, :proxy_pwd)
end

Trollop::die :visit_file_name, "is require" if opts[:visit_file_name].nil?
Trollop::die :visit_file_name, ": <#{opts[:visit_file_name]}> is not valid, or not find" unless File.file?(opts[:visit_file_name])
Trollop::die :proxy_ip, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_ip].nil?
Trollop::die :proxy_port, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_port].nil?

class VisitException < StandardError

end

VISIT_NOT_BUILT = 10
VISIT_FILE_NOT_LOADED = 11
VISIT_MEDIUM_REFERER_UNKNOWN = 12
VISIT_ENGINE_REFERER_UNKNOWN = 13
VISIT_BAD_PROPERTIES = 14
VISITOR_IS_NOT_BORN = 20
VISITOR_IS_NOT_BORN_CONFIG_ERROR = 21
VISITOR_IS_NOT_BORN_TECHNICAL_ERROR = 22
VISITOR_NOT_OPEN_BROWSER = 30
VISITOR_NOT_EXECUTE_VISIT = 40
REFERRER_NOT_DISPLAY_START_PAGE = 41
REFERRER_NOT_FOUND_LANDING_PAGE = 42
REFERRAL_NOT_FOUND_LANDING_LINK = 43
SEARCH_NOT_FOUND_LANDING_LINK = 44
VISITOR_NOT_CLOSE_BROWSER = 50
VISITOR_NOT_DIE = 60
VISITOR_NOT_INHUME = 70
OK = 0
=begin
class Connection < EventMachine::Connection
  include EM::Protocols::ObjectProtocol

  attr :visitor, :opts

  def initialize(opts, visitor)
    @visitor = visitor
    @opts = opts
  end

  def receive_object(visit_details)
    close_connection
    visit = build_visit(visit_details)
    @visitor.execute(visit)
  end
end
class Client < EventMachine::Connection
  include EM::Protocols::ObjectProtocol
  attr_accessor :visit_details
  attr :logger

  def initialize(visit_details)
    begin
      @visitor_details = visit_details

    rescue Exception => e
      p e.message
    end
  end

  def post_init
    begin
      send_object @visit_details
    rescue Exception => e
      p e.message
    end
  end

end

def build_visit(visit_details)
  visit = nil
  begin
    visit = Visit.new(visit_details)
    @@logger.an_event.debug visit.to_yaml
  rescue Exception => e
    @@logger.an_event.error "building visit #{visit_details[:id_visit]} failed"
    @@logger.an_event.error e.message
    raise VisitException, e.message
  end
  visit
end


def build_visitor(visitor_details,
    exist_pub_in_visit,
    listening_port_sahi_proxy = nil, proxy_ip=nil, proxy_port=nil, proxy_user=nil, proxy_pwd=nil)
  visitor = nil
  begin
    visitor = Visitor.build(visitor_details, exist_pub_in_visit,
                            listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd)
    @@logger.an_event.debug visitor.to_yaml
  rescue Exception => e
    @@logger.an_event.error "building visitor of visit #{visit_details[:id_visit]} failed"
    @@logger.an_event.debug e.message
    raise VisitorException, e.message
  end
  visitor
end

def visitor_is_slave(opts)
  visit_details = YAML::load(File.read(opts[:visit_file_name]))
  visitor_details = visit_details[:visitor]
  visitor = build_visitor(visitor_details, visit_details[:advert][:advertising] != :none)
  visitor.open_browser
  EventMachine.run {
    Signal.trap("INT") { EventMachine.stop; }
    Signal.trap("TERM") { EventMachine.stop; }

    EventMachine.start_server "127.0.0.1", opts[:listening_port], Connection, opts, visitor
    EM.connect '127.0.0.1', opts[:listening_port], Client, visit_details
  }
end
=end
def visitor_load_visit_file(file_path)
  begin
    visit_file = File.open(file_path, "r:BOM|UTF-8:-")
    visit_details = YAML::load(visit_file.read)
    visit_file.close
    #File.delete(file_path)
    @@logger.an_event.info "visit file #{file_path} is loaded"
    [OK, visit_details]
  rescue Exception => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visit file #{file_path} is not loaded"
    [VISIT_FILE_NOT_LOADED, nil]
  end
end

def visitor_build_visit(visit_details)
  visit = nil
  @@logger.an_event.debug "visit details #{visit_details}"
  begin
    visit = Visit.new(visit_details)

    [OK, visit]
  rescue Visits::FunctionalError => e
    @@logger.an_event.debug e.message
    case e.message
      when Referrer::MEDIUM_UNKNOWN
        [VISIT_MEDIUM_REFERER_UNKNOWN, nil]
      when EngineSearch::SEARCH_ENGINE_UNKNOWN
        [VISIT_ENGINE_REFERER_UNKNOWN, nil]
      else
        [VISIT_BAD_PROPERTIES, nil]
    end

  rescue Visits::TechnicalError, Exception => e
    @@logger.an_event.debug e.message
    #TODO delete visit file in tmp directory
    [VISIT_NOT_BUILT, nil]
  end

end

def visitor_born(visitor_details)
  visitor = nil
  @@logger.an_event.debug "visitor details #{visitor_details}"
  begin
    visitor = Visitor.build(visitor_details)

    [OK, visitor]
  rescue Visitors::FunctionalError => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visitor #{visitor_details[:id]}  is not born, config is mistaken"
    [VISITOR_IS_NOT_BORN_CONFIG_ERROR, nil]

  rescue Visitors::TechnicalError, Exception => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visitor #{visitor_details[:id]}  is not born, technical error"
    [VISITOR_IS_NOT_BORN_TECHNICAL_ERROR, nil]
  end
end

def visitor_open_browser(visitor)
  @@logger.an_event.debug visitor.to_yaml
  begin
    visitor.open_browser
    OK
  rescue Exception => e
    @@logger.an_event.error "visitor #{visitor.id} not open its browser"
    @@logger.an_event.debug e
    visitor_die(visitor)
    VISITOR_NOT_OPEN_BROWSER
  end
end


def visitor_browse_referrer(visitor, visit)
  landing_page = nil
  begin
    landing_page = visitor.browse(visit.referrer)
    [OK, landing_page]

  rescue Visitors::FunctionalError => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visitor #{@id} not found landing page"
    visitor_close_browser(visitor)
    visitor_die(visitor)
    case e.message
      when Visitor::REFERRER_NOT_DISPLAY_START_PAGE
        [REFERRER_NOT_DISPLAY_START_PAGE, nil]
      when Visitor::REFERRER_NOT_FOUND_LANDING_PAGE
        [REFERRER_NOT_FOUND_LANDING_PAGE, nil]
      when Visitor::REFERRAL_NOT_FOUND_LANDING_LINK
        [REFERRAL_NOT_FOUND_LANDING_LINK, nil]
      when Visitor::SEARCH_NOT_FOUND_LANDING_LINK
        [SEARCH_NOT_FOUND_LANDING_LINK, nil]
    end

  rescue Visitors::TechnicalError, Exception => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visitor #{@id} not found landing page"
    visitor_close_browser(visitor)
    visitor_die(visitor)
    [REFERRER_NOT_FOUND_LANDING_PAGE, nil]
  end
end

def visitor_surf(visitor, visit, landing_page)
  page = nil

  begin
    page = visitor.surf(visit.durations, landing_page, visit.around)
    [OK, page]
  rescue Exception => e
    @@logger.an_event.debug e.message
    @@logger.an_event.error "visitor #{@id} not execute visit"
    visitor_close_browser(visitor)
    visitor_die(visitor)
    [VISITOR_NOT_EXECUTE_VISIT, nil]
  end
end

def visitor_close_browser(visitor)
  begin
    visitor.close_browser
    OK
  rescue Exception => e

    @@logger.an_event.debug e
    @@logger.an_event.error "visitor #{visitor.id} not close his browser"
    visitor_die(visitor)
    VISITOR_NOT_CLOSE_BROWSER
  end
end

def visitor_die(visitor)
  begin
    visitor.die
    OK
  rescue Exception => e

    @@logger.an_event.debug e
    @@logger.an_event.error "visitor #{visitor.id} is not dead"
    VISITOR_NOT_DIE
  end
end

def visitor_inhume(visitor)
  begin
    visitor.inhume
    OK
  rescue Exception => e

    @@logger.an_event.debug e
    @@logger.an_event.error "visitor #{visitor.id} is not inhume"
    VISITOR_NOT_INHUME
  end
end

def visitor_is_no_slave(opts)
  visit = nil
  visitor = nil
  landing_page = nil
  page = nil
  #---------------------------------------------------------------------------------------------------------------------
  # chargement du fichier definissant la visite
  #---------------------------------------------------------------------------------------------------------------------
  cr, visit_details = visitor_load_visit_file(opts[:visit_file_name])
  if cr == OK
    context = ["visit=#{visit_details[:id_visit]}"]
    @@logger.ndc context
    visit_details[:visitor][:browser][:proxy_system] = opts[:proxy_system] == "yes"
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Creation de la visit
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr, visit = visitor_build_visit(visit_details)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Creation du visitor
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    visitor_details = visit_details[:visitor]
    visitor_details[:browser][:listening_port_proxy] = opts[:listening_port_sahi_proxy]
    visitor_details[:browser][:proxy_ip] = opts[:proxy_ip]
    visitor_details[:browser][:proxy_port] = opts[:proxy_port]
    visitor_details[:browser][:proxy_user] = opts[:proxy_user]
    visitor_details[:browser][:proxy_pwd] = opts[:proxy_pwd]

    cr, visitor = visitor_born(visitor_details)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor open browser
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr = visitor_open_browser(visitor)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor browse referrer
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr, landing_page = visitor_browse_referrer(visitor, visit)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor execute visit
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    #TODO meo le surf de la visit
    cr, page = visitor_surf(visitor, visit, landing_page)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor close its browser
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr = visitor_close_browser(visitor)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor die
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr = visitor_die(visitor)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Visitor inhume
  #---------------------------------------------------------------------------------------------------------------------
  if cr == OK
    cr = visitor_inhume(visitor)
  end

  cr
end

PARAMETERS = File.dirname(__FILE__) + "/../parameter/visitor_bot.yml"
ENVIRONMENT= File.dirname(__FILE__) + "/../parameter/environment.yml"
$staging = "production"
$debugging = false

def load_parameter
  begin
    environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
    $staging = environment["staging"] unless environment["staging"].nil?
  rescue Exception => e
    STDERR << "loading parameter file #{ENVIRONMENT} failed : #{e.message}"
  end

  begin
    #TODO parametrer les répertoires contenant des fichiers d'exécution pour un usage avec virtualisation d'OS afin que les OS point sur les même executables
    params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
    @@debug_outbound_queries = params[$staging]["debug_outbound_queries"] unless params[$staging]["debug_outbound_queries"].nil? #geolocation
    @@home = params[$staging]["home"] unless params[$staging]["home"].nil? #geolocation
    @@firefox_path = params[$staging]["firefox_path"] unless params[$staging]["firefox_path"].nil?
    $java_runtime_path = params[$staging]["java_runtime_path"] unless params[$staging]["java_runtime_path"].nil?
    $java_key_tool_path = params[$staging]["java_key_tool_path"] unless params[$staging]["java_key_tool_path"].nil?

    $debugging = params[$staging]["debugging"] unless params[$staging]["debugging"].nil?
  rescue Exception => e
    STDERR << "loading parameters file #{PARAMETERS} failed : #{e.message}"
  end
end

load_parameter
visitor_id = YAML::load(File.read(opts[:visit_file_name]))[:visitor][:id]
@@logger = Logging::Log.new(self, :staging => 'development', :id_file => File.join("#{File.basename(__FILE__, ".rb")}_#{visitor_id}"), :debugging => true)
@@logger.an_event.debug "File Parameters begin------------------------------------------------------------------------------"
@@logger.a_log.info "firefox path : #{@@firefox_path}"
@@logger.a_log.info "java runtime path : #{$java_runtime_path}"
@@logger.a_log.info "java key tool path : #{$java_key_tool_path}"
@@logger.a_log.info "debug outbound queries : #{@@debug_outbound_queries}"
@@logger.a_log.info "home : #{@@home}"
@@logger.a_log.info "debugging : #{$debugging}"
@@logger.a_log.info "staging : #{$staging}"
@@logger.an_event.debug "File Parameters end------------------------------------------------------------------------------"
@@logger.an_event.debug "Start Parameters begin------------------------------------------------------------------------------"
@@logger.an_event.debug opts.to_yaml
@@logger.an_event.debug "Start Parameters end--------------------------------------------------------------------------------"


@@logger.an_event.debug "begin execution visitor_bot"
state = OK
#state = visitor_is_slave(opts) if opts[:slave] == "yes"
state = visitor_is_no_slave(opts) if opts[:slave] == "no"
@@logger.an_event.debug "end execution visitor_bot, with state #{state}"
Process.exit(state)




