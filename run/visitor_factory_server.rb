#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require_relative '../lib/logging'
require_relative '../model/visitor_factory/public'
require_relative '../model/visitor_factory/visitor_factory'

include VisitorFactory
#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
VisitorFactory.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
VisitorFactory.logger(logger)

logger.a_log.info "parameters of visitor factory server :"
logger.a_log.info "assign new visitor listening port : #{VisitorFactory.assign_new_visitor_listening_port}"
logger.a_log.info "assign return visitor listening port : #{VisitorFactory.assign_return_visitor_listening_port}"
logger.a_log.info "unassign visitor listening port : #{VisitorFactory.unassign_visitor_listening_port}"
logger.a_log.info "browse url listening port : #{VisitorFactory.browse_url_listening_port}"
logger.a_log.info "click url listening port : #{VisitorFactory.click_url_listening_port}"
logger.a_log.info "search url listening port : #{VisitorFactory.search_url_listening_port}"
logger.a_log.info "firefox path : #{VisitorFactory.firefox_path}"
logger.a_log.info "debug outbound queries : #{VisitorFactory.debug_outbound_queries}"
logger.a_log.info "home : #{VisitorFactory.home}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------

EventMachine.run {
  #timer = EventMachine::PeriodicTimer.new(60) do
  #  VisitorFactory.garbage_free_visitors
  #end

  Signal.trap("INT") { EventMachine.stop ;  }
  Signal.trap("TERM") { EventMachine.stop ; }

  EventMachine.add_periodic_timer( 60 ) { VisitorFactory.garbage_free_visitors }

  logger.a_log.info "visitor factory server is starting"
  EventMachine.start_server "127.0.0.1", VisitorFactory.assign_new_visitor_listening_port, VisitorFactory::AssignNewVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.assign_return_visitor_listening_port, VisitorFactory::AssignReturnVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.unassign_visitor_listening_port, VisitorFactory::UnAssignVisitorConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.browse_url_listening_port, VisitorFactory::BrowseUrlConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.click_url_listening_port, VisitorFactory::ClickUrlConnection,  logger
  EventMachine.start_server "127.0.0.1", VisitorFactory.search_url_listening_port, VisitorFactory::SearchUrlConnection,  logger


}
logger.a_log.info "visitor factory server stopped"

