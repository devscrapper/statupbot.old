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
      attr :durations

      #----------------------------------------------------------------------------------------------------------------
      # class methods
      #----------------------------------------------------------------------------------------------------------------
      def initialize(referer_details, landing_page)
        begin
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keyword"}) if referer_details[:keyword].size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_page"}) if landing_page.nil?

          super(landing_page)

          @keywords = referer_details[:keyword]

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