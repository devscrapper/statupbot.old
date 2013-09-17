module VisitFactory
  module Referers
    class Referral < Referer
      class ReferralException < StandardError
      end


      attr :referral_page

      def initialize(source, referral_path, landing_page)
        begin
          super(landing_page)

          @referral_page = VisitFactory::Ressources::Referral.new(source,
                                                                  referral_path,
                                                                  landing_page.start_date_time)
        rescue Exception => e
          raise ReferralException, e.message
        end
      end

      def start_date_time
        @referral_page.start_date_time
      end

      def plan(scheduler, visitor_id)
        begin
          @referral_page.browse(scheduler, visitor_id)
          @landing_page.click(scheduler, visitor_id)
        rescue Exception => e
          raise ReferralException, e.message
        end
      end

    end
  end
end
