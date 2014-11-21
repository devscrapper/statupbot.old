require_relative '../../../lib/error'
module Visits
  module Advertisings
    class Advertiser
      attr :durations,
           :arounds

       include Errors

      def initialize(advertiser_details)
        @@logger.an_event.debug "durations #{advertiser_details[:durations]}"
        @@logger.an_event.debug "arounds #{advertiser_details[:arounds]}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "durations"}) if advertiser_details[:durations].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "arounds"}) if advertiser_details[:arounds].nil?

        @durations = advertiser_details[:durations]
        @arounds = advertiser_details[:arounds]
      end
    end

    def to_s
      "durations : #{@durations}, arounds : #{@arounds}"
    end

  end
end