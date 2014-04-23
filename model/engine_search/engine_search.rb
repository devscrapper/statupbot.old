module EngineSearches
  class FunctionalError < StandardError
  end
  class EngineSearch

    attr :page_url,
         :tag_search, :id_search
    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    SEARCH_ENGINE_UNKNOWN = "search engine is unknown"

    def self.build(engine) #, driver, sleeping_time)   pour webdriver

      case engine
        when "google"
          return Google.new()
        #   when "bing"
        #     return Bing.new()
        else
          @@logger.an_event.debug  "search engine <#{engine}> unknown"
          raise FunctionalError, SEARCH_ENGINE_UNKNOWN
      end
    end


  end
end

require_relative 'google'
require_relative 'bing'