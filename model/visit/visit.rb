require 'uuid'
require 'uri'
require_relative '../../lib/error'
require_relative '../../lib/logging'
require_relative 'advertising/advertising'


module Visits


  class Visit
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Advertisings

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------

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
    attr :referrer
    attr :durations
    attr :advertising
    attr :start_date_time
    attr :id
    attr :visitor_details
    attr :around


    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(file_path)
      begin

        @@logger.an_event.debug "file_path #{file_path}"
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "file_path"}) if file_path.nil?
        raise Error.new(VISIT_NOT_FOUND, :values => {:path => file_path}) unless File.exist?(file_path)


        visit_file = File.open(file_path, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)
        visit_file.close

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISIT_NOT_CREATE, :values => {:path => file_path}, :error => e)

      else
        @@logger.an_event.info "visit file #{file_path} create"
        return visit_details

      ensure

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

      @@logger.an_event.debug "id_visit #{visit_details[:id_visit]}"
      @@logger.an_event.debug "visitor #{visit_details[:visitor]}"
      @@logger.an_event.debug "start_date_time #{visit_details[:start_date_time]}"
      @@logger.an_event.debug "many_hostname #{visit_details[:website][:many_hostname]}"
      @@logger.an_event.debug "many_account_ga #{visit_details[:website][:many_account_ga]}"
      @@logger.an_event.debug "fqdn #{visit_details[:landing][:fqdn]}"
      @@logger.an_event.debug "page_path #{visit_details[:landing][:page_path]}"

      begin

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "id_visit"}) if visit_details[:id_visit].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor"}) if visit_details[:visitor].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "start_date_time"}) if visit_details[:start_date_time].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "many_hostname"}) if visit_details[:website][:many_hostname].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "many_account_ga"}) if visit_details[:website][:many_account_ga].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "fqdn"}) if visit_details[:landing][:fqdn].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "page_path"}) if visit_details[:landing][:page_path].nil?

        @id = visit_details[:id_visit]
        @visitor_details = visit_details[:visitor]
        @start_date_time = visit_details[:start_date_time]
        @durations = visit_details[:durations]
        @around = (visit_details[:website][:many_hostname] == :true and visit_details[:website][:many_account_ga] == :no) ? :inside_hostname : :inside_fqdn
        @landing_url = URI.join(visit_details[:landing][:fqdn].start_with?("http") ? visit_details[:landing][:fqdn] : "http://#{visit_details[:landing][:fqdn]}", visit_details[:landing][:page_path])
        @referrer = Referrer.build(visit_details[:referrer], @landing_url)
        @advertising = Advertising.build(visit_details[:advert])

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise e

      else
        @@logger.an_event.debug "visit #{@id} initialize"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # advertising?
    #----------------------------------------------------------------------------------------------------------------
    # retourne true si la visit prévoit une publicité.
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    #TODO à supprimer
    def advertising?
      !@advertising.is_a?(NoAdvertising)
    end

  end
end


