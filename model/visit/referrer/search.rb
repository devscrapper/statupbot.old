require_relative '../../engine_search/engine_search'
module Visits
  module Referrers
    include EngineSearches
    class Search < Referrer


      attr :keywords,
           :durations,
           :engine_search


      def initialize(referer_details, landing_page)
        raise FunctionalError, "bad keywords for search referrer" if referer_details[:keyword][0]== "(not provided)"
        raise FunctionalError, "keywords for search referrer are not define" if referer_details[:keyword].size == 0
        super(landing_page)

        @keywords = referer_details[:keyword]
        @durations = referer_details[:durations]
        begin
          @engine_search = EngineSearch.build(referer_details[:source])
        rescue EngineSearches::FunctionalError => e
          @@logger.an_event.debug e.message
          raise FunctionalError, e.message
        rescue FunctionalError => e
          @@logger.an_event.debug e.message
           raise e
        rescue Exception => e
          @@logger.an_event.debug e.message
            raise FunctionalError, "search referrer is not create"
        end

        #case referer_details[:source]
        #  when "google"
        #    @engine_search = Google.new()
        #  when "bing"
        #    @engine_search = Bing.new()
        #  else
        #    raise "search engine #{referer_details[:source]} unknown"
        #end
      end


    end
  end
end