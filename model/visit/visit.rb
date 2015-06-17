require 'uuid'
require 'uri'
require_relative '../../lib/error'
require_relative '../../lib/logging'
require_relative '../page/link'
require_relative 'advertising/advertising'
require_relative 'referrer/referrer'

module Visits
  #--------------------------------------------------------------------------------------------------------------------
  # Liste des expressions regulieres en fonction du type de visite (:traffic, :advert, :rank)
  # Type visit :
  # :adword : permet de générer du revenu adword à partir d’un site
  # :Traffic : permet de générer du traffic sur un site
  # :Rank : permet de diminuer la position d’un site dans les résultats de recherche google.
  #
  # Random  search : réalise une recherche aléatoire avec un ensemble de mots clé au moyen d’un moteur de recherche
  # Random  surf : réalise une navigation aléatoire sur un site non maitrisé.
  #--------------------------------------------------------------------------------------------------------------------
  # variables utilisées dans les expressions regulieres :
  # i : nombre de pages de la visite ; issu du fichier yaml de la visite
  # j : nombre de pages visitée lors du random surf chez l'advertiser ; issu du fichier yaml de la visite
  # k : cardinalité de l'ensemble des sous chaines du mot clé final (permet atterrissage sur landing page) ; le mot clé
  # final est issu du fichier yaml de la visite ; l'ensemble des sous-chaine est calculé ; la répartition entre k' et k''
  # est aléatoire.
  #     k = k'' + k'
  # p : nombre de pages visitées lors du random surf qui précède la visite ; calculé aléaoirement entre [1-3]
  # f : index de la page de resultats du MDR dans laquelle on trouve le lien de la landing page. ; issu du fichier yaml
  # de la visite
  # q : nombre de sites visités par page de resultats du MDR avant de passer à la visite ; calculé aléaoirement entre [2-3]
  #--------------------------------------------------------------------------------------------------------------------
  # type    | random search | random suf | referrer | advertising | expression reguliere
  #--------------------------------------------------------------------------------------------------------------------
  # advert  | NON           | NON        | Direct   | OUI         | aE{i-1}FH{j-1}
  # advert  | OUI           | OUI        | Referral | OUI         | b(00{k’’}(c+f+G{p}f)){k’}1A{f-1}eDE{i-1}FH{j-1}
  # advert  | OUI           | OUI        | Search   | OUI         | b(00{k’’}(c+f+G{p}f)){k’}1A{f-1}DE{i-1}FH{j-1}
  # traffic | NON           | NON        | Direct   | NON         | aE{i-1}
  # traffic | OUI           | OUI        | Referral | NON         | b(00{k’’}(c+f+G{p}f)){k’}1A{f-1}eDE{i-1}
  # traffic | OUI           | OUI        | Search   | NON         | b(00{k’’}(c+f+G{p}f)){k’}1A{f-1}DE{i-1}
  # rank    | OUI           | NON        | Search   | NON         | b1((Cc){2,5}A){f-1}(Cc){2,5}DE{i}
  #--------------------------------------------------------------------------------------------------------------------
  # Transitions go to url     | id | Description
  #--------------------------------------------------------------------------------------------------------------------
  # go_to_start_landing       | a  | Accès à la page de démarrage du scénario qui est le landing page
  # go_to_start_search_engine | b  | Accès à la page de démarrage du scénario qui est un MDR
  # go_back 	                | c  | Accès à la page précédente.
  # go_to_landing	            | d  | Accès à la page d’atterrissage du site (referrer = direct)
  # go_to_referral	          | e  | Accès à la page du referral (referrer = referral)
  # go_to_search_engine 	    | f  | Accès à la page d’accueil du MDR (referrer = organic)
  #--------------------------------------------------------------------------------------------------------------------
  # Transitions submit form   | id | Description
  #--------------------------------------------------------------------------------------------------------------------
  # sb_search 	              | 0  | saisie des mots clés et soumission de la recherche vers le MDR.
  #                           |    | Les mots clé n’offrent qu’une liste des résultats dans laquelle n’apparait pas la
  #                           |    | landing_page.
  # sb_final_search 	        | 1  | saisie des mots clés et soumission de la recherche vers le MDR.
  #                           |    | Le mot clé permets d’offrir une liste des résultats dans laquelle apparait la
  #                           |    | landing_page.
  #--------------------------------------------------------------------------------------------------------------------
  # Transitions click link    | id | Description
  #--------------------------------------------------------------------------------------------------------------------
  # cl_on_next 	              | A  | click sur la page suivante des résultats de recherche
  # cl_on_previous 	          | B  | click sur la page précédente  des résultats de recherche
  # cl_on_result 	            | C  | click sur un résultat de recherche choisi au hasard qui n’est pas la page d’arrivée
  #                           |    | du site recherché.
  # cl_on_landing 	          | D  | click sur un résultat de recherche qui est la page d’arrivée du site recherché
  # cl_on_link_on_website 	  | E  | click sur un lien d’une page du site ciblé, choisit au hasard
  # cl_on_advert	            | F  | click sur un advert présent dans la page du site
  # cl_on_link_on_unknown	    | G  | click sur un lien d’une page d’un site inconnu, choisit au hasard
  # cl_on_link_on_advertiser  |	H  | click sur un lien d’une page d’un site inconnu, choisit au hasard
  #--------------------------------------------------------------------------------------------------------------------

  class Visit
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Advertisings
    include Referrers

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
    # variable de classe
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :landing_link, #Object Pages::Link
                :regexp #expression reguliere définissant le scénario d'exécution de la visit

    attr :actions, # liste des actions de la visite : construit à partir de la regexp
         :referrer,
         :durations,
         :start_date_time,
         :id,
         :visitor_details,
         :around #perimètre de recherche des link (domain, sous domain)


    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.load(file_path)
      @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

      begin
        @@logger.an_event.debug "file_path #{file_path}"
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "file_path"}) if file_path.nil?
        raise Error.new(VISIT_NOT_FOUND, :values => {:path => file_path}) unless File.exist?(file_path)

        visit_file = File.open(file_path, "r:BOM|UTF-8:-")
        visit_details = YAML::load(visit_file.read)
        visit_file.close

        @@logger.an_event.debug "visit_details #{visit_details}"

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISIT_NOT_LOAD, :values => {:file => file_path}, :error => e)

      else
        @@logger.an_event.info "visit file #{file_path} loaded"
        visit_details

      ensure

      end
    end

    def self.build(visit_details)

      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visit_details"}) if visit_details.nil? or visit_details.empty?

      begin

        case visit_details[:type]
          when :traffic
            visit = Traffic.new(visit_details)

          when :advert
            visit = Advert.new(visit_details)

          when :rank
            visit = Rank.new(visit_details)

          else

        end

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISIT_NOT_CREATE, :values => {:id => visit_details[:id_visit]}, :error => e)

      else
        @@logger.an_event.info "visit #{visit.id} has #{visit.actions.size} actions : #{visit.actions}"
        @@logger.an_event.debug "visit #{visit.to_s}"
        visit

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def script
      @actions.split("")
    end

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
      @@logger.an_event.debug "durations #{visit_details[:durations]}"

      begin

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "id_visit"}) if visit_details[:id_visit].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor"}) if visit_details[:visitor].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "start_date_time"}) if visit_details[:start_date_time].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "many_hostname"}) if visit_details[:website][:many_hostname].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "many_account_ga"}) if visit_details[:website][:many_account_ga].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing link fqdn"}) if visit_details[:landing][:fqdn].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing link path"}) if visit_details[:landing][:path].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing link scheme"}) if visit_details[:landing][:scheme].nil?

        @id = visit_details[:id_visit]
        @visitor_details = visit_details[:visitor]
        @start_date_time = visit_details[:start_date_time]
        @durations = visit_details[:durations]
        @around = (visit_details[:website][:many_hostname] == :true and visit_details[:website][:many_account_ga] == :no) ? :inside_hostname : :inside_fqdn

        @landing_link = Pages::Link.new("#{visit_details[:landing][:scheme]}://#{visit_details[:landing][:fqdn]}#{visit_details[:landing][:path]}")

        @referrer = Referrer.build(visit_details[:referrer])


      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise e

      else
        @@logger.an_event.debug "visit #{@id} initialize"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # next_duration
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : la duration suivante de la liste
    #----------------------------------------------------------------------------------------------------------------
    def next_duration
      @durations.first
    end

    def to_s
      "id : #{@id} \n" +
      "landing link : #{@landing_link} \n" +
      "regexp : #{@regexp} \n" +
      "actions : #{@actions} \n" +
      "referrer : #{@referrer} \n" +
      "durations : #{@durations} \n" +
      "start date time : #{@start_date_time} \n" +
      "around : #{@around} \n"
    end

  end
end


require_relative 'traffic'
require_relative 'advert'
require_relative 'rank'