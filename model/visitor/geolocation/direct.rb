module Visitors
  module Geolocations
    class Direct < Geolocation
      class DirectException < StandardError

      end

      def initialize
        super("FR")
      end

      def update_profile(profile)
        profile['network.proxy.type'] = 5
        profile
      end
    end
  end
end