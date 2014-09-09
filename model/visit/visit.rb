require 'uuid'
require 'uri'
require_relative '../../lib/logging'
require_relative 'referrer/referrer'
require_relative 'advertising/advertising'
require_relative '../../lib/error'

module Visits


  class Visit
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    #    include Referrers
    include Advertisings

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    class VisitError < Error
    end
    ARGUMENT_UNDEFINE = 700
    VISIT_NOT_CREATE = 701
    VISIT_NOT_FOUND = 702
    VISIT_NOT_LOAD = 703

    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    ARCHIVE = Pathname(File.join(File.dirname(__FILE__), "..", "..", "archive")).realpath
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :landing_url
    attr :referrer,
         :durations,
         :advertising,
         :start_date_time,
         :id,
         :visitor_details,
         :around


    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(file_path)
      @@logger.an_event.debug "BEGIN Visit.build"

      @@logger.an_event.debug "file_path #{file_path}"
      raise VisitError.new(ARGUMENT_UNDEFINE), "file_path undefine" if file_path.nil?
      raise VisitError.new(VISIT_NOT_FOUND), "visit file #{file_path} not found" unless File.exist?(file_path)

      begin
        visit_file = File.open(file_path, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)
        visit_file.close
        @@logger.an_event.info "visit file #{file_path} load"
      rescue Exception => e
        @@logger.an_event.error "visit file #{file_path} not load : #{e.message}"
        raise VisitError.new(VISIT_NOT_LOAD), "visit file #{file_path} not load"
      else
        return visit_details
      ensure
        @@logger.an_event.debug "END Visit.build"

      end
    end

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
      @@logger.an_event.debug "BEGIN Visit.initialize"

      @@logger.an_event.debug "id_visit #{visit_details[:id_visit]}"
      @@logger.an_event.debug "visitor #{visit_details[:visitor]}"
      @@logger.an_event.debug "start_date_time #{visit_details[:start_date_time]}"
      @@logger.an_event.debug "many_hostname #{visit_details[:website][:many_hostname]}"
      @@logger.an_event.debug "many_account_ga #{visit_details[:website][:many_account_ga]}"
      @@logger.an_event.debug "fqdn #{visit_details[:landing][:fqdn]}"
      @@logger.an_event.debug "page_path #{visit_details[:landing][:page_path]}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "id_visit undefine" if visit_details[:id_visit].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "visitor undefine" if visit_details[:visitor].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "start_date_time undefine" if visit_details[:start_date_time].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "many_hostname undefine" if visit_details[:website][:many_hostname].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "many_account_ga undefine" if visit_details[:website][:many_account_ga].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "fqdn undefine" if visit_details[:landing][:fqdn].nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "page_path undefine" if visit_details[:landing][:page_path].nil?


      begin
        @id = visit_details[:id_visit]
        @visitor_details = visit_details[:visitor]
        @start_date_time = visit_details[:start_date_time]
        @durations = visit_details[:durations]
        @around = (visit_details[:website][:many_hostname] == :true and visit_details[:website][:many_account_ga] == :no) ? :inside_hostname : :inside_fqdn
        @landing_url = URI.join(visit_details[:landing][:fqdn].start_with?("http") ? visit_details[:landing][:fqdn] : "http://#{visit_details[:landing][:fqdn]}", visit_details[:landing][:page_path])
        @referrer = Referrer.build(visit_details[:referrer], @landing_url)
        @advertising = Advertising.build(visit_details[:advert])

        @@logger.an_event.debug "visit #{@id} is create"

      rescue Error => e
        @@logger.an_event.error "visit #{visit_details[:id_visit]} not create #{e.message}"
        raise VisitError.new(VISIT_NOT_CREATE, e), "visit #{visit_details[:id_visit]} not create"
      rescue Exception => e
        @@logger.an_event.error "visit #{visit_details[:id_visit]} not create #{e.message}"
        raise VisitError.new(VISIT_NOT_CREATE), "visit #{visit_details[:id_visit]} not create"
      ensure
        @@logger.an_event.debug "END Visit.initialize"
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # advertising?
    #----------------------------------------------------------------------------------------------------------------
    # retourne true si la visit prévoit une publicité.
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def advertising?
      !@advertising.is_a?(NoAdvertising)
    end

    #----------------------------------------------------------------------------------------------------------------
    # plan
    #----------------------------------------------------------------------------------------------------------------
    # enregistre la visite aupres du schelduler
    # planifie le referer et les pages
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
=begin
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
=end

  end
end


