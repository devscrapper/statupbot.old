module VisitorFactory
  module SearchEngines
    class SearchEngine
      class SearchEngineException < StandardError
      end

      def self.build(engine, driver, sleeping_time)

        case engine
          when :google
            return Google.new(driver, sleeping_time)
          when :bing
            return  #TODO developper engine Bing
          when :ask
            return  #TODO developper engine ask

          else
            raise SearchEngineException, "search engine <#{engine}> unknown"
        end
      end

    end
  end
end

require_relative 'google'