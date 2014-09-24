require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative '../../lib/flow'
require_relative '../../lib/logging'
require_relative 'flow_list'

module Flowing
  class FlowConnection < EventMachine::Connection
    attr :logger


    def initialize(logger)
      @logger = logger
    end

    def receive_data param
      @logger.an_event.debug "data receive <#{param}>"

      begin
        Thread.new(Socket.unpack_sockaddr_in(get_peername)[1], param) { |ip_ftp_server, param1|
          close_connection
          @logger.an_event.debug "ip_ftp_server #{ip_ftp_server}"
          @logger.an_event.debug "param #{param}"
          begin
            data = YAML::load param1

            data["data"].merge!({"ip_ftp_server" => ip_ftp_server})
            type_flow = data["type_flow"]
            data_type_flow = data["data"]
            @logger.an_event.debug data
            context = []
            context << type_flow
            @logger.ndc context
            @logger.an_event.debug "type_flow <#{type_flow}>"
            @logger.an_event.debug "data type_flow <#{data_type_flow}>"
            @logger.an_event.debug "context <#{context}>"
            @logger.an_event.info "receive flow <#{data_type_flow["basename"]}>"
            case type_flow
              when "geolocations"
                Flowlist.new(data_type_flow).geolocations
              else
                Flowlist.new(data_type_flow).visit_flow
            end
          rescue Exception => e
            @logger.an_event.error "cannot manage flow <#{type_flow.gsub("-", "_")}> : #{e.message}"
          end
        }
      rescue Exception => e
        @logger.an_event.error e.message
      end

    end


  end
end