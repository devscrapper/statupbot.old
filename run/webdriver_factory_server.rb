#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require_relative '../lib/logging'
require_relative '../model/webdriver_factory_connection'

include WebdriverFactory
#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
WebdriverFactory.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


logger.a_log.info "parameters of webdriver factory server :"
logger.a_log.info "assign browser listening port : #{WebdriverFactory.assign_browser_listening_port}"
logger.a_log.info "unassign browser listening port : #{WebdriverFactory.unassign_browser_listening_port}"
logger.a_log.info "free browsers port listening : #{WebdriverFactory.free_browsers_listening_port}"
logger.a_log.info "busy browsers port listening : #{WebdriverFactory.busy_browsers_listening_port}"
logger.a_log.info "start phantomjs port listening : #{WebdriverFactory.start_phantomjs_port}"
logger.a_log.info "proxy port listening : #{WebdriverFactory::proxy_listening_port}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
EventMachine.run {
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }



  logger.a_log.info "webdriver factory server is starting"
  EventMachine.start_server "127.0.0.1", WebdriverFactory.assign_browser_listening_port, AssignBrowserConnection, logger
  EventMachine.start_server "127.0.0.1", WebdriverFactory.unassign_browser_listening_port, UnAssignBrowserConnection, logger
  EventMachine.start_server "127.0.0.1", WebdriverFactory.free_browsers_listening_port, FreeBrowsersConnection, logger
  EventMachine.start_server "127.0.0.1", WebdriverFactory.busy_browsers_listening_port, BusyBrowsersConnection, logger
}

logger.a_log.info "webdriver factory server stopped"

