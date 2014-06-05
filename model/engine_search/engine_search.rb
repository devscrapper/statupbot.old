 require_relative '../../lib/error'

module EngineSearches
  class EngineSearch
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    class EngineSearchError < Error

    end
    ARGUMENT_UNDEFINE = 900
    SEARCH_ENGINE_UNKNOWN = 901
    ENGINE_NOT_FOUND_LANDING_LINK = 903
    ENGINE_NOT_FOUND_NEXT_LINK = 904

    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr :page_url,
         :tag_search, :id_search

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(engine) #, driver, sleeping_time)   pour webdriver
      @@logger.an_event.debug "BEGIN EngineSearch.build"
      case engine
        when "google"
          return Google.new()
        #   when "bing"
        #     return Bing.new()
        else
          @@logger.an_event.warn "engine search <#{engine}> unknown"
          raise EngineSearchError.new(SEARCH_ENGINE_UNKNOWN), "engine search <#{engine}> unknown"
      end
    rescue Exception => e
      @@logger.an_event.debug e.message
      raise e
    ensure
      @@logger.an_event.debug "END EngineSearch.build"
    end
  end
end

require_relative 'google'
require_relative 'bing'