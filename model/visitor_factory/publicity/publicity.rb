module VisitorFactory
  module Publicities
    class Publicity
      #-----------------------------------------------------------------------------------------------------
      # Publicity permet de sélectionner la régie publicitaire présente sur le site.
      # La régie aura au préalable choisie par le proprietaire du site lors des Policy définies au moyen de StatupWeb
      # La régie publicitaire est donc positionnée lors de la définition de la Policy avec StatupWeb
      class PublicityException < StandardError

      end
      attr :driver

      def self.build(advertising, driver)
        case advertising
          when :adsense
            publicities = Adsense.build(driver)
            publicities.each { |pub| pub.log }
            return publicities.shuffle[0]
          else
            raise PublicityException, "advertising #{advertising} unknown"
        end
      end


      def initialize(driver)
        @driver = driver
      end


    end
  end
end

require_relative "adsense"
require_relative 'advertiser'