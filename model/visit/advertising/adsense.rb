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

        @domain = "googleads.g.doubleclick.net"
        @advertiser = advertiser

      end

      #advert retourne un Link_element ElementStub) contenant dans les zones advert identifiées par <frame>
      def advert(frames)
        @@logger.an_event.debug "frames #{frames}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "frames"}) if frames.nil? or frames.empty?
        link = nil
        links = []
        count_try = 0

        begin
          for f in frames
            links += f.link("/.*ca-pub.*/").collect_similar

            @@logger.an_event.debug "frame #{f} count links #{links.size}"

          end
          @@logger.an_event.debug "count links #{links.size}"

          raise "no advert link found" if links.empty?

        rescue Exception => e
          @@logger.an_event.warn "#{e.message}, try #{count_try}"
          sleep 5
          count_try += 1
          retry if count_try < 3
          @@logger.an_event.error e.message
          raise Error.new(NONE_ADVERT, :error => e)

        else
          for l in links
            @@logger.an_event.debug "advert link #{l}"
          end
          link = links.sample
          @@logger.an_event.debug "advert link chosen #{link}"

        end

        link

      end

    end
  end

end
