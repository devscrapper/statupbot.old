#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require 'pathname'
require_relative '../lib/logging'
require_relative '../model/visit_factory/public'
require_relative '../model/visit_factory/visit_factory'

include VisitFactory
#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
VisitFactory.load_parameter

logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
logger.a_log.info "parameters of visit factory server :"
logger.a_log.info "listening port : #{VisitFactory.listening_port}"
logger.a_log.info "debugging : #{$debugging}"
logger.a_log.info "staging : #{$staging}"

#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------

stop=false
while !stop
  begin

    EventMachine.run {

      Signal.trap("INT") { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }

      logger.a_log.info "visit factory server is starting"
      EventMachine.start_server "127.0.0.1", VisitFactory.listening_port, VisitFactory::BuildVisitConnection,  logger
      stop =true
    }

  rescue Exception => e
    logger.a_log.debug e
    logger.a_log.fatal e.message
    stop = false
    logger.a_log.warn "visit factory server re-start"
  end
end
logger.a_log.info "visit factory server stopped"

