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
            return Bing.new(driver, sleeping_time)
          when :ask
            return Ask.new(driver, sleeping_time)
          else
            raise SearchEngineException, "search engine <#{engine}> unknown"
        end
      end

    end
  end
end

require_relative 'google'