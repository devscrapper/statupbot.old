require_relative '../../engine_search/engine_search'
module Visits
  module Referrers

    class Search < Referrer
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      include EngineSearches

      #----------------------------------------------------------------------------------------------------------------
      # attribut
      #----------------------------------------------------------------------------------------------------------------
      attr_accessor :keywords
      attr :durations,
           :engine_search

      #----------------------------------------------------------------------------------------------------------------
      # class methods
      #----------------------------------------------------------------------------------------------------------------
      def initialize(referer_details, landing_page)
        @@logger.an_event.debug "BEGIN Search.initialize"
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "keywords bad or undefine" if referer_details[:keyword][0]== "(not provided)" or referer_details[:keyword].size == 0
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "landing page undefine" if landing_page.nil?
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "durations undefine" if referer_details[:durations].nil?
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "source undefine" if referer_details[:source].nil?

        super(landing_page)

        @keywords = referer_details[:keyword]
        @durations = referer_details[:durations]

        begin
          @engine_search = EngineSearch.build(referer_details[:source])
          @@logger.an_event.debug "referrer #{self.class} create"

        rescue EngineSearches::Error => e
          @@logger.an_event.error "referrer #{self.class} not create : #{e.message}"
          raise ReferrerError.new(REFERRER_NOT_CREATE, e), "referrer #{self.class} not create"

        ensure
          @@logger.an_event.debug "END Search.initialize"
        end
      end
    end
  end
end