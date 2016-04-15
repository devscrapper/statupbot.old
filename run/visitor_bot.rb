require_relative '../model/visitor/visitor'
require_relative '../model/visit/visit'
require_relative '../lib/monitoring'
require_relative '../lib/logging'
require_relative '../lib/parameter'
require_relative '../lib/mail_sender'
require_relative '../lib/error'
require 'uri'
require 'trollop'
require 'eventmachine'
require 'timeout'

include Visits
include Visitors
# bot which surf on website
#
# Usage:
#        visitor_bot [options]
# where [options] are:
#   -v, --visit-file-name=<s>                                                                                                      Path and name of visit file to browse
#   -s, --slave=<s>                                                                                                                Visitor
#                                                                                                                                  is slave
#                                                                                                                                  of
#                                                                                                                                  Visitor
#                                                                                                                                  Factory
#                                                                                                                                  (yes/no)
#                                                                                                                                  (default:
#                                                                                                                                  no)
#   -p, --proxy-system=<s>                                                                                                         browser
#                                                                                                                                  use
#                                                                                                                                  proxy
#                                                                                                                                  system
#                                                                                                                                  of
#                                                                                                                                  windows
#                                                                                                                                  (yes/no)
#                                                                                                                                  (default:
#                                                                                                                                  no)
#   -l, --listening-port-visitor-factory=<i>                                                                                       Listening port of Visitor Factory (default: 9220)
#   -i, --listening-port=<i>                                                                                                       Listening port of Visitor Bot (default: 9800)
#   -t, --listening-port-sahi-proxy=<i>                                                                                            Listening port of Sahi proxy (default: 9999)
#   -r, --proxy-type=<s>                                                                                                           Type of geolocation
#                                                                                                                                  proxy use
#                                                                                                                                  (none|http|https|socks)
#                                                                                                                                  (default:
#                                                                                                                                  none)
#   -o, --proxy-ip=<s>                                                                                                             @ip of geolocation proxy
#   -x, --proxy-port=<i>                                                                                                           Port of geolocation proxy
#   -y, --proxy-user=<s>                                                                                                           Identified user of geolocation proxy
#   -w, --proxy-pwd=<s>                                                                                                            Authentified pwd of geolocation proxy
#   -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
#   -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
#   -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
#   -e, --version                                                                                                                  Print version and exit
#   -h, --help                                                                                                                     Show this message

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
OVER_TTL = 4


def change_visit_state(visit_id, state, logger)
  begin
    Monitoring.change_state_visit(visit_id, state)

  rescue Exception => e
    logger.an_event.warn e.messsage

  end
end

def visitor_is_no_slave(max_time_to_live_visit, opts, logger)
  visit = nil
  visitor = nil

  begin


    exit_status = Timeout::timeout(max_time_to_live_visit * 60) {
      #---------------------------------------------------------------------------------------------------------------------
      # chargement du fichier definissant la visite
      #---------------------------------------------------------------------------------------------------------------------
      visit_details,
          website_details,
          visitor_details = Visit.load(opts[:visit_file_name])

      change_visit_state(visit_details[:id], Monitoring::START, logger)
      context = ["visit=#{visit_details[:id]}"]
      logger.ndc context


      #---------------------------------------------------------------------------------------------------------------------
      # Creation de la visit
      #---------------------------------------------------------------------------------------------------------------------
      visit = Visit.build(visit_details, website_details)

      #---------------------------------------------------------------------------------------------------------------------
      # Creation du visitor
      #---------------------------------------------------------------------------------------------------------------------
      visitor_details[:browser][:proxy_system] = opts[:proxy_system] == "yes"
      visitor_details[:browser][:listening_port_proxy] = opts[:listening_port_sahi_proxy]
      visitor_details[:browser][:proxy_ip] = opts[:proxy_ip]
      visitor_details[:browser][:proxy_port] = opts[:proxy_port]
      visitor_details[:browser][:proxy_user] = opts[:proxy_user]
      visitor_details[:browser][:proxy_pwd] = opts[:proxy_pwd]

      visitor = Visitor.new(visitor_details)

      #---------------------------------------------------------------------------------------------------------------------
      # Naissance du Visitor
      #---------------------------------------------------------------------------------------------------------------------
      visitor.born
      #---------------------------------------------------------------------------------------------------------------------
      # Visitor open browser
      #---------------------------------------------------------------------------------------------------------------------
      begin
        visitor.open_browser

        #---------------------------------------------------------------------------------------------------------------------
        # Visitor execute visit
        #---------------------------------------------------------------------------------------------------------------------

        visitor.execute(visit)
        #---------------------------------------------------------------------------------------------------------------------
        # Visitor close browser
        #---------------------------------------------------------------------------------------------------------------------
        visitor.close_browser

        #---------------------------------------------------------------------------------------------------------------------
        # Visitor die
        #---------------------------------------------------------------------------------------------------------------------
        visitor.die

        #---------------------------------------------------------------------------------------------------------------------
        # Visitor inhume
        #---------------------------------------------------------------------------------------------------------------------
        visitor.inhume

      rescue Exception => e
        exit_status = KO

        case e.code
          when Visits::Visit::ARGUMENT_UNDEFINE,
              Visits::Visit::VISIT_NOT_LOAD,
              Visits::Visit::VISIT_NOT_CREATE
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger)

          when Visitors::Visitor::ARGUMENT_UNDEFINE,
              Visitors::Visitor::VISITOR_NOT_CREATE,
              Visitors::Visitor::VISITOR_NOT_BORN,
              Visitors::Visitor::VISITOR_NOT_DIE,
              Visitors::Visitor::VISITOR_NOT_INHUME
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger)


          when Visitors::Visitor::VISITOR_NOT_OPEN,
              Visitors::Visitor::VISITOR_NOT_CLOSE
            visitor.die
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger)

          when Visitors::Visitor::VISITOR_NOT_FULL_EXECUTE_VISIT
            visitor.close_browser
            visitor.die
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger)
            if e.history.include?(Browsers::Browser::BROWSER_NOT_FOUND_LINK)
              exit_status = NO_LANDING
            elsif e.history.include?(Visits::Advertisings::Advertising::NONE_ADVERT)
              exit_status = NO_AD
            else
              exit_status = KO
            end
          else
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger)

        end
      else
        change_visit_state(visit_details[:id], Monitoring::SUCCESS, logger)
        exit_status = OK

      ensure
        exit_status

      end
    }


  rescue Timeout::Error => e
    visitor.close_browser
    visitor.die
    visit_details,
        website_details,
        visitor_details = Visit.load(opts[:visit_file_name])
    change_visit_state(visit_details[:id], Monitoring::OVERTTL, logger)
    exit_status = OVER_TTL

  ensure
    exit_status

  end
