#!/usr/bin/env ruby -w
# encoding: UTF-8

require 'yaml'
require_relative '../lib/logging'
require_relative '../model/scheduler_connection'

include Scheduler
#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
Scheduler.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


logger.a_log.info "parameters of scheduler server :"
logger.a_log.info "listening port : #{Scheduler.listening_port}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
EventMachine.run {
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  logger.a_log.info "scheduler server is starting"
  EventMachine.start_server "127.0.0.1", Scheduler.listening_port, Connection, logger
}
logger.a_log.info "scheduler server stopped"

