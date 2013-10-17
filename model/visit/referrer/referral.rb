require 'uri'
module Visits
  module Referrers
    class Referral < Referrer
      class ReferralException < StandardError
      end


      attr :page_url, # URI de la page referral
           :duration


      def initialize(referer_details, landing_page)
        super(landing_page)

        @page_url = referer_details[:source].start_with?("http:") ?
            URI.join(referer_details[:source], referer_details[:referral_path]) :
            URI.join("http://#{referer_details[:source]}", referer_details[:referral_path])
        @duration = referer_details[:duration]
      end

    end
  end
end