end


#------------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------------
def visitor_is_no_slave_old(opts, logger)
  visit = nil
  visitor = nil

  #---------------------------------------------------------------------------------------------------------------------
  # chargement du fichier definissant la visite
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visit_details,
        website_details,
        visitor_details = Visit.load(opts[:visit_file_name])

  rescue Exception => e

    Monitoring.send_failure(e, opts[:visit_file_name], logger)
    return KO

  end

  context = ["visit=#{visit_details[:id]}"]
  logger.ndc context

  #---------------------------------------------------------------------------------------------------------------------
  # Creation de la visit
  #---------------------------------------------------------------------------------------------------------------------
  begin

    visit = Visit.build(visit_details, website_details)

  rescue Exception => e

    Monitoring.send_failure(e, visit_details, logger)
    return KO

  end
  #---------------------------------------------------------------------------------------------------------------------
  # Creation du visitor
  #---------------------------------------------------------------------------------------------------------------------
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

    visitor.execute(visit)

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
  Process.exit(KO)

else
  $staging = parameters.environment
  $debugging = parameters.debugging
  $java_runtime_path = parameters.java_runtime_path.join(File::SEPARATOR)
  $java_key_tool_path = parameters.java_key_tool_path.join(File::SEPARATOR)
  $start_page_server_ip = parameters.start_page_server_ip
  $start_page_server_port = parameters.start_page_server_port
  max_time_to_live_visit = parameters.max_time_to_live_visit

  visitor_id = YAML::load(File.read(opts[:visit_file_name]))[:visitor][:id]

  logger = Logging::Log.new(self, :staging => $staging, :id_file => File.join("#{File.basename(__FILE__, ".rb")}_#{visitor_id}"), :debugging => $debugging)
  logger.an_event.debug "File Parameters begin------------------------------------------------------------------------------"
  logger.a_log.info "java runtime path : #{$java_runtime_path}"
  logger.a_log.info "java key tool path : #{$java_key_tool_path}"
  logger.a_log.info "start page server ip : #{$start_page_server_ip}"
  logger.a_log.info "start page server port: #{$start_page_server_port}"
  logger.a_log.info "max time to live visit: #{max_time_to_live_visit}"
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
      max_time_to_live_visit.nil? or
      $debugging.nil? or
      $staging.nil?
    $stderr << "some parameters not define" << "\n"
    Process.exit(KO)
  end
  #--------------------------------------------------------------------------------------------------------------------
  # MAIN
  #--------------------------------------------------------------------------------------------------------------------

  logger.an_event.debug "begin execution visitor_bot"
  #exit_status = visitor_is_slave(opts) if opts[:slave] == "yes"  pour gerer le return visitor
  exit_status = visitor_is_no_slave(max_time_to_live_visit, opts, logger) if opts[:slave] == "no"
  logger.an_event.debug "end execution visitor_bot, with state #{exit_status}"
  Process.exit(exit_status)

end



