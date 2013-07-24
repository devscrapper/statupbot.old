#!/usr/bin/env ruby -w
# encoding: UTF-8

require_relative '../visit'

module Flowing
  class Inputs

    def initialize()
      @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debugging)
    end

    def scheduling_visits(inputflow)
      @logger.an_event.info "#{inputflow.basename } received at #{Time.now}"
      @logger.an_event.debug inputflow
      begin
        Visit.build(inputflow).each { |visit|

          begin
            Scheduler.plan(visit)
            @logger.an_event.info "visit #{visit.id} ask planning at #{visit.start_date_time}"
          rescue Exception => e
            @logger.an_event.debug e
            @logger.an_event.error "visit #{visit.id} is not plan at #{visit.start_date_time}"
          end
        }
      rescue Exception => e
        @logger.an_event.debug e
        @logger.an_event.error "visits are not build"
      end
      #TODO archiver le flow
      #inputflow.archive
    end
  end

end