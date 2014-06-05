#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require 'trollop'
require 'pathname'
require_relative '../lib/logging'
require_relative '../model/visitor_factory/visitor_factory'
require_relative '../model/browser_type/browser_type'

#TODO declarer le server comme un service windows


opts = Trollop::options do
  version "visitor factory server 0.3 (c) 2014 Dave Scrapper"
  banner <<-EOS
factory which execute visitor_bot with a visit

Usage:
       visitor_factory_server [options]
where [options] are:
  EOS
  opt :proxy_type, "Type of geolocation proxy use (none|http|https|socks)", :type => :string, :default => "none"
  opt :proxy_ip, "@ip of geolocation proxy", :type => :string
  opt :proxy_port, "Port of geolocation proxy", :type => :integer
  opt :proxy_user, "Identified user of geolocation proxy", :type => :string
  opt :proxy_pwd, "Authentified pwd of geolocation proxy", :type => :string

  opt depends(:proxy_type, :proxy_ip)
  opt depends(:proxy_type, :proxy_port)
  opt depends(:proxy_user, :proxy_pwd)
end

Trollop::die :proxy_ip, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_ip].nil?
Trollop::die :proxy_port, "is require with proxy" if opts[:proxy_type] != "none" and opts[:proxy_port].nil?

#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
VisitorFactory.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

logger.a_log.info "parameters of visitor factory server :"
logger.a_log.info "geolocation is : #{opts[:proxy_type]}"
logger.a_log.info "runtime ruby : #{$runtime_ruby}"
logger.a_log.info "delay_periodic_scan : #{$delay_periodic_scan}"
logger.a_log.info "os : #{$current_os}"
logger.a_log.info "os version : #{$current_os_version}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
logger.a_log.info "load browser type repository file : browser_type.csv"
bt = BrowserTypes.new($current_os, $current_os_version)
logger.a_log.info "publish browser type to sahi"
bt.publish_to_sahi


EM.run do

  Signal.trap("INT") { EventMachine.stop; }
  Signal.trap("TERM") { EventMachine.stop; }

  logger.a_log.info "visitor factory server is starting"
  bt.browser.each { |name|
    bt.browser_version(name).each { |version|

      runtime_browser_path = bt.runtime_path(name, version)
      raise StandardError, "runtime browser path #{runtime_browser_path} not found" unless File.exist?(runtime_browser_path)

      use_proxy_system = bt.proxy_system?(name, version) == true ? "yes" : "no"

      port_proxy_sahi = bt.listening_port_proxy(name, version)

      vf = VisitorFactory.new(name, version, use_proxy_system, port_proxy_sahi, $runtime_ruby, $delay_periodic_scan, opts, logger)
      vf.scan_visit_file
    }
  }
end

logger.a_log.info "visitor factory server stopped"


