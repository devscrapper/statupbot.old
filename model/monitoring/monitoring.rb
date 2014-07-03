require 'eventmachine'
require 'em/protocols'

require_relative '../../lib/error'
module Monitoring
  #--------------------------------------------------------------------------------------------------------------------
  # Global variables
  #--------------------------------------------------------------------------------------------------------------------
  @@logger = nil
  @@return_codes = nil
  @@return_codes_stat = nil
  @@count_visits = nil
  @@count_success = nil
  @@pools_size_stat = nil
  @@visits_out_of_time_stat = nil
  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class ReturnCodeConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(return_codes, return_codes_stat, count_visits, count_success, logger, opts)
      @@logger = logger
      @@return_codes = return_codes
      @@return_codes_stat = return_codes_stat
      @@count_visits = count_visits
      @@count_success = count_success
    end


    def receive_object(data)
      begin
        port, ip = Socket.unpack_sockaddr_in(get_peername)
        @@count_visits[0] += 1
        if data[:return_code].code == 0
          @@count_success[0] += 1
          Monitoring.add_stat(Date.today,
                              data[:return_code].code,
                              @@return_codes_stat)
          @@logger.an_event.info "register success for visit #{data[:visit_details]} from #{ip}"
        else
          add_error(data)
          @@logger.an_event.info "register return code #{data[:return_code].code} for visit #{data[:visit_details]} from #{ip}"
        end
      rescue Exception => e
        @@logger.an_event.error "not register return code #{data[:return_code].code} for visit #{data[:visit_details][:id_visit]}from #{ip} : #{e.message}"
      ensure
        close_connection
      end
    end


    def add_error(data)

      history = data[:return_code].history

      if data[:visit_details].is_a?(String)
        # si une erreur survient lors du chargement du fichier de visit alors, on a passé le nom du fichier de la visit en remplacement du hash de la visit
        Monitoring.add_history(history,
                               @@return_codes,
                               {"no_id_visit" => data[:visit_details]})
        Monitoring.add_stat(Date.today,
                            data[:return_code].origin_code || data[:return_code].code,
                            @@return_codes_stat)

      end

      if data[:visit_details].is_a?(Hash)
        Monitoring.add_history(history,
                               @@return_codes,
                               {data[:visit_details][:id_visit] =>
                                    {:visitor => data[:visit_details][:visitor][:id],
                                     :browser => {:name => data[:visit_details][:visitor][:browser][:name],
                                                  :version => data[:visit_details][:visitor][:browser][:version],
                                                  :operating_system => data[:visit_details][:visitor][:browser][:operating_system],
                                                  :operating_system_version => data[:visit_details][:visitor][:browser][:operating_system_version]},
                                     :referrer => data[:visit_details][:referrer]}
                               })
        Monitoring.add_stat(Date.today,
                            data[:return_code].origin_code || data[:return_code].code,
                            @@return_codes_stat)

      end
    end
  end

  class PoolSizeConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(pools_size, logger, opts)
      @@logger = logger
      @@pools_size_stat = pools_size
    end


    def receive_object(pool_size)
      begin
        port, ip = Socket.unpack_sockaddr_in(get_peername)
        #@@pools_size_stat[Time.now.strftime("%F : %Hh")] = pool_size
        pool_size.each_pair { |browser_type, pool_size|
          Monitoring.add_stat(Date.today,
                              browser_type,
                              @@pools_size_stat,
                              pool_size)

        }

        @@logger.an_event.info "register pool size #{@@pools_size_stat} from #{ip}"

      rescue Exception => e
        @@logger.an_event.error "not register pool size : #{e.message}"
      ensure
        close_connection
      end
    end
  end

  class VisitOutOfTimeConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(visit_out_of_time, logger, opts)
      @@logger = logger
      @@visits_out_of_time_stat = visit_out_of_time
    end


    def receive_object(pattern)
      begin
        port, ip = Socket.unpack_sockaddr_in(get_peername)
        Monitoring.add_stat(Date.today,
                            pattern,
                            @@visits_out_of_time_stat)

        @@logger.an_event.info "register visit out of time #{@@visits_out_of_time_stat} from #{ip}"

      rescue Exception => e
        @@logger.an_event.error "not register visit out of time : #{e.message}"
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


  def add_stat(key1, key2, stats_universe, value = 1)
    if stats_universe[key1].nil?
      stats_universe[key1] = {}
    end
    if stats_universe[key1][key2].nil?
      stats_universe[key1][key2] = value
    else
      if value == 1
        stats_universe[key1][key2] += value
      else
        stats_universe[key1][key2] = value > stats_universe[key1][key2] ? value : stats_universe[key1][key2]
      end
    end
  end

  def logger(logger)
    @@logger = logger
  end


  module_function :logger
  module_function :add_history
  module_function :add_stat


end