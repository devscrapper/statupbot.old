module Visits
  module Referrers

    class Direct < Referrer


      def initialize(landing_page)
        @@logger.an_event.debug "BEGIN Direct.initialize"
        super(landing_page)
        @@logger.an_event.debug "END Direct.initialize"
      end

    end
  end
end