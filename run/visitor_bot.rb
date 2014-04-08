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
#          --slave, -s <s>:   Visitor
#                             is slave
#                             of
#                             Visitor
#                             Factory
#                             (yes/no)
#                             (default:
#                             no)
#        --sandbox, -a <s>:   browser is sandboxed (yes/no) (default: no)
#--multi-instance-proxy-compatible, -m <s>:   browser
#                             is multi
#                             instance
#                             compatible
#                             (yes/no)
#                             (default:
#                             no)
#--listening-port-visitor-factory, -l <i>:   Listening port of Visitor Factory (default: 9220)
# --listening-port, -i <i>:   Listening port of Visitor Bot (default: 9800)
#--listening-port-sahi-proxy, -t <i>:   Listening port of Sahi proxy (default: 9999)
#     --proxy-type, -p <s>:   Type of geolocation
#                             proxy use
#                             (none|http|https|socks)
#                             (default:
#                             none)
#       --proxy-ip, -r <s>:   @ip of geolocation proxy
#     --proxy-port, -o <i>:   Port of geolocation proxy
#     --proxy-user, -x <s>:   Identified user of geolocation proxy
#      --proxy-pwd, -y <s>:   Authentified pwd of geolocation proxy
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#--[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#            --version, -e:   Print version and exit
#               --help, -h:   Show this message
#--help, -h:   Show this message
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
  opt :sandbox, "browser is sandboxed (yes/no)", :type => :string, :default => "no"
  opt :multi_instance_proxy_compatible, "browser is multi instance compatible (yes/no)", :type => :string, :default => "no"
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


VISITOR_NOT_LOADED_VISIT_FILE = 1
VISITOR_NOT_BUILT_VISIT = 2
VISITOR_IS_NOT_BORN = 10
VISITOR_IS_NOT_BORN_CONFIG_ERROR = 11
VISITOR_IS_NOT_BORN_TECHNICAL_ERROR = 12
VISITOR_NOT_OPEN_BROWSER = 20
VISITOR_NOT_EXECUTE_VISIT = 30
VISITOR_NOT_FOUND_LANDING_PAGE = 31
VISITOR_NOT_SURF_COMPLETLY = 32
VISITOR_NOT_CLOSE_BROWSER = 40
VISITOR_NOT_DIE = 50
VISITOR_NOT_CLOSE_BROWSER_AND_NOT_DIE = 60
OK = 0
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

def visitor_load_visit_file(file_path)
  begin
    visit_file = File.open(file_path, "r:BOM|UTF-8:-")
    visit_details = YAML::load(visit_file.read)
    visit_file.close
    @@logger.an_event.info "visit file #{file_path} is loaded"
    [OK, visit_details]
  rescue Exception => e
    @@logger.an_event.debug e
    @@logger.an_event.error "visit file #{file_path} is not loaded"
    [VISITOR_NOT_LOADED_VISIT_FILE, nil]
  end
end

def visitor_build_visit(visit_details)
  visit = nil
  begin
    visit = Visit.new(visit_details)
    @@logger.an_event.debug visit.to_yaml
    @@logger.an_event.info "visitor built visit #{visit_details[:id_visit]}"
    [OK, visit]
  rescue Exception => e
    @@logger.an_event.debug e
    @@logger.an_event.error "visitor not built visit #{visit_details[:id_visit]}"
    #TODO delete visit file in tmp directory
    [VISITOR_NOT_BUILT_VISIT, nil]
  end

end

def visitor_born(visitor_details,
    exist_pub_in_visit,
    listening_port_sahi_proxy = nil, proxy_ip=nil, proxy_port=nil, proxy_user=nil, proxy_pwd=nil)
  visitor = nil
  begin
    visitor = Visitor.build(visitor_details, exist_pub_in_visit,
                            listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd)
    @@logger.an_event.debug visitor.to_yaml

    [OK, visitor]
  rescue Visitors::FunctionalError => e
    @@logger.an_event.error "visitor #{visitor_details[:id]}  is not born, config is mistaken"
    [VISITOR_IS_NOT_BORN_CONFIG_ERROR, nil]

  rescue Visitors::FunctionalError => e
      @@logger.an_event.error "visitor #{visitor_details[:id]}  is not born, technical error"

    [VISITOR_IS_NOT_BORN_TECHNICAL_ERROR, nil]
  end
