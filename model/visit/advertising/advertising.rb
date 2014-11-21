require_relative '../visit'
require_relative '../../../lib/error'
module Visits
  module Advertisings
    class Advertising
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      include Errors
      #----------------------------------------------------------------------------------------------------------------
      # Message exception
      #----------------------------------------------------------------------------------------------------------------
       ARGUMENT_UNDEFINE = 1200
      ADVERTISING_NOT_BUILD = 1201
      ADVERT_NOT_FOUND = 1202
      NONE_ADVERT = 1203
      ADVERTISING_UNKNOWN = 1204
      attr_reader :domains,
                  # tableau de nom de domain de la iframe contenant les advert.
                  # IMPORTANT : si l'advert n'est pas dans un iframe alors le tableau doit contenir la chaine "nil", exemple
                  # @domains = ["nil"]
                  :link_identifiers
      # tableau d'identifiant de la balise html <a> qui heberge le lien vers l'advertiser
      # cet identifiant peut être un attribut de la balise <a> : id, class, href combiné avec une expression réguliere

      attr :advertiser # le site dont on fait la promotion
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

        @@logger.an_event.debug "advertising #{pub_details[:advertising]}"
        @@logger.an_event.debug "advertiser #{pub_details[:advertiser]}"


        begin
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => advertising}) if pub_details[:advertising].nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => advertiser}) if pub_details[:advertiser].nil? and pub_details[:advertising] != :none

          case pub_details[:advertising]
            when :none
              return NoAdvertising.new()

            when :adsense
              return Adsense.new(Advertiser.new(pub_details[:advertiser]))

            else
              @@logger.an_event.warn "advertising  #{pub_details[:advertising]} unknown"
              return NoAdvertising.new()
          end

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(ADVERTISING_NOT_BUILD, :error => e)

        else
          @@logger.an_event.debug "advertising #{self.class} build"

        ensure

        end

      end

      def to_s
        "domains : #{@domains}, link identifiers : #{@link_identifiers}, advertiser : #{@advertiser}"
      end

    end
  end
end

require_relative 'advertiser'
require_relative 'adsense'
require_relative 'no_advertising'
require_relative 'advertiser'