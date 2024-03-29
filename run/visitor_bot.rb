# encoding: utf-8
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
=begin
bot which surf on website

Usage:
       visitor_bot [options]
where [options] are:
  -v, --visit-file-name=<s>                                                                                                      Path and name of visit file to browse
  -s, --slave=<s>                                                                                                                Visitor
                                                                                                                                 is slave
                                                                                                                                 of
                                                                                                                                 Visitor
                                                                                                                                 Factory
                                                                                                                                 (yes/no)
                                                                                                                                 (default:
                                                                                                                                 no)
  -p, --proxy-system=<s>                                                                                                         browser
                                                                                                                                 use
                                                                                                                                 proxy
                                                                                                                                 system
                                                                                                                                 of
                                                                                                                                 windows
                                                                                                                                 (yes/no)
                                                                                                                                 (default:
                                                                                                                                 no)
  -l, --listening-port-visitor-factory=<i>                                                                                       Listening port of Visitor Factory (default: 9220)
  -i, --listening-port=<i>                                                                                                       Listening port of Visitor Bot (default: 9800)
  -t, --listening-port-sahi-proxy=<i>                                                                                            Listening port of Sahi proxy (default: 9999)
  -r, --proxy-type=<s>                                                                                                           Type of geolocation
                                                                                                                                 proxy use
                                                                                                                                 (none|http|https|socks)
                                                                                                                                 (default:
                                                                                                                                 none)
  -o, --proxy-ip=<s>                                                                                                             @ip of geolocation proxy
  -x, --proxy-port=<i>                                                                                                           Port of geolocation proxy
  -y, --proxy-user=<s>                                                                                                           Identified user of geolocation proxy
  -w, --proxy-pwd=<s>                                                                                                            Authentified pwd of geolocation proxy
  -m, --max-time-to-live-visit=<i>                                                                                               Max time to live visit (minute) (default: 30)
  -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
  -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
  -[, --[[:depends, [:proxy-type, :proxy-ip]], [:depends, [:proxy-type, :proxy-port]], [:depends, [:proxy-user, :proxy-pwd]]]
  -e, --version                                                                                                                  Print version and exit
  -h, --help                                                                                                                     Show this message
=end

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
  opt :max_time_to_live_visit, "Max time to live visit (minute)", :type => :integer, :default => 30

  #opt depends(:slave, :listening_port, :listening_port_visitor_factory)
  opt depends(:proxy_type, :proxy_ip)
  opt depends(:proxy_type, :proxy_port)
  opt depends(:proxy_user, :proxy_pwd)
end

Trollop::die :visit_file_name, "is require" if opts[:visit_file_name].nil?
Trollop::die :visit_file_name, ": <#{opts[:visit_file_name]}> is not valid, or not find" unless File.file?(opts[:visit_file_name])
Trollop::die :proxy_ip, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_ip].nil?
Trollop::die :proxy_port, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_port].nil?


