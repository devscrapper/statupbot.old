module Visits
  module Advertisings
    class Advertiser
      attr :durations,
           :arounds


      def initialize(advertiser_details)
        @@logger.an_event.debug "BEGIN Advertiser.initialize"

        @@logger.an_event.debug "durations #{advertiser_details[:durations]}"
        @@logger.an_event.debug "arounds #{advertiser_details[:arounds]}"

        raise AdvertisingError.new(ARGUMENT_UNDEFINE), "durations undefine" if advertiser_details[:durations].nil?
        raise AdvertisingError.new(ARGUMENT_UNDEFINE), "arounds undefine" if advertiser_details[:arounds].nil?

        @durations = advertiser_details[:durations]
        @arounds = advertiser_details[:arounds]

        @@logger.an_event.debug "END Advertiser.initialize"
      end
    end

    def to_s
      "durations : #{@durations}, arounds : #{@arounds}"
    end

  end
end