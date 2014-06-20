require_relative '../../model/building/inputs'
require_relative '../../lib/flow'
require_relative '../../lib/logging'
require 'pathname'

module Flowing
  class Flowlist
    class FlowlistError < StandardError;
    end
    INPUT = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'input')).realpath

    attr :last_volume,
         :input_flow,
         :logger

    def initialize(data)
      @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debugging)
      @last_volume = data["last_volume"]
      @input_flow = Flow.from_basename(INPUT, data["basename"])
      begin
        @input_flow.get(data["ip_ftp_server"], data["port_ftp_server"], data["user"], data["pwd"])
      rescue Exception => e
        @logger.an_event.error "input flow #{@input_flow.basename} not download : #{e.message}"
      else
        @logger.an_event.info "input flow #{@input_flow.basename} download"
      end
    end

    def visit_flow
      execute { Inputs.new.send_to_visitor_factory(@input_flow) }
    end

    private
    def execute (&block)
      begin
        yield
      rescue Exception => e
        #@logger.an_event.debug e
        raise FlowlistError, e
      end
    end
  end
end
