require_relative '../../model/building/inputs'
require_relative '../flow'

module Flowing
  class Flowlist
    class FlowlistException < StandardError;
    end
    INPUT = File.dirname(__FILE__) + "/../../input"

    attr :last_volume,
         :input_flow,
         :logger

    def initialize(data)
      @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debugging)
      @last_volume = data["last_volume"]
      @input_flow = Flow.from_basename(INPUT, data["basename"])
      @input_flow.get(data["ip_ftp_server"], data["port_ftp_server"], data["user"], data["pwd"])
    end

    def published_visits()
      execute { Inputs.new.toto(@input_flow) } if @last_volume
    end


    private
    def execute (&block)
      begin
        yield
      rescue Exception => e
        @logger.an_event.debug e
        raise FlowlistException, e
      end
    end
  end
end
