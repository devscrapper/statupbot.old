require_relative '../../engine_search/engine_search'
module Visits
  module Referrers
    include EngineSearches
    class Search < Referrer
      class SearchException < StandardError
        KEYWORDS_NOT_PROVIDE = "keywords missing"
      end

      attr :keywords,
           :durations,
           :engine_search


      def initialize(referer_details, landing_page)
        raise SearchException::KEYWORDS_NOT_PROVIDE if referer_details[:keyword]== "(not provided)"  or \
                                                        referer_details[:keyword] ==""
        super(landing_page)

        @keywords = referer_details[:keyword]
        @durations = referer_details[:durations]

        case referer_details[:source]
          when "google"
            @engine_search = Google.new()
          when "bing"
            @engine_search = Bing.new()
          else
            raise "search engine #{referer_details[:source]} unknown"
        end
      end


    end
  end
end