require 'uuid'
require 'uri'
require_relative '../../lib/logging'
require_relative 'referrer/referrer'
require_relative 'advertising/advertising'


module Visits
  class Visit
    class VisitException < StandardError
      PARAM_DETAILS_MALFORMED = "visit parameters are malformed"
    end

    attr :referrer,
         :landing_url,
         :durations,
         :advertising,
         :start_date_time,
         :id,
         :visitor_details,
         :around


    include Referrers
    include Advertisings

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # build
    #----------------------------------------------------------------------------------------------------------------
    # construit les visites à partir du input flow
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # flow : published-visits_label_date_hour.json
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # crée une visite :
    # - crée le visitor, le referer, les pages
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # une visite qui est une ligne du flow : published-visits_label_date_hour.json
    # {"id_visit":"1321","start_date_time":"2013-04-21 00:13:00 +0200","account_ga":"pppppppppppppp","return_visitor":"true","browser":"Internet Explorer","browser_version":"8.0","operating_system":"Windows","operating_system_version":"XP","flash_version":"11.6 r602","java_enabled":"Yes","screens_colors":"32-bit","screen_resolution":"1024x768","referral_path":"(not set)","source":"google","medium":"organic","keyword":"(not provided)","pages":[{"id_uri":"856","delay_from_start":"33","hostname":"centre-aude.epilation-laser-definitive.info","page_path":"/ville-11-castelnaudary.htm","title":"Centre d'épilation laser CASTELNAUDARY centres de remise en forme CASTELNAUDARY"}]}
    #----------------------------------------------------------------------------------------------------------------
    def initialize(visit_details)
      begin
        @visitor_details = visit_details[:visitor_details]
        @start_date_time = visit_details[:start_date_time]
        @durations = visit_details[:durations]
        @around = (visit_details[:website][:many_hostname] == :true and visit_details[:website][:many_account_ga] == :no) ? :inside_hostname : :inside_fqdn
        @landing_url = URI.join(visit_details[:landing][:fqdn].start_with?("http") ? visit_details[:landing][:fqdn] : "http://#{visit_details[:landing][:fqdn]}",
                                visit_details[:landing][:page_path])
        @referrer = Referrer.build(visit_details[:referrer], @landing_url)
        @advertising = Advertising.build(visit_details[:advert])
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visit #{visit_details["id_visit"]} is not built"
        raise VisitException::PARAM_DETAILS_MALFORMED
      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # plan
    #----------------------------------------------------------------------------------------------------------------
    # enregistre la visite aupres du schelduler
    # planifie le referer et les pages
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def plan(scheduler)
      begin
        scheduler.at @start_date_time do
          assign_visitor
        end
        @@logger.an_event.info "assign visitor to #{@id} is planed at #{@start_date_time}"

        @referer.plan(scheduler, @visitor_id)

        Page.plan(@pages, scheduler, @visitor_id)

        #TODO VALIDATE la planification de la publcité
        @publicity.plan(scheduler, @visitor_id)

        scheduler.at @stop_date_time do
          free_visitor
        end
        @@logger.an_event.info "free visitor of visit #{@id} is planed at #{stop_date_time}"
      rescue VisitException => e
        @@logger.an_event.debug e
        @@logger.an_event.info "assign or free visitor of visit #{@id} is not plan"
        raise VisitException, e.message
      rescue ReferralException => e
        @@logger.an_event.debug e
        @@logger.an_event.info "referrer of visit #{@id} is not plan"
        raise VisitException, e.message
      rescue PublicityException => e
        @@logger.an_event.debug e
        @@logger.an_event.info "publicity of visit #{@id} is not plan"
        raise VisitException, e.message
      end

    end

  end
end