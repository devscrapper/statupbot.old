require 'uuid'
require_relative '../../lib/logging'
require_relative 'referer/referer'
require_relative 'ressource/ressource'
require_relative '../visitor_factory/public'

module VisitFactory
  class Visit
    class VisitException < StandardError;
    end
    DURATION = 60
    attr :start_date_time,
         :id,
         :visitor_id,
         :visitor_details,
         :referer_details,
         :pages_details,
         :referer,
         :landing_page,
         :pages

    include VisitFactory::Ressources
    include VisitFactory::Referers
    # a remplacer par un test lors du open d'une page par le raise d'une exception si absence de webdriver. (17 juin 2013)
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
    #def self.build(visits_input_flow)
    #  visits = []
    #  visits_input_flow.foreach(EOFLINE) { |visit|
    #    begin
    #      visits << Visit.new(JSON.parse(visit))
    #    rescue Exception => e
    #      @@logger.an_event.debug e
    #      raise VisitException, "visit #{visit["id_visit"]} is not built : #{e.message}"
    #    end
    #  }
    #  visits
    #end


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
    #["id_visit", "162"]
    #["start_date_time", "2013-04-21 00:09:00 +0200"]
    #["account_ga", "pppppppppppppp"]       => non repris car fourni par lexecution de la page dans phantomjs
    #["return_visitor", "true"]
    #["browser", "Firefox"]
    #["browser_version", "16.0"]
    #["operating_system", "Windows"]
    #["operating_system_version", "7"]
    #["flash_version", "11.4 r402"]
    #["java_enabled", "No"]
    #["screens_colors", "24-bit"]
    #["screen_resolution", "1366x768"]
    #["referral_path", "(not set)"]
    #["source", "(direct)"]
    #["medium", "(none)"]
    #["keyword", "(not set)"]
    #["pages", [{"id_uri"=>"19155", "delay_from_start"=>"10", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-cadaujac.htm", "title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}, {"id_uri"=>"19196", "delay_from_start"=>"15", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-le_pian_medoc_.htm", "title"=>"Centre d'\u00E9pilation laser LE PIAN M\u00C9DOC  centres de remise en forme LE PIAN M\u00C9DOC"}, {"id_uri"=>"19253", "delay_from_start"=>"39", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-yvrac.htm", "title"=>"Centre d'\u00E9pilation laser YVRAC centres de remise en forme YVRAC"}, {"id_uri"=>"115", "delay_from_start"=>"12", "hostname"=>"www.epilation-laser-definitive.info", "page_path"=>"/en/", "title"=>"Final Laser depilation"}]]
    def initialize(visit_details)

      begin
        @id = visit_details["id_visit"]
        @visitor_id = UUID.generate
        @visitor_details = {}
        @visitor_details[:id] = @visitor_id
        @visitor_details[:return_visitor] = visit_details["return_visitor"]
        @visitor_details[:browser] = visit_details["browser"]
        @visitor_details[:browser_version] = visit_details["browser_version"]
        @visitor_details[:operating_system] = visit_details["operating_system"]
        @visitor_details[:operating_system_version] = visit_details["operating_system_version"]
        @visitor_details[:flash_version] = visit_details["flash_version"]
        @visitor_details[:java_enabled] = visit_details["java_enabled"]
        @visitor_details[:screens_colors] = visit_details["screens_colors"]
        @visitor_details[:screen_resolution] = visit_details["screen_resolution"]
        @referer_details = {}
        @referer_details[:referral_path] = visit_details["referral_path"]
        @referer_details[:source] = visit_details["source"]
        @referer_details[:medium] = visit_details["medium"]
        @referer_details[:keyword] = visit_details["keyword"]
        @pages_details = visit_details["pages"]
        @landing_page = LandingPage.new(@pages_details.first, Time.parse(visit_details["start_date_time"]))
        @pages = Page.build(@pages_details.drop(1), @landing_page) if @pages_details.size > 1
        @referer = Referer.build(@referer_details, @landing_page)
        @start_date_time = @referer.start_date_time - DURATION
        @@logger.an_event.info "visit #{@id} is built with #{@referer.class}, #{@pages.size + 1} pages"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visit #{visit_details["id_visit"]} is not built"
        raise VisitException, e.message
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

        stop_date_time = Page.plan(@pages, scheduler, @visitor_id)

        scheduler.at stop_date_time do
          free_visitor
        end
        @@logger.an_event.info "free visitor of visit #{@id} is planed at #{stop_date_time}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.info "visit #{@id} is not planed"
        raise VisitException, e.message
      end

    end

#----------------------------------------------------------------------------------------------------------------
# start
#----------------------------------------------------------------------------------------------------------------
# démarre une visite :
# - assigne un visitor
# - ? send properties of referer to proxy ?
# - ? send properties of page to proxy ?
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------
    def assign_visitor
      begin
        VisitorFactory.assign_new_visitor(@visitor_details, @@logger) if @visitor_details[:return_visitor] == "false"
        #TODO valider return visitor
        @visitor_id = VisitorFactory.assign_return_visitor(@visitor_details, @@logger).pop if @visitor_details[:return_visitor] == "true"
        @@logger.an_event.info "visitor #{@visitor_id} is assign to visit #{@id}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "none visitor is assign to visit #{@id}"
        raise VisitException, e.message
      end
    end


#----------------------------------------------------------------------------------------------------------------
# stop
#----------------------------------------------------------------------------------------------------------------
# arrete une visite
# libere le visitor
# supprimer le referer, les pages
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------
    def free_visitor
      begin
        VisitorFactory.unassign_visitor(@visitor_id, @@logger)
        @@logger.an_event.info "visitor #{@visitor_id} is free"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@visitor_id} is not free"
        raise VisitException, e.message
      end
    end

  end
end