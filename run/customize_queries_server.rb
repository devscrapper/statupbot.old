#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'rufus-scheduler'
require 'yaml'
require_relative '../lib/logging'
require_relative '../model/customize_queries_connection'
require_relative '../model/custom_gif_request/header'


include CustomizeQueries
                      #--------------------------------------------------------------------------------------------------------------------
                      # LOAD PARAMETER
                      #--------------------------------------------------------------------------------------------------------------------
CustomizeQueries.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


logger.a_log.info "parameters of proxy server :"
logger.a_log.info "visitor listening port : #{CustomizeQueries.visitor_listening_port}"
logger.a_log.info "page listening port : #{CustomizeQueries.page_listening_port}"
logger.a_log.info "proxy listening port : #{CustomizeQueries.proxy_listening_port}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"
@@logger = logger

#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
EventMachine.run {
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }



   EventMachine.start_server "127.0.0.1", CustomizeQueries.visitor_listening_port, VisitorConnection, logger
   logger.an_event.info "customize queries visitor is started"
   logger.a_log.info "customize queries server is starting"
   EM::start_server("0.0.0.0", CustomizeQueries.proxy_listening_port, HTTPHandler, logger)


}
logger.a_log.info "customize queries server stopped"

