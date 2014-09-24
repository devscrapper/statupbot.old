require_relative '../../model/building/inputs'
require_relative '../../lib/flow'
require_relative '../../lib/logging'
require 'pathname'

module Flowing
  class Flowlist
    class FlowlistError < StandardError;
    end
    INPUT = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'input')).realpath
    TMP = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp')).realpath

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


    def geolocations

      @logger.an_event.debug @input_flow.to_s

      raise "inputflow #{@input_flow.absolute_path} not found" unless @input_flow.exist?

      begin

        geolocations_flow = @input_flow.cp(TMP)
        @logger.an_event.info "copy input flow #{@input_flow.basename} to #{geolocations_flow.absolute_path}"

        @input_flow.delete
        @logger.an_event.info "delete input flow #{@input_flow.absolute_path}"

        geolocations_flow.archive_previous
      rescue Exception => e

        @logger.an_event.error "geolocations #{@input_flow.basename} not send to visitor factory : #{e.message}"
        raise "geolocations #{@input_flow.basename} not send to visitor factory"

      else

        @logger.an_event.info "geolocations #{@input_flow.basename} send to visitor factory"

      end

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
