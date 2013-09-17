require_relative '../../visitor_factory/public'

module VisitFactory
  module Ressources

    class Page < Ressource
      class PageException < StandardError;
      end

      attr :id

      def self.plan(pages, scheduler, visitor_id)
        last_date_time = Time.now
        begin
          pages.each { |page|
            page.click(scheduler, visitor_id)
            last_date_time = page.stop_date_time
          }
        rescue Exception => e
          raise PageException, e.message
        end
        last_date_time
      end

      def self.build(pages_details, landing_page)
        pages = []
        start_date_time = landing_page.stop_date_time
        begin
          pages_details.each { |page|
            p = Page.new(page, start_date_time)
            pages << p
            start_date_time = p.stop_date_time
          }
        rescue Exception => e
          raise PageException, e.message
        end
        pages
      end

      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # initialize
      #----------------------------------------------------------------------------------------------------------------
      # crée une page :
      #
      #----------------------------------------------------------------------------------------------------------------
      # input :
      # les infos détails d'une page présente dans le fichiers d'input
      #----------------------------------------------------------------------------------------------------------------
      # {"id_uri"=>"19155",
      #"delay_from_start"=>"10",
      #"hostname"=>"centre-gironde.epilation-laser-definitive.info",
      #"page_path"=>"/ville-33-cadaujac.htm",
      #"title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}  cette variable ne sera pas utlisée car sera récupérer lors de l'exéution du scrip GA dans phantomjs
      def initialize(page_details, start_date_time_page)
        @id = page_details["id_uri"]
        super("#{page_details["hostname"]}#{page_details["page_path"]}",
              start_date_time_page,
              page_details["delay_from_start"].to_i)
      end

#----------------------------------------------------------------------------------------------------------------
# click
#----------------------------------------------------------------------------------------------------------------
# planifie le click sur une url d'un page active dans le navigateur
#----------------------------------------------------------------------------------------------------------------
# input : scheduler, visitor_id
#----------------------------------------------------------------------------------------------------------------
      def click(scheduler, visitor_id)
        begin
          scheduler.at @start_date_time do
            VisitorFactory.click_url(visitor_id, @url, @@logger)
          end
          @@logger.an_event.info "click on url #{@url} is planed at #{@start_date_time}"
        rescue Exception => e
          @logger.an_event.debug e
          @@logger.an_event.error "cannot plan click of #{self.class} #{@url}"
          raise RessourceException, e.message
        end
      end
    end
  end
end