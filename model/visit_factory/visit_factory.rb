require 'rubygems' # if you use RubyGems
require 'eventmachine'
require 'rufus-scheduler'
require_relative 'visit'
module VisitFactory
  @@scheduler = Rufus::Scheduler::start_new
  @@logger = nil
  #--------------------------------------------------------------------------------------------------------------------
  # Communication
  #--------------------------------------------------------------------------------------------------------------------
  class BuildVisitConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visit_details)
      close_connection
      @@logger.an_event.debug visit_details
      begin
        Visit.new(visit_details).plan(@@scheduler)
      rescue Exception => e
        @@logger.an_event.debug e
      end

    end
  end


end