#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require 'trollop'
require 'pathname'
require_relative '../lib/logging'
require_relative '../model/visitor_factory/public'
require_relative '../model/visitor_factory/visitor_factory'
require_relative '../model/visitor_factory/browser_type'

#TODO declarer le server comme un service windows
include VisitorFactory


opts = Trollop::options do
  version "test 0.1 (c) 2013 Dave Scrapper"
  banner <<-EOS
factory which execute visitor_bot with a visit

Usage:
       visitor_bot [options]
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
VisitorFactory.logger(logger)

logger.a_log.info "parameters of visitor factory server :"
logger.a_log.info "geolocation is : #{opts[:proxy_type]}"
logger.a_log.info "assign new visitor listening port : #{VisitorFactory.assign_new_visitor_listening_port}"
logger.a_log.info "assign return visitor listening port : #{VisitorFactory.assign_return_visitor_listening_port}"
logger.a_log.info "firefox path : #{VisitorFactory.firefox_path}"
logger.a_log.info "debug outbound queries : #{VisitorFactory.debug_outbound_queries}"
logger.a_log.info "home : #{VisitorFactory.home}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
logger.a_log.info "load browser type repository file : browser_type.csv"
bt = VisitorFactory::BrowserTypes.new(Pathname.new(File.join(File.dirname(__FILE__),'..', 'model','visitor_factory', 'browser_type.csv')).realpath)
logger.a_log.info "generation of win32.xml browser type file"
bt.to_win32(Pathname.new(File.join(File.dirname(__FILE__),'..', 'lib', 'sahi.in.co' ,'config', 'browser_types', 'win32.xml')).realpath)
logger.a_log.info "generation of win64.xml browser type file"
bt.to_win64(Pathname.new(File.join(File.dirname(__FILE__),'..', 'lib', 'sahi.in.co' ,'config', 'browser_types', 'win64.xml')).realpath)

EventMachine.run {
  #timer = EventMachine::PeriodicTimer.new(60) do
  #  VisitorFactory.garbage_free_visitors
  #end

  Signal.trap("INT") { EventMachine.stop ;  }
  Signal.trap("TERM") { EventMachine.stop ; }

  EventMachine.add_periodic_timer( 5*60 ) { VisitorFactory.garbage_free_visitors }

  logger.a_log.info "visitor factory server is starting"
  EventMachine.start_server "127.0.0.1", VisitorFactory.assign_new_visitor_listening_port, VisitorFactory::AssignNewVisitorConnection, bt, logger, opts

}
logger.a_log.info "visitor factory server stopped"

