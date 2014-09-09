module Visits
  module Advertisings
    class Adsense < Advertising


      def initialize(advertiser)
        @@logger.an_event.debug "BEGIN Adsense.initialize"

        @@logger.an_event.debug "advertiser #{advertiser}"

        raise AdvertisingError.new(ARGUMENT_UNDEFINE), "advertiser undefine" if advertiser.nil?

        @domains = ["googleads.g.doubleclick.net"]
        # 2014/09/08 : Adsens offre 2 solutions pour cliquer sur la pub : un titre ou un button
        # les liens sont identifiés grace à leur class HTML.
        @link_identifiers = ["rhtitle", "rhbutton"]
        @advertiser = advertiser

        @@logger.an_event.debug "END Adsense.initialize"
      end


    end

  end
end