end

def visitor_open_browser(visitor)
  begin
    visitor.open_browser
    OK
  rescue Exception => e
    @@logger.an_event.error e.message
    @@logger.an_event.debug e
    VISITOR_NOT_OPEN_BROWSER
  end
end

def visitor_execute_visit(visitor, visit)
  begin
    @@logger.an_event.info "visitor #{visitor.id} start execution of visit #{visit.id}"
    visitor.execute(visit)
    @@logger.an_event.info "visitor #{visitor.id} terminate execution of visit #{visit.id}"
    #TODO delete visit file in tmp directory
    OK
  rescue Exception => e
    @@logger.an_event.error "visitor #{visitor.id} not execute the visit #{visit.id}"
    @@logger.an_event.debug e
    case e.message
      #erreur fonctionnelle => le menage sera fait par lexcécution naturelle de visitor_bot
      when Visitors::Visitor::VisitorException::NOT_FOUND_LANDING_PAGE
        VISITOR_NOT_FOUND_LANDING_PAGE
      when Visitors::Visitor::VisitorException::CANNOT_CONTINUE_SURF
        VISITOR_NOT_SURF_COMPLETLY
      else
        #erreur technique irrémdiable, le menage a du être fait dans visitor.execute
        VISITOR_NOT_EXECUTE_VISIT
    end

  end


end

def visitor_close_browser(visitor)
  begin
    visitor.close_browser
    OK
  rescue Exception => e

    @@logger.an_event.debug e
    @@logger.an_event.error "visitor #{visitor.id} not close his browser"
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

def visitor_is_no_slave(opts)
  cr, visit_details = visitor_load_visit_file(opts[:visit_file_name])
  return cr unless cr==OK

  context = ["visit=#{visit_details[:id_visit]}"]
  @@logger.ndc context

  cr, visit = visitor_build_visit(visit_details)
  return cr unless cr==OK

  visit_details[:visitor][:browser][:sandbox] = opts[:sandbox] == "yes"
  visit_details[:visitor][:browser][:multi_instance_proxy_compatible] = opts[:multi_instance_proxy_compatible] == "yes"
  cr, visitor = visitor_born(visit_details[:visitor],
                             visit_details[:advert][:advertising] != :none,
                             opts[:listening_port_sahi_proxy],
                             opts[:proxy_ip],
                             opts[:proxy_port],
                             opts[:proxy_user],
                             opts[:proxy_pwd]) if   visit_details[:advert][:advertising] == :none
  return cr unless cr==OK

  cr = visitor_open_browser(visitor)
  return cr unless cr==OK

  #TODO temporaire
  #cr = visitor_execute_visit(visitor, visit)
  cr1 = visitor_close_browser(visitor)
  cr2 = visitor_die(visitor)


  #if cr != VISITOR_NOT_EXECUTE_VISIT
  #  cr1 = visitor_close_browser(visitor)
  #  cr2 = visitor_die(visitor)
  #  cr = VISITOR_NOT_CLOSE_BROWSER_AND_NOT_DIE if cr1 != OK and cr2 != OK
  #  cr = OK if cr1 == OK and cr2 == OK
  #  cr = cr1 if cr1 != OK
  #  cr = cr2 if cr2 != OK
  #end

  return cr
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
state = 0
state = visitor_is_slave(opts) if opts[:slave] == "yes"
state = visitor_is_no_slave(opts) if opts[:slave] == "no"
@@logger.an_event.debug "end execution visitor_bot, with state #{state}"
Process.exit(state)