#-----------------------------------------------------------------------------------------------------------------------
# gestion des erreurs :
# visitor_bot retourne à la fois un CR à visitor_factory et envoie une raison de l'erreur à statupweb
# tableau d'alignement des CR et des raisons :
#-----------------------------------------------------------------------------------------------------------------------
# ERROR                          | CR                      | RAISON
#-----------------------------------------------------------------------------------------------------------------------
# no error                       | OK                      | no reason
# error not identifie            | KO                      | "error not catch"
#-----------------------------------------------------------------------------------------------------------------------
# ARGUMENT_UNDEFINE              | ERR_VISIT_DEFINITION    | "visit definition"
# VISIT_NOT_LOAD                 | ERR_VISIT_LOADING       | "visit loading"
# VISIT_NOT_CREATE               | ERR_VISIT_CREATION      | "visit creation"
# VISITOR_NOT_FULL_EXECUTE_VISIT | ERR_VISIT_EXECUTION     | "visit execution"
# Timeout::Error                 | ERR_VISIT_OVER_TTL      | "visit over ttl"
#-----------------------------------------------------------------------------------------------------------------------
# ARGUMENT_UNDEFINE              | ERR_VISITOR_DEFINITON   | "visitor definition"
# VISITOR_NOT_CREATE             | ERR_VISITOR_CREATION    | "visitor creation"
# VISITOR_NOT_BORN               | ERR_VISITOR_BIRTH       | "visitor birth"
# VISITOR_NOT_DIE                | ERR_VISITOR_DEATH       | "visitor death"
# VISITOR_NOT_INHUME             | ERR_VISITOR_INHUMATION  | "visitor inhumation"
#-----------------------------------------------------------------------------------------------------------------------
# VISITOR_NOT_OPEN               | ERR_BROWSER_OPENING     | "browser opening"
# VISITOR_NOT_CLOSE              | ERR_BROWSER_CLOSING     | "browser closing"
#-----------------------------------------------------------------------------------------------------------------------
# BROWSER_NOT_FOUND_LINK         | ERR_LINK_TRACKING       | "link tracking"
# NONE_ADVERT                    | ERR_ADVERT_TRACKING     | "advert tracking"
# VISITOR_SEE_CAPTCHA            | ERR_CAPTCHA_SUBMITTING    | "captcha occurence"
#-----------------------------------------------------------------------------------------------------------------------
OK = 0
KO = 1
ERR_VISIT_DEFINITION = 2
ERR_VISIT_LOADING = 3
ERR_VISIT_CREATION = 4
ERR_VISIT_OVER_TTL = 5
ERR_VISITOR_DEFINITON = 6
ERR_VISITOR_CREATION = 7
ERR_VISITOR_BIRTH = 8
ERR_VISITOR_DEATH = 9
ERR_VISITOR_INHUMATION = 10
ERR_BROWSER_OPENING = 11
ERR_BROWSER_CLOSING = 12
ERR_LINK_TRACKING = 13
ERR_ADVERT_TRACKING = 14
ERR_CAPTCHA_SUBMITTING = 15
ERR_VISIT_EXECUTION = 16

def visit_started(visit, visitor, logger)
  begin
    Monitoring.visit_started(visit.id,
                             visit.script,
                             visitor.proxy.ip_geo_proxy)
  rescue Exception => e
    logger.an_event.warn e.message

  end
end

def change_visit_state(visit_id, state, logger, reason=nil)
  begin
    Monitoring.change_state_visit(visit_id, state, reason)

  rescue Exception => e
    logger.an_event.warn e.message

  end
end

