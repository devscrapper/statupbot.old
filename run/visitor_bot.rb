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


OK = 0


def visitor_is_no_slave(opts)
  visit = nil
  visitor = nil
  landing_page = nil
  page = nil
  cr = OK


  #---------------------------------------------------------------------------------------------------------------------
  # chargement du fichier definissant la visite
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visit_details = Visit.build(opts[:visit_file_name])

  rescue Exception => e
    cr = e.code
    p "return code from visitor_bot #{cr}"
    return cr
  end

  context = ["visit=#{visit_details[:id_visit]}"]
  @@logger.ndc context

  #---------------------------------------------------------------------------------------------------------------------
  # Creation de la visit
  #---------------------------------------------------------------------------------------------------------------------

  visit_details[:visitor][:browser][:proxy_system] = opts[:proxy_system] == "yes"

  begin

    visit = Visit.new(visit_details)

  rescue Exception => e
    cr = e.code
    p e.to_s
    return cr
  end
  #---------------------------------------------------------------------------------------------------------------------
  # Creation du visitor
  #---------------------------------------------------------------------------------------------------------------------

  visitor_details = visit_details[:visitor]
  visitor_details[:browser][:listening_port_proxy] = opts[:listening_port_sahi_proxy]
  visitor_details[:browser][:proxy_ip] = opts[:proxy_ip]
  visitor_details[:browser][:proxy_port] = opts[:proxy_port]
  visitor_details[:browser][:proxy_user] = opts[:proxy_user]
  visitor_details[:browser][:proxy_pwd] = opts[:proxy_pwd]

  begin

    visitor = Visitor.build(visitor_details)

  rescue Exception => e
    cr = e.code
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Naissance du Visitor
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.born

  rescue Exception => e
    cr = e.code
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor open browser
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.open_browser

  rescue Exception => e
    cr = e.code
    visitor.die
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor browse referrer
  #---------------------------------------------------------------------------------------------------------------------
  begin

    landing_page = visitor.browse(visit.referrer)

  rescue Exception => e
    cr = e.code
    visitor.close_browser
    visitor.die
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor execute visit
  #---------------------------------------------------------------------------------------------------------------------
  begin

    page = visitor.surf(visit.durations, landing_page, visit.around)

  rescue Exception => e
    cr = e.code
    visitor.close_browser
    visitor.die
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor close its browser
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.close_browser

  rescue Exception => e
    cr = e.code
    visitor.die
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor die
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.die

  rescue Exception => e
    cr = e.code
    p e.to_s
    return cr
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor inhume
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.inhume

  rescue Exception => e
    cr = e.code
    p e.to_s
    return cr
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
@@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.join("#{File.basename(__FILE__, ".rb")}_#{visitor_id}"), :debugging => $debugging)
@@logger.an_event.debug "File Parameters begin------------------------------------------------------------------------------"
@@logger.a_log.info "java runtime path : #{$java_runtime_path}"
@@logger.a_log.info "java key tool path : #{$java_key_tool_path}"
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




