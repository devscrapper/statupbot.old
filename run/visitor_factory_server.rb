#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'rufus-scheduler'
require 'yaml'
require_relative '../lib/logging'
require_relative '../model/visitor_factory_connection'

include VisitorFactory
#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
VisitorFactory.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


logger.a_log.info "parameters of visitor factory server :"
logger.a_log.info "assign new visitor listening port : #{VisitorFactory.assign_new_visitor_listening_port}"
logger.a_log.info "assign return visitor listening port : #{VisitorFactory.assign_return_visitor_listening_port}"
logger.a_log.info "unassign visitor listening port : #{VisitorFactory.unassign_visitor_listening_port}"
logger.a_log.info "return visitors port listening : #{VisitorFactory.return_visitors_listening_port}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
EventMachine.run {
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }



  logger.a_log.info "visitor factory server is starting"
  EventMachine.start_server "127.0.0.1", VisitorFactory.assign_new_visitor_listening_port, VisitorFactory::AssignNewVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.assign_return_visitor_listening_port, VisitorFactory::AssignReturnVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.unassign_visitor_listening_port, VisitorFactory::UnAssignVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.return_visitors_listening_port, VisitorFactory::ReturnVisitorsConnection,  logger
}
logger.a_log.info "visitor factory server stopped"