def visitor_is_no_slave(opts, logger)
  visit = nil
  visitor = nil

  begin


    exit_status = Timeout::timeout(opts[:max_time_to_live_visit] * 60) {

      begin
        #---------------------------------------------------------------------------------------------------------------------
        # chargement du fichier definissant la visite
        #---------------------------------------------------------------------------------------------------------------------
        visit_details,
            website_details,
            visitor_details = Visit.load(opts[:visit_file_name])


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
        visitor.open_browser

        #---------------------------------------------------------------------------------------------------------------------
        # Visitor execute visit
        #---------------------------------------------------------------------------------------------------------------------
        visit_started(visit, visitor, logger)

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
        #---------------------------------------------------------------------------------------------------------------
        visitor.inhume

      rescue Exception => e
        # fail debut
        case e.code
          when Visits::Visit::ARGUMENT_UNDEFINE
            exit_status = ERR_VISIT_DEFINITION
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visit definition")

          when Visits::Visit::VISIT_NOT_LOAD
            exit_status = ERR_VISIT_LOADING
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visit loading")

          when Visits::Visit::VISIT_NOT_CREATE
            exit_status = ERR_VISIT_CREATION
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visit creation")

          when Visitors::Visitor::ARGUMENT_UNDEFINE
            exit_status = ERR_VISITOR_DEFINITON
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor definition")

          when Visitors::Visitor::VISITOR_NOT_CREATE
            exit_status = ERR_VISITOR_CREATION
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor creation")

          when Visitors::Visitor::VISITOR_NOT_BORN
            exit_status = ERR_VISITOR_BIRTH
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor birth")

          when Visitors::Visitor::VISITOR_NOT_DIE
            exit_status = ERR_VISITOR_DEATH
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor death")

          when Visitors::Visitor::VISITOR_NOT_INHUME
            exit_status = ERR_VISITOR_INHUMATION
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor inhumation")

          when Visitors::Visitor::VISITOR_NOT_OPEN
            exit_status = ERR_BROWSER_OPENING
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "browser opening")

          when Visitors::Visitor::VISITOR_NOT_CLOSE
            exit_status = ERR_BROWSER_CLOSING
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "browser closing")

            begin
              visitor.die

            rescue Exception => e

            end

          when Visitors::Visitor::VISITOR_NOT_FULL_EXECUTE_VISIT
            if e.history.include?(Browsers::Browser::BROWSER_NOT_FOUND_LINK)
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "link tracking")
              exit_status = ERR_LINK_TRACKING

            elsif e.history.include?(Visitors::Visitor::VISITOR_NOT_CHOOSE_ADVERT)
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "advert tracking")
              exit_status = ERR_ADVERT_TRACKING

            elsif e.history.include?(Visitors::Visitor::VISITOR_NOT_CLOSE)
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "browser closing")
              exit_status = ERR_BROWSER_CLOSING

            elsif e.history.include?(Visitors::Visitor::VISITOR_NOT_DIE)
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visitor death")
              exit_status = ERR_VISITOR_DEATH

            elsif e.history.include?(Visitors::Visitor::VISITOR_NOT_SUBMIT_CAPTCHA)
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "captcha submitting")
              exit_status = ERR_CAPTCHA_SUBMITTING

            else
              exit_status = ERR_VISIT_EXECUTION
              change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "visit execution")
            end

            begin
              visitor.close_browser
              visitor.die

            rescue Exception => e
            end

            exit_status

          else
            change_visit_state(visit_details[:id], Monitoring::FAIL, logger, "error not catch")
            exit_status = KO

        end
        exit_status
          # fail end
      else
        # Success
        change_visit_state(visit_details[:id], Monitoring::SUCCESS, logger)
        exit_status = OK

      ensure
        exit_status

      end
    }


  rescue Timeout::Error => e
    begin
      visitor.close_browser
      visitor.die
    rescue Exception => e
    end
    visit_details,
        website_details,
        visitor_details = Visit.load(opts[:visit_file_name])
    change_visit_state(visit_details[:id], Monitoring::OVERTTL, logger, "visit over ttl")
    exit_status = ERR_VISIT_OVER_TTL

  ensure
    exit_status

  end
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
  $dir_archive = parameters.archive
  $dir_log = parameters.log
  $dir_tmp = parameters.tmp
  $dir_visitors = parameters.visitors

  visitor_id = YAML::load(File.read(opts[:visit_file_name]))[:visitor][:id]

  logger = Logging::Log.new(self, :staging => $staging, :id_file => File.join("#{File.basename(__FILE__, ".rb")}_#{visitor_id}"), :debugging => $debugging)
  logger.an_event.debug "File Parameters begin------------------------------------------------------------------------------"
  logger.a_log.info "java runtime path : #{$java_runtime_path}"
  logger.a_log.info "java key tool path : #{$java_key_tool_path}"
  logger.a_log.info "start page server ip : #{$start_page_server_ip}"
  logger.a_log.info "start page server port: #{$start_page_server_port}"
  logger.a_log.info "debugging : #{$debugging}"
  logger.a_log.info "staging : #{$staging}"
  logger.a_log.info "specific dir archive : #{$dir_archive}"
  logger.a_log.info "specific dir log : #{$dir_log}"
  logger.a_log.info "specific dir tmp : #{$dir_tmp}"
  logger.a_log.info "specific dir visitors : #{$dir_visitors}"
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
  #exit_status = visitor_is_slave(opts) if opts[:slave] == "yes"  pour gerer le return visitor
  exit_status = visitor_is_no_slave(opts, logger) if opts[:slave] == "no"

  logger.an_event.debug "end execution visitor_bot, with state #{exit_status}"
  Process.exit(exit_status)

end



