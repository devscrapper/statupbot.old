#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require 'trollop'
require 'pathname'
require 'eventmachine'
require_relative '../lib/logging'
require_relative '../lib/os'
require_relative '../lib/parameter'
require_relative '../lib/error'
require_relative '../model/browser_type/browser_type'
require_relative '../model/visitor_factory/visitor_factory'
require_relative '../model/geolocation/geolocation_factory'
require_relative '../model/monitoring/public'


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

  logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

  logger.a_log.info "parameters of visitor factory server :"
  logger.a_log.info "geolocation is : #{opts[:proxy_type]}"
  logger.a_log.info "runtime ruby : #{$runtime_ruby}"
  logger.a_log.info "delay_periodic_scan (second) : #{$delay_periodic_scan}"
  logger.a_log.info "delay_periodic_pool_size_monitor (minute) : #{delay_periodic_pool_size_monitor}"
  logger.a_log.info "delay_periodic_load_geolocations (minute) : #{delay_periodic_load_geolocations}"
  logger.a_log.info "delay_out_of_time (minute): #{delay_out_of_time}"
  logger.a_log.info "debugging : #{$debugging}"
  logger.a_log.info "staging : #{$staging}"

  if $runtime_ruby.nil? or
      $delay_periodic_scan.nil? or
      delay_out_of_time.nil? or
      $debugging.nil? or
      $staging.nil?
    $stderr << "some parameters not define\n" << "\n"
    exit(1)
  end
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
            raise VisitorFactory::VisitorFactoryError.new(VisitorFactory::RUNTIME_BROWSER_PATH_NOT_FOUND)
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
        }
        Monitoring.send_pool_size(pool_size, logger)
      end
    end

  rescue Error => e

    case e.code
      when VisitorFactory::RUNTIME_BROWSER_PATH_NOT_FOUND, Geolocations::GEO_FILE_NOT_FOUND
        logger.a_log.fatal e.message
      else
        logger.a_log.error e.message
        retry
    end

  rescue Exception => e
    logger.a_log.error e.message
    retry
  end

  logger.a_log.info "visitor factory server stopped"


end
