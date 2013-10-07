module VisitFactory
  module Publicities
    class NoPublicity < Publicity
      def initialize(start_date_time)
        @start_date_time = start_date_time
        @stop_date_time = start_date_time
      end

      def plan(scheduler, visitor_id)
        @@logger.an_event.info "none publicity is plan"
      end
    end
  end
end