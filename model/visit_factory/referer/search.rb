module VisitFactory
  module Referers
    class Search < Referer
      class SearchException < StandardError
      end

      attr :keywords,
           :search_page

      def initialize(source, keywords, landing_page)
        @keywords = keywords
        super(landing_page)
        begin
          @search_page = VisitFactory::Ressources::SearchPage.new(source,
                                                                  landing_page.start_date_time)
        rescue Exception => e
          raise SearchException, e.message
        end
      end

      def plan(scheduler, visitor_id)
        begin
          @search_page.browse(scheduler, visitor_id, @landing_page.url, @keywords)
          @landing_page.click(scheduler, visitor_id)
        rescue Exception => e
          raise SearchException, e.message
        end
      end

      def start_date_time
        @search_page.start_date_time
      end

    end
  end
end