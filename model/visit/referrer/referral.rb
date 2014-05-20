require 'uri'
module Visits
  module Referrers
    class Referral < Referrer

      attr :page_url, # URI de la page referral
           :duration


      def initialize(referer_details, landing_page)
        @@logger.an_event.debug "BEGIN Referral.initialize"

        raise ReferrerError.new(ARGUMENT_UNDEFINE), "referral_path undefine" if landing_page[:referral_path].nil?
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "durations undefine" if referer_details[:duration].nil?
        raise ReferrerError.new(ARGUMENT_UNDEFINE), "source undefine" if referer_details[:source].nil?

        super(landing_page)

        begin
          @page_url = referer_details[:source].start_with?("http:") ?
              URI.join(referer_details[:source], referer_details[:referral_path]) :
              URI.join("http://#{referer_details[:source]}", referer_details[:referral_path])
          @duration = referer_details[:duration]

        rescue Exception => e
          @@logger.an_event.error "referrer #{self.class} not create : #{e.message}"
          raise ReferrerError.new(REFERRER_NOT_CREATE, e), "referrer #{self.class} not create"

        ensure
          @@logger.an_event.debug "END Referral.initialize"
        end
      end

    end
  end
end
