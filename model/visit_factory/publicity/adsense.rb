module VisitFactory
  module Publicities
    class Adsense < Publicity
      DURATION_VISIT_MIN = 60
      ADVERTISING = :adsens
      attr_reader :duration_pages

      def initialize(start_date_time)
        #TODO VALIDATE le comportement du navigateur avec l'annonceur Adsense
        count_page = Random.new.rand(5..15) # le nombre de page de la visit est compris entre 5 & 15
        duration_visit = Random.new.rand(10..30) # la durée de la visit est comprise en tre 10 & 30 mn
        @duration_pages = distributing(count_page, duration_visit * 60, DURATION_VISIT_MIN)
        super(start_date_time, start_date_time + duration_visit * 60)
      end

      def plan(scheduler,visitor_id)
        begin
          scheduler.at @start_date_time do
            VisitorFactory.click_pub(visitor_id, @duration_pages, ADVERTISING, @@logger)
          end
          @@logger.an_event.info "click on publicity #{self.class} is planed at #{@start_date_time}"
        rescue Exception => e
          @logger.an_event.debug e
          @@logger.an_event.error "cannot plan click on publicity #{self.class}"
          raise RessourceException, e.message
        end
      end
    end
  end
end