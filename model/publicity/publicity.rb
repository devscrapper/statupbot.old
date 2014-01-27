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
            return Adsense.build(driver)
          else
            raise PublicityException, "advertising #{advertising} unknown"
        end
      end

      def self.go_to_frame(driver, path_crt_frame)
        begin
          driver.switch_to.default_content
          path_crt_frame.each { |frame| driver.switch_to.frame(frame) }
        rescue Exception => e
          raise PublicityException, "frame not found"
        end
      end

      def self.advertising_exist?(advertising, link)
        pub_exist = false
        advertising.each { |ad| pub_exist ||= !link.match(ad).nil? }
        pub_exist
      end

      def self.publicities(driver, advertising, path_crt_frame=[], crt_frame=nil)
        path_crt_frame << crt_frame unless crt_frame.nil?
        Publicity.go_to_frame(driver,path_crt_frame)

        pubs = driver.find_elements(:tag_name, "a")
        pubs.select! { |l| !l[:href].nil? and \
                            Publicity.advertising_exist?(advertising, l[:href]) and
                            l.displayed? and l.enabled?
        } # conserve que les liens qui sont apportés par advertising
        pubs.uniq! { |p| p[:href] } #supprimer les mulitple occurences des mêmes publicité
        pubs = (pubs.size > 0) ? pubs.map { |link| [Array.new(path_crt_frame), link] } : [] # associe à chaque lien, la frame dans laquelle il se trouve

        driver.find_elements(:tag_name, "iframe").each { |frame|
          pubs += Publicity.publicities(driver, advertising, path_crt_frame, frame)

          path_crt_frame.pop
          Publicity.go_to_frame(driver,path_crt_frame)
        }
        pubs
      end
      def initialize(driver)
        @driver = driver
      end
    end
  end
end

require_relative "adsense"
require_relative 'advertiser'