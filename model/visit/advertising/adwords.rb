require_relative '../../../lib/error'

module Visits
  module Advertisings
    class Adwords < Advertising

      attr_reader :label #libelle del l'advert adwords déclaré dans statupweb lors de la creation de la policy seaattack
      include Errors

      def initialize(label, advertiser)

        @@logger.an_event.debug "advertiser #{advertiser}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "advertiser"}) if advertiser.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "label"}) if label.nil?
        @advertiser = advertiser
        @label = label
      end

      #advert retourne un Link_element ElementStub contenant le domain de Advertiser.domain
      def advert(driver)
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "driver"}) if driver.nil?
        link = nil
        count_try = 0

        begin
          link = driver.link("/#{@label}/")

        rescue Exception => e
          @@logger.an_event.warn "#{e.message}, try #{count_try}"
          sleep 5
          count_try += 1
          retry if count_try < 3
          @@logger.an_event.error e.message
          raise Error.new(ADVERTISING_NOT_FOUND, :error => e, :values => {:advertising => self.class.name})

        else
          @@logger.an_event.info "advertising #{self.class.name} found #{@label}"

        end

        link

      end

    end
  end

end
