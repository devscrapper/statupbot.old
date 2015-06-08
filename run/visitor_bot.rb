require_relative '../model/visitor/visitor'
require_relative '../model/visit/visit'
require_relative '../model/monitoring/public'
require_relative '../lib/logging'
require_relative '../lib/parameter'
require_relative '../lib/mail_sender'

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
KO = 1
NO_AD = 2
NO_LANDING = 3

def visitor_is_no_slave(opts, logger)
  visit = nil
  visitor = nil
  landing_page = nil
  advertiser_landing_page = nil
  final_visit_page = nil
  final_advertiser_page = nil

  #---------------------------------------------------------------------------------------------------------------------
  # chargement du fichier definissant la visite
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visit_details = Visit.load(opts[:visit_file_name])

  rescue Exception => e

    Monitoring.send_failure(e, opts[:visit_file_name], logger)
    return KO

  end

  context = ["visit=#{visit_details[:id_visit]}"]
  logger.ndc context

  #---------------------------------------------------------------------------------------------------------------------
  # Creation de la visit
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visit = Visit.build(visit_details)

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end
  #---------------------------------------------------------------------------------------------------------------------
  # Creation du visitor
  #---------------------------------------------------------------------------------------------------------------------

  visitor_details = visit_details[:visitor]
  visitor_details[:browser][:proxy_system] = opts[:proxy_system] == "yes"
  visitor_details[:browser][:listening_port_proxy] = opts[:listening_port_sahi_proxy]
  visitor_details[:browser][:proxy_ip] = opts[:proxy_ip]
  visitor_details[:browser][:proxy_port] = opts[:proxy_port]
  visitor_details[:browser][:proxy_user] = opts[:proxy_user]
  visitor_details[:browser][:proxy_pwd] = opts[:proxy_pwd]

  begin

    visitor = Visitor.new(visitor_details)

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Naissance du Visitor
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.born

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor open browser
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.open_browser

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    visitor.die
    return KO

  end

    #---------------------------------------------------------------------------------------------------------------------
  # Visitor execute visit
  #---------------------------------------------------------------------------------------------------------------------
  begin

    final_visit_page = visitor.execute(visit)

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    visitor.close_browser
    visitor.die
    if e.history.include?(Browsers::Browser::BROWSER_NOT_FOUND_LINK)
      cr = NO_LANDING
    elsif e.history.include?(Visits::Advertisings::Advertising::NONE_ADVERT)
      cr = NO_AD
    else
      cr = KO
    end
    return cr

  end


  begin

    visitor.close_browser

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    visitor.die
    return KO

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor die
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.die

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Visitor inhume
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visitor.inhume

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end


  Monitoring.send_success(visit_details, logger)
  OK
end


#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
rescue Exception => e
  $stderr << e.message << "\n"
else
  $staging = parameters.environment
  $debugging = parameters.debugging
  $java_runtime_path = parameters.java_runtime_path.join(File::SEPARATOR)
  $java_key_tool_path = parameters.java_key_tool_path.join(File::SEPARATOR)
  $start_page_server_ip = parameters.start_page_server_ip
  $start_page_server_port = parameters.start_page_server_port

  visitor_id = YAML::load(File.read(opts[:visit_file_name]))[:visitor][:id]

  logger = Logging::Log.new(self, :staging => $staging, :id_file => File.join("#{File.basename(__FILE__, ".rb")}_#{visitor_id}"), :debugging => $debugging)
  logger.an_event.debug "File Parameters begin------------------------------------------------------------------------------"
  logger.a_log.info "java runtime path : #{$java_runtime_path}"
  logger.a_log.info "java key tool path : #{$java_key_tool_path}"
  logger.a_log.info "start page server ip : #{$start_page_server_ip}"
  logger.a_log.info "start page server port: #{$start_page_server_port}"
  logger.a_log.info "debugging : #{$debugging}"
  logger.a_log.info "staging : #{$staging}"
  logger.an_event.debug "File Parameters end------------------------------------------------------------------------------"
  logger.an_event.debug "Start Parameters begin------------------------------------------------------------------------------"
  logger.an_event.debug opts.to_yaml
  logger.an_event.debug "Start Parameters end--------------------------------------------------------------------------------"

  if $java_runtime_path.nil? or
      $java_key_tool_path.nil? or
      $start_page_server_ip.nil? or
      $start_page_server_port.nil? or
      $debugging.nil? or
      $staging.nil?
    $stderr << "some parameters not define" << "\n"
    Process.exit(KO)
  end
  #--------------------------------------------------------------------------------------------------------------------
  # MAIN
  #--------------------------------------------------------------------------------------------------------------------

  logger.an_event.debug "begin execution visitor_bot"
  state = OK
  #state = visitor_is_slave(opts) if opts[:slave] == "yes"  pour gerer le return visitor
  state = visitor_is_no_slave(opts, logger) if opts[:slave] == "no"
  logger.an_event.debug "end execution visitor_bot, with state #{state}"
  Process.exit(state)
end



