require_relative '../../visitor_factory/public'
module VisitFactory
  module Ressources
    class SearchPage
      class SearchPageException< StandardError

      end
      #Ces 2 constantes détermineront le date_start_time du SearcPage :
      DURATION = 5 # tps attente en seconde du chargement de la page de resultat sur le browser pour éviter d'avoir des erreurs de non chargement
      COUNT_MAX_PAGE = 5 #nombre de page maximun de resultats de la recherche qui seront passé en revue pour trouver landing page
      attr :search_engine
      attr_reader :start_date_time

      def initialize (source, start_date_time_landing_page)
        @start_date_time = start_date_time_landing_page - DURATION * (COUNT_MAX_PAGE + 1)
        case source
          when "google"
            @search_engine = :google
          when "bing"
            @search_engine = :bing
          else
            raise SearchException, "organic source #{source} unknown"
        end
      end


      def browse(scheduler, visitor_id, landing_page_url, keywords)
        begin
          scheduler.at @start_date_time do
            VisitorFactory.search_url(visitor_id, @search_engine, landing_page_url, keywords, DURATION, COUNT_MAX_PAGE, @@logger)
          end
          @@logger.an_event.info "browse of #{self.class} #{@url} is planed at #{@start_date_time}"
        rescue Exception => e
          @logger.an_event.debug e
          @@logger.an_event.error "cannot plan browse of #{self.class} #{@url}"
          raise RessourceException, e.message
        end
      end
    end
  end
end