
module VisitFactory
  module Referers

    class NoReferer < Referer
      class NoRefererException < StandardError
      end


      def initialize(landing_page)
        super(landing_page)
      end

      def start_date_time
        @landing_page.start_date_time
      end
      def plan(scheduler, visitor_id)
        begin
          @landing_page.browse(scheduler, visitor_id)
        rescue Exception => e
          raise NoRefererException, e.message
        end
      end
    end
  end
end