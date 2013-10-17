require_relative '../../engine_search/engine_search'
module Visits
  module Referrers
    include EngineSearches
    class Search < Referrer
      class SearchException < StandardError
      end

      attr :keywords,
           :durations,
           :engine_search


      def initialize(referer_details, landing_page)
        super(landing_page)
        @keywords = referer_details[:keyword]
        @durations = referer_details[:durations]

        case referer_details[:source]
          when "google"
            @engine_search = Google.new()
          when "bing"
            @engine_search = Bing.new()
          else
            raise "search engine #{source} unknown"
        end
      end


    end
  end
end