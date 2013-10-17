module Visits
    module Advertisings
    class Adsense < Advertising
              #TODO VALIDATE le comportement du navigateur avec l'annonceur Adsense
      ID = [/doubleclick.net/, /googleadservices.com/]

      def initialize(advertiser)
        @advertiser = advertiser
      end
      def advert_on(page)
        # retourne nil si pas de advert
        advert_link = page.link_by_hostname(ID)
        @@logger.an_event.debug "chosen adsense link #{advert_link.url}"
        advert_link
      end
    end

  end
end