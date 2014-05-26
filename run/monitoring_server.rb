#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require 'trollop'
require 'pathname'
require_relative '../lib/logging'
require_relative '../model/monitoring/monitoring'
require_relative '../model/monitoring/public'
require_relative '../model/monitoring/http_server'

opts = Trollop::options do
  version "monitoring 0.1 (c) 2014 Dave Scrapper"
  banner <<-EOS
monitoring catch all activity send by statup_bot : Error.

Usage:
       monitoring_server [options]
where [options] are:
  EOS

end



#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
Monitoring.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
Monitoring.logger(logger)

logger.a_log.info "parameters of monitoring server :"
logger.a_log.info "return code listening port : #{Monitoring.return_code_listening_port}"
logger.a_log.info "http server listening port : #{Monitoring.http_server_listening_port}"

logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------

@@return_codes = {}
@@count_visits = [0]
@@count_success = [0]
EventMachine.run {

  Signal.trap("INT") { EventMachine.stop ;  }
  Signal.trap("TERM") { EventMachine.stop ; }

  logger.a_log.info "monitoring server is starting"
  EventMachine.start_server "0.0.0.0", Monitoring.return_code_listening_port, Monitoring::ReturnCodeConnection, @@return_codes,@@count_visits,@@count_success, logger, opts
  logger.a_log.info "monitoring server http is starting"
  EventMachine.start_server "0.0.0.0", Monitoring.http_server_listening_port, HTTPHandler, @@return_codes , @@count_success, @@count_visits

}
logger.a_log.info "visitor factory server stopped"

