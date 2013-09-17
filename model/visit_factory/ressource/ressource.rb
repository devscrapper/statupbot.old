require_relative '../../visitor_factory/public'
module VisitFactory
  module Ressources
    class Ressource
      class RessourceException < StandardError

      end
      attr :url
      attr_reader :start_date_time, :stop_date_time

      # {"id_uri"=>"19155",
      #"delay_from_start"=>"10",
      #"hostname"=>"centre-gironde.epilation-laser-definitive.info",
      #"page_path"=>"/ville-33-cadaujac.htm",
      #"title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}  cette variable ne sera pas utlisée car sera récupérer lors de l'exéution du scrip GA dans phantomjs
      def initialize(url, start_date_time, duration)
        @start_date_time = start_date_time
        @url = url
        @stop_date_time = @start_date_time + duration
      end

      def browse(scheduler, visitor_id)
        begin
          scheduler.at @start_date_time do
            VisitorFactory.browse_url(visitor_id, @url, @@logger)
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

require_relative 'page'
require_relative 'landing'
require_relative 'referral'
require_relative 'search'
