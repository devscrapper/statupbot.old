require_relative '../visit'
module Visits
  module Advertisings
    class Advertising
          #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------



      attr :advertiser
      #---------------------------------------------------------------------------------------------------------------
      # l'existence du click pour une visit est calculé par enginebot suite aux exigences de statupweb.
      # statupweb définit pour chaque Policy :
      # - le taux de click par rapport aux nombre de visites qu'il projette de faire.
      # - la régie publicitaire utilisée par le site.
      #---------------------------------------------------------------------------------------------------------------
      # publicity :
      # permet de definir la regie publicitaire utilisée dans les pages du site
      # permet de définir si la visit doit cliquer sur une pub d'une des pages de la visit
      # permet de définir la durée de surf sur le site qui a exposé la pub, sur lequel on se debranche apres avoir cliquer sur la pub
      # permet de définir le nombre de page visitées sur le site qui a exposé la pub, sur lequel on se debranche apres avoir cliquer sur la pub
      #---------------------------------------------------------------------------------------------------------------
      #---------------------------------------------------------------------------------------------------------------
      def self.build(pub_details)
        case pub_details[:advertising]
          when :none
            return NoAdvertising.new()
          when :adsense
            return Adsense.new(Advertiser.new(pub_details[:advertiser]))
          else
            @@logger.an_event.debug "pub details #{pub_details}"
            @@logger.an_event.warn "publicity #{pub_details[:advertising]} unknown"
            return NoAdvertising.new()
        end
      end



    end
  end
end
                 require_relative 'advertiser'
require_relative 'adsense'
require_relative 'no_advertising'
require_relative 'advertiser'