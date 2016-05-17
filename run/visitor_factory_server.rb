#!/usr/bin/env ruby -w

require 'yaml'
require 'trollop'
require 'pathname'
require 'eventmachine'
require 'rufus-scheduler'
require_relative '../lib/logging'
require_relative '../lib/os'
require_relative '../lib/parameter'
require_relative '../lib/error'
require_relative '../model/browser_type/browser_type'
require_relative '../model/visitor_factory/visitor_factory'
require_relative '../model/geolocation/geolocation_factory'
require_relative '../lib/monitoring'
require_relative '../model/visitor_factory/http_server'
require_relative '../lib/supervisor'

# factory which execute visitor_bot with a visit
#
# Usage:
#        visitor_factory_server [options]
# where [options] are:
#   -p, --proxy-type=<s>                             Type of geolocation proxy
#                                                    use (none|factory|http)
#                                                    (default: none)
#   -r, --proxy-ip=<s>                               @ip of geolocation proxy
#   -o, --proxy-port=<i>                             Port of geolocation proxy
#   -x, --proxy-user=<s>                             Identified user of
#                                                    geolocation proxy
#   -y, --proxy-pwd=<s>                              Authentified pwd of
#                                                    geolocation proxy
#   -[, --[[:depends, [:proxy-user, :proxy-pwd]]]
#   -v, --version                                    Print version and exit
#   -h, --help                                       Show this message

TMP = Pathname(File.join(File.dirname(__FILE__), "..", "tmp")).realpath

opts = Trollop::options do
  version "visitor factory server 0.4 (c) 2014 Dave Scrapper"
  banner <<-EOS
factory which execute visitor_bot with a visit

Usage:
       visitor_factory_server [options]
where [options] are:
  EOS
  opt :proxy_type, "Type of geolocation proxy use (none|factory|http)", :type => :string, :default => "none"
  opt :proxy_ip, "@ip of geolocation proxy", :type => :string
  opt :proxy_port, "Port of geolocation proxy", :type => :integer
  opt :proxy_user, "Identified user of geolocation proxy", :type => :string
  opt :proxy_pwd, "Authentified pwd of geolocation proxy", :type => :string
  opt depends(:proxy_user, :proxy_pwd)
end

Trollop::die :proxy_type, "is not in (none|factory|http)" if !["none", "factory", "http"].include?(opts[:proxy_type])
Trollop::die :proxy_ip, "is require with proxy" if ["http"].include?(opts[:proxy_type]) and opts[:proxy_ip].nil?
Trollop::die :proxy_port, "is require with proxy" if ["http"].include?(opts[:proxy_type]) and opts[:proxy_port].nil?

#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
  parameters_visitor_bot = Parameter.new("visitor_bot.rb")
rescue Exception => e
  $stderr << e.message << "\n"
else
  $staging = parameters.environment
  $debugging = parameters.debugging
  $runtime_ruby = parameters.runtime_ruby.join(File::SEPARATOR)
  $delay_periodic_scan = parameters.delay_periodic_scan
  delay_out_of_time = parameters.delay_out_of_time
  delay_periodic_pool_size_monitor = parameters.delay_periodic_pool_size_monitor
  delay_periodic_load_geolocations = parameters.delay_periodic_load_geolocations
  monitoring_server_ip = parameters.monitoring_server_ip
  http_server_listening_port = parameters.http_server_listening_port
  periodicity_supervision = parameters.periodicity_supervision
  # recuperation du mode debug ou pas de visitor_bot pour selectionner le fichier de log de visitor_bot à afficher dans le monitoring.
  # l extension est differente entre debug et non debug
  max_count_current_visit = parameters.max_count_current_visit
  debugging_visitor_bot = parameters_visitor_bot.debugging

  if $runtime_ruby.nil? or
      $delay_periodic_scan.nil? or
      delay_out_of_time.nil? or
      delay_periodic_pool_size_monitor.nil? or
      delay_periodic_load_geolocations.nil? or
      monitoring_server_ip.nil? or
      http_server_listening_port.nil? or
      periodicity_supervision.nil? or
      max_count_current_visit.nil? or
      $debugging.nil? or
      $staging.nil?
    $stderr << "some parameters not define\n" << "\n"
    exit(1)
  end
end
logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

