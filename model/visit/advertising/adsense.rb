require_relative '../../../lib/error'

module Visits
  module Advertisings
    class Adsense < Advertising

      include Errors

      def initialize(advertiser)

        @@logger.an_event.debug "advertiser #{advertiser}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "advertiser"}) if advertiser.nil?
        #adclick.g.doubleclick.net
        #googleads.g.doubleclick.net
        #"www.googleadservices.com"

        @domains = ["googleads.g.doubleclick.net"]
        # 2014/09/08 : Adsens offre 2 solutions pour cliquer sur la pub : un titre ou un button
        # les liens sont identifiés grace à leur class HTML.
        # correction 2014/10/15 : Adsense à plusieurs façon de présenter la pub :
        # avec titre et bouton : les liens sont identifiés grace à leur class HTML : rhtitle & rhbutton
        # avec un libellé : les liens sont identifiés grace à leur class HTML : alt
        @link_identifiers = ["alt","rhtitle", "rhbutton"]
        @advertiser = advertiser

      end

      def advert (&block)
        links = []
        link = []
        begin
          @domains.each { |domain|
            @link_identifiers.each { |link_identifier|
              links += yield domain, link_identifier
            }
          }

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(ADVERT_NOT_FOUND, :error => e)

        else
          links.each { |link| @@logger.an_event.debug "advert link : #{link}" }

          if links.empty?
            raise Error.new(NONE_ADVERT, :values => {:advert => self.class})

          else
            l = links.shuffle![0]
            return [l, l.text || l.title]
          end

        ensure

        end

      end
    end

  end
end