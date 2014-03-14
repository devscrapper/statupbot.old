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
#                                                                                                    --visit-file-name, -v <s>:   Path and name of visit file to browse
#                                                                                                              --slave, -s <s>:   Visitor
#                                                                                                                                 is slave
#                                                                                                                                 of
#                                                                                                                                 Visitor
#                                                                                                                                 Factory
#                                                                                                                                 (yes/no)
#                                                                                                                                 (default:
#                                                                                                                                 no)
#                                                                                     --listening-port-visitor-factory, -l <i>:   Listening port of Visitor Factory (default: 9220)
#                                                                                                     --listening-port, -i <i>:   Listening port of Visitor Bot (default: 9800)
#                                                                                          --listening-port-sahi-proxy, -t <i>:   Listening port of Sahi proxy (default: 9999)
#                                                                                                         --proxy-type, -p <s>:   Type of geolocation
#                                                                                                                                 proxy use
#                                                                                                                                 (none|http|https|socks)
#                                                                                                                                 (default:
#                                                                                                                                 none)
#                                                                                                           --proxy-ip, -r <s>:   @ip of geolocation proxy
#                                                                                                         --proxy-port, -o <i>:   Port of geolocation proxy
#                                                                                                         --proxy-user, -x <s>:   Identified user of geolocation proxy
#                                                                                                          --proxy-pwd, -y <s>:   Authentified pwd of geolocation proxy
#  --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#  --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#  --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]], -[:
#                                                                                                                --version, -e:   Print version and exit
#--help, -h:   Show this message
# sample :
# Visitor_bot is no slave without geolocation : visitor_bot -v d:\toto\visit.yaml -t 9998
# Visitor_bot is slave : visitor_bot -v d:\toto\visit.yaml -s yes -l 9220 -i 9800

opts = Trollop::options do
  version "test 0.11 (c) 2013 Dave Scrapper"
  banner <<-EOS
bot which surf on website

Usage:
       visitor_bot [options]
where [options] are:
  EOS
  opt :visit_file_name, "Path and name of visit file to browse", :type => :string
  opt :slave, "Visitor is slave of Visitor Factory (yes/no)", :type => :string, :default => "no"
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

DIR_VISITORS = File.join(File.dirname(__FILE__), '..', '..', 'visitors')
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

def visitor_is_no_slave(opts)
  visitor = nil
  begin
    visit_file = File.open(opts[:visit_file_name], "r:BOM|UTF-8:-")
    visit_details = YAML::load(visit_file.read)
    visit_file.close
    visitor_details = visit_details[:visitor]
    visit = build_visit(visit_details)
    context = ["#{visit_details[:website][:label]}:#{visit.id}"]
    @@logger.ndc context
    if  visit_details[:advert][:advertising] != :none
      visitor = build_visitor(visitor_details,
                              visit_details[:advert][:advertising] != :none)
    else
      #pas de pub dans la visit
      visitor = build_visitor(visitor_details,
                              visit_details[:advert][:advertising] != :none,
                              opts[:listening_port_sahi_proxy],
                              opts[:proxy_ip],
                              opts[:proxy_port],
                              opts[:proxy_user],
                              opts[:proxy_pwd])
    end
    visitor.open_browser
    visitor.execute(visit)
    visitor.close_browser
    visitor.die
    return 0
  rescue Exception => e
    case e.message
      when Visitors::Visitor::VisitorException::CANNOT_DIE
        return 1
      when Visitors::Visitor::VisitorException::CANNOT_CLOSE_BROWSER
        begin
        visitor.die unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot die visitor after cannot close browser : #{e.message}"
          return 1
        end
        return 2
      when Visitors::Visitor::VisitorException::CANNOT_CONTINUE_SURF
        begin
        visitor.close_browser unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot close browser  after cannot continue surf : #{e.message}"
        end
        begin
        visitor.die unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot die visitor after cannot continue surf : #{e.message}"
        end
        return 3
      when Visitors::Visitor::VisitorException::DIE_DIRTY
        return 4
      when Visitors::Visitor::VisitorException::CANNOT_OPEN_BROWSER
        begin
        visitor.die unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot die visitor after cannot open browser : #{e.message}"
        end
        return 5
      when Visitors::Visitor::VisitorException::NOT_FOUND_LANDING_PAGE
        begin
        visitor.close_browser unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot close browser  after not found landing page : #{e.message}"
        end
        begin
        visitor.die unless visitor.nil?
        rescue Exception => e
          STDERR << "visitor_bot : cannot die visitor after not found landing pag : #{e.message}"
        end
        return 6
    end
    visitor.close_browser unless visitor.nil?
    visitor.die unless visitor.nil?
    STDERR << "visitor_bot : failed : #{e.message}"
    return -1
  end
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
    params = YAML::load(File.open(PARAMETERS), "r:UTF-8")
    @@debug_outbound_queries = params[$staging]["debug_outbound_queries"] unless params[$staging]["debug_outbound_queries"].nil? #geolocation
    @@home = params[$staging]["home"] unless params[$staging]["home"].nil? #geolocation
    @@firefox_path = params[$staging]["firefox_path"] unless params[$staging]["firefox_path"].nil?
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
exit state




