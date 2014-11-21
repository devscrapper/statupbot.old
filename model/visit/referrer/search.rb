require_relative '../../engine_search/engine_search'
require_relative '../../../lib/error'
module Visits
  module Referrers

    class Search < Referrer
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      include EngineSearches
      include Errors

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
        begin
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keyword"}) if referer_details[:keyword][0]== "(not provided)" or referer_details[:keyword].size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_page"}) if landing_page.nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "source"}) if referer_details[:source].nil?

          super(landing_page)

          @keywords = referer_details[:keyword]
          @engine_search = EngineSearch.build(referer_details[:source])

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(REFERRER_NOT_CREATE, :error => e)

        else
          @@logger.an_event.debug "referrer #{self.class} create"

        ensure

        end
      end
    end
  end
end