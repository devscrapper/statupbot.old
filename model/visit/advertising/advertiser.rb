module Visits
  module Advertisings
    class Advertiser
      attr :durations,
           :arounds


      def initialize(advertiser_details)
        @durations = advertiser_details[:durations]
        @arounds = advertiser_details[:arounds]
      end
    end

  end
end