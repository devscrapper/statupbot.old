require 'eventmachine'
require_relative '../../model/error'
module Monitoring
  #--------------------------------------------------------------------------------------------------------------------
  # Global variables
  #--------------------------------------------------------------------------------------------------------------------
  @@logger = nil
  @@return_codes = nil
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class ReturnCodeConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(return_codes, logger, opts)
      @@logger = logger
      @@return_codes = return_codes
    end


    def receive_object(data)
      begin
        port, ip = Socket.unpack_sockaddr_in(get_peername)

        history = data[:return_code].history
        if data[:visit_details].is_a?(String)
          # si une erreur survient lors du chargement du fichier de visit alors, on a passé le nom du fichier de la visit en remplacement du hash de la visit
          Monitoring.add_history(history,
                                 @@return_codes,
                                 {"no_id_visit" => data[:visit_details]})
          @@logger.an_event.info "register return code #{data[:return_code].code} for visit #{data[:visit_details]} from #{ip}"
        end
        if data[:visit_details].is_a?(Hash)
          Monitoring.add_history(history,
                                 @@return_codes,
                                 {data[:visit_details][:id_visit] =>
                                      {:browser => {:name => data[:visit_details][:visitor][:browser][:name],
                                                    :version => data[:visit_details][:visitor][:browser][:version],
                                                    :operating_system => data[:visit_details][:visitor][:browser][:operating_system],
                                                    :operating_system_version => data[:visit_details][:visitor][:browser][:operating_system_version]},
                                       :referrer => data[:visit_details][:referrer]}
                                 })
          @@logger.an_event.info "register return code #{data[:return_code].code} for visit #{data[:visit_details][:id_visit]} from #{ip}"
        end
      rescue Exception => e
        @@logger.an_event.error "not register return code #{data[:return_code].code} for visit #{data[:visit_details][:id_visit]}from #{ip} : #{e.message}"
      ensure
        close_connection
      end
    end
  end

  def add_history(history, return_codes, visit_details)
    if history.empty?
      return_codes[:visit_details] = return_codes[:visit_details].nil? ? visit_details : return_codes[:visit_details].merge(visit_details)
    else
      rc = history.pop
      if return_codes[rc].nil?
        return_codes[rc] = {}
      end
      Monitoring.add_history(history, return_codes[rc], visit_details)
    end
  end

  def logger(logger)
    @@logger = logger
  end


  module_function :logger
  module_function :add_history

end