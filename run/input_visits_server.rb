#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'yaml'
require_relative '../lib/logging'
require_relative '../lib/parameter'
require_relative '../model/visit/connection'
#TODO declarer le server comme un service windows

#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
rescue Exception => e
  $stderr << e.message   << "\n"
else
  $staging = parameters.environment
  $debugging = parameters.debugging
  listening_port = parameters.listening_port
  logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


  logger.a_log.info "parameters of input flows server :"
  logger.a_log.info "listening port : #{listening_port}"
  logger.a_log.info "debugging : #{$debugging}"
  logger.a_log.info "staging : #{$staging}"

  if listening_port.nil? or
      $debugging.nil? or
      $staging.nil?
    $stderr << "some parameters not define"   << "\n"
    exit(1)
  end


  include Visits
#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
  begin
    EventMachine.run {
      Signal.trap("INT") { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }

      logger.a_log.info "input flows server is starting"
      EventMachine.start_server "0.0.0.0", listening_port, Connection, logger
    }
  rescue Exception => e
    logger.a_log.fatal e.message
    logger.a_log.warn "input flow server restart"
    retry
  end
  logger.a_log.info "input flows server stopped"

end