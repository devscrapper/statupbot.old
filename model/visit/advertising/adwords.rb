require_relative '../../../lib/error'

module Visits
  module Advertisings
    class Adwords < Advertising

      attr_reader :labels # array de libelles de l'advert adwords déclaré dans statupweb
      include Errors

      def initialize(labels, advertiser)

        @@logger.an_event.debug "labels #{labels}"
        @@logger.an_event.debug "advertiser #{advertiser}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "advertiser"}) if advertiser.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "labels"}) if labels.nil?
        @advertiser = advertiser
        @labels = labels
      end

      #advert retourne un Link_element ElementStub contenant le domain de Advertiser.domain
      def advert(browser)
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser"}) if browser.nil?
        link = nil

        begin
          adwords = browser.engine_search.adverts(browser.body)
          adwords.each { |adword| @@logger.an_event.debug "adword : #{adword}" }

          #TODO remplacer @labels par @fqdns
          @labels.each { |label| @@logger.an_event.debug "labels : #{label}" }
          tmp_fqdns = @labels.dup

          # suppression des adwords dont le href n'est pas dans liste de fqdn
          href_adwords =[]
          adwords.map { |adword| adword[:href] }.each { |href|
            tmp_fqdns.each { |fqdn|
              href_adwords << href if href.include?(fqdn)
            }
          }

          raise "none labels advertisings #{@labels} found in adwords list #{adwords}" if href_adwords.empty?

          links = href_adwords.map { |href| browser.driver.link("#{href}") }
          @@logger.an_event.debug "links : #{links}"

          links.delete_if { |link| !link.exists? }
          @@logger.an_event.debug "links : #{links}"

          raise "none label advertising visible" if links.empty?

          link = links.shuffle[0]
          @@logger.an_event.debug "link : #{link}"

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(ADVERTISING_NOT_FOUND, :error => e, :values => {:advertising => self.class.name})

        else
          @@logger.an_event.info "advertising #{self.class.name} found #{link}"

        end

        link

      end

    end
  end

end
