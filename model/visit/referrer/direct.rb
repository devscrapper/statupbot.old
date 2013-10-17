module Visits
  module Referrers

    class Direct < Referrer

      class DirectException < StandardError
      end


      def initialize(landing_page)
        super(landing_page)
      end

    end
  end
end