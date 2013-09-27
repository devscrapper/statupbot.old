#!/usr/bin/env ruby -w
# encoding: UTF-8

require_relative '../../model/visit_factory/public'
module Flowing
  class Inputs
    include VisitFactory
    EOFLINE = "\n"
    def initialize()
      @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debugging)
    end

    def scheduling_visits(inputflow)
      @logger.an_event.info "#{inputflow.basename} received at #{Time.now}"
      @logger.an_event.debug inputflow
      begin
        inputflow.foreach(EOFLINE) { |visit| VisitFactory.plan(JSON.parse(visit)) }
        @logger.an_event.error "all visits of #{inputflow.basename} are built"
      rescue Exception => e
        @logger.an_event.debug e
        @logger.an_event.error "some visits of #{inputflow.basename} are not built"
      end
      #TODO archiver le flow input venant de engine Bot
      #inputflow.archive
    end
  end

end