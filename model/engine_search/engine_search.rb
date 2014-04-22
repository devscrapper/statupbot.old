module EngineSearches
  class EngineSearch
    class FunctionalError < StandardError
    end
    attr :page_url,
         :tag_search, :id_search

    def self.build(engine) #, driver, sleeping_time)   pour webdriver

      case engine
        when "google"
          return Google.new()
        when "bing"
          return Bing.new()
        else
          raise FunctionalError, "search engine <#{engine}> unknown"
      end
    end


  end
end

require_relative 'google'
require_relative 'bing'