logger.a_log.info "parameters of visitor factory server :"
logger.a_log.info "geolocation is : #{opts[:proxy_type]}"
logger.a_log.info "runtime ruby : #{$runtime_ruby}"
logger.a_log.info "delay_periodic_scan (second) : #{$delay_periodic_scan}"
logger.a_log.info "delay_periodic_pool_size_monitor (minute) : #{delay_periodic_pool_size_monitor}"
logger.a_log.info "delay_periodic_load_geolocations (minute) : #{delay_periodic_load_geolocations}"
logger.a_log.info "delay_out_of_time (minute): #{delay_out_of_time}"
logger.a_log.info "monitoring_server_ip: #{monitoring_server_ip}"
logger.a_log.info "http_server_listening_port: #{http_server_listening_port}"
logger.a_log.info "debugging_visitor_bot: #{debugging_visitor_bot}"
logger.a_log.info "periodicity supervision : #{periodicity_supervision}"
logger.a_log.info "max count current visit : #{max_count_current_visit}"

logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"
#--------------------------------------------------------------------------------------------------------------------
# INCLUDE
#--------------------------------------------------------------------------------------------------------------------
include Errors

#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------

begin
  bt = BrowserTypes.new()
  logger.a_log.info "load browser type repository file : #{BrowserTypes::BROWSER_TYPE}"
  bt.publish_to_sahi
  logger.a_log.info "publish browser type to \\lib\\sahi.in.co"


  vf_arr = []

  EM.run do
    logger.a_log.info "visitor factory server is starting"

    Signal.trap("INT") { EventMachine.stop; }
    Signal.trap("TERM") { EventMachine.stop; }

    # supervision
    Rufus::Scheduler.start_new.every periodicity_supervision do
      Supervisor.send_online(File.basename(__FILE__, '.rb'))
    end
    # association d'une geolocation factory à chaque visitor_factory pour eviter les contentions car chaque visitorFactory
    # s'execute dans un thread car c'est un EM::ThreadedResource
    # remarque  : mettre un Mutex sur @gelocations_factory genere l'erreur :  "deadlock; recursive locking"
    geolocation_factory = nil
    case opts[:proxy_type]
      when "none"

        logger.a_log.info "none geolocation"

      when "factory"

        logger.a_log.info "factory geolocation"
        geolocation_factory = Geolocations::GeolocationFactory.new(delay_periodic_load_geolocations * 60, logger)

      when "http"

        logger.a_log.info "default geolocation : #{opts[:proxy_ip]}:#{opts[:proxy_port]}"
        geo_flow = Flow.new(TMP, "geolocations", $staging, Date.today)
        geo_flow.write(["fr", opts[:proxy_type], opts[:proxy_ip], opts[:proxy_port], opts[:proxy_user], opts[:proxy_pwd]].join(Geolocations::Geolocation::SEPARATOR))
        geo_flow.close
        geolocation_factory = Geolocations::GeolocationFactory.new(delay_periodic_load_geolocations * 60, logger)

    end

    bt.browser.each { |name|
      bt.browser_version(name).each { |version|

        runtime_browser_path = bt.runtime_path(name, version)
        unless File.exist?(runtime_browser_path)
          logger.an_event.error "runtime browser #{name} #{version} path <#{runtime_browser_path}> not found"
          raise Error.new(VisitorFactory::RUNTIME_BROWSER_PATH_NOT_FOUND)
        end


        use_proxy_system = bt.proxy_system?(name, version) == true ? "yes" : "no"

        port_proxy_sahi = bt.listening_port_proxy(name, version)

        vf = VisitorFactory.new(name,
                                version,
                                use_proxy_system,
                                port_proxy_sahi,
                                $runtime_ruby,
                                $delay_periodic_scan,
                                delay_out_of_time,
                                max_count_current_visit,
                                geolocation_factory.nil? ? geolocation_factory : geolocation_factory.dup,
                                logger)
        vf.scan_visit_file
        vf_arr << vf
      }
    }


    EM.add_periodic_timer(delay_periodic_pool_size_monitor * 60) do
      pool_size = {}
      vf_arr.each { |vf|
        pool_size.merge!({vf.pattern => vf.pool_size})
        logger.an_event.info "pool size #{vf.pattern} : #{vf.pool_size}"
      }
      #TODO suppress monitoring
      #Monitoring.send_pool_size(pool_size, logger)
    end

    Supervisor.send_online(File.basename(__FILE__, '.rb'))

  end

rescue Error => e
  Supervisor.send_failure(File.basename(__FILE__, '.rb'), e)
  case e.code
    when BrowserTypes::BROWSER_TYPE_NOT_PUBLISH, VisitorFactory::RUNTIME_BROWSER_PATH_NOT_FOUND, Geolocations::GEO_FILE_NOT_FOUND
      logger.a_log.fatal e
    else
      logger.a_log.error e
      logger.a_log.warn "visitor factory server restart"
      retry
  end

rescue Exception => e
  Supervisor.send_failure(File.basename(__FILE__, '.rb'), e)
  logger.a_log.error e
  logger.a_log.warn "visitor factory server restart"
  retry
end

logger.a_log.info "visitor factory server stopped"


