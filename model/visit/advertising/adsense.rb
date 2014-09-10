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

      def advert  (&block)
        @@logger.an_event.debug "BEGIN Adsense.advert"

        links = []
        link = nil
        begin
          @domains.each { |domain|
            @link_identifiers.each { |link_identifier|
              links += yield domain, link_identifier
            }
          }
          links.each { |link| @@logger.an_event.debug "advert link : #{link}" }
        rescue Error => e
          @@logger.an_event.error "advert Adsens not found : #{e.message}"
          raise AdvertisingError.new(ADVERT_NOT_FOUND), "advert Adsens not found : #{e.message}"
        else
          link = links.shuffle![0]
        ensure
          @@logger.an_event.debug "END Adsense.advert"
          return link
        end

      end
    end

  end
end