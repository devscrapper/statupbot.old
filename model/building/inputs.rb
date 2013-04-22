#!/usr/bin/env ruby -w
# encoding: UTF-8
require 'socket'
require "ruby-progressbar"

module Flowing

  SEPARATOR1=";"
  SEPARATOR2="|"
  SEPARATOR3=","
  EOFLINE ="\n"

  class Inputs

    def initialize()
      @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debugging)
    end

    def toto(inputflow)
      @logger.an_event.info "#{inputflow.basename } received at #{Time.now}"
      @logger.an_event.debug inputflow
    end
  end

end