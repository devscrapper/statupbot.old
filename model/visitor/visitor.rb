require_relative 'geolocation/geolocation'
require_relative 'nationality/nationality'
require_relative '../../model/browser/webdriver/browser'
require_relative '../../model/browser/sahi.co.in/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require 'pathname'

#require_relative 'customize_queries_connection'
#require_relative 'custom_gif_request/custom_gif_request'
#TODO reviser globalement la gestion des erreurs et des exceptions
module Visitors
  class FunctionalError < StandardError
    VISIT_NOT_DEFINE = "visit is not define"
    REFERRER_NOT_DEFINE = "referrer is not define"

    CANNOT_CLICK_ON_LINK_OF_LANDING_URL = "visitor cannot click on link of landing url"
    LINK_OF_LANDING_URL_NOT_FOUND = "referrer not found link of landing url in results pages search"
    NONE_SEARCH_NOT_FOUND_LANDING_LINK = "none keywords found link of landing url in search"
    SEARCH_NOT_FOUND_LANDING_LINK = "keywords found link of landing url in search"
    NO_MORE_RESULT_PAGE = "no more results pages"
    CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE = "cannot click on link of next page"
    LANDING_PAGE_NOT_FOUND = "landing page not found"
    CANNOT_CONTINUE_SURF = "visitor cannot surf"
  end
  class TechnicalError < StandardError

  end
  include Geolocations
  include Nationalities
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings

  class Visitor
    #TODO à supprimer
    class VisitorException < StandardError
      CANNOT_CREATE_DIR = "visitor cannot create runtime directory"
      CANNOT_OPEN_BROWSER = "visitor cannot open browser"
      CANNOT_CONTINUE_VISIT = "visitor cannot continue visit"
      NOT_FOUND_LANDING_PAGE = "visitor #{@id} not found landing page"

      CANNOT_CLOSE_BROWSER = "visitor #{@id} cannot close his browser"
      CANNOT_DIE = "visitor cannot die"
      DIE_DIRTY = "visitor die dirty"
      BAD_KEYWORDS = "keywords are bad"
    end

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    REFERRER_NOT_DISPLAY_START_PAGE = "referrer not display start page"
    REFERRER_NOT_FOUND_LANDING_PAGE = "referrer not found landing page"
    REFERRAL_NOT_FOUND_LANDING_LINK = "referral not found landing link in referral page"
    SEARCH_NOT_FOUND_LANDING_LINK = "search not found landing link in results page"
    PARAM_NOT_DEFINE = "some parameter not define"
    CANNOT_SURF = "cannot suf"
    PARAM_BROWSER_MISTAKEN = "param browser mistaken"

    DIR_VISITORS = Pathname(File.join(File.dirname(__FILE__), '..', '..', 'visitors')).realpath
    attr_accessor :id,
                  :browser,
                  :home, #repertoire d'execution du visitor
                  :proxy, #sahi : utilise le proxy sahi
                  # webdriver : n'utilise pas le proxy
                  :geolocation # webdriver : utilise la geolocation car il n'y a pas de proxy,
    # sahi : n'utilise pas geolocation car pris en charge par le proxy sahi

    #  include CustomGifRequest
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(visitor_details)
      #exist_pub_in_visit = true si il existe une pub dans la visit alors on utilise un browser de type webdriver
      #sinon un browser de type sahi
      @@logger.an_event.debug "begin build visitor"
      @@logger.an_event.debug "visitor detail #{visitor_details}"

      begin
        # Pour le moment on ne travaille qu'avec SAHI
        return Visitor.new(visitor_details, :sahi)
        @@logger.an_event.info "visitor is built"

      rescue Exception => e
        @@logger.an_event.debug e.message
        raise e
      end
      @@logger.an_event.info "visitor #{visitor_details[:id]} is born"
      @@logger.an_event.debug "end build visitor"
    end

#----------------------------------------------------------------------------------------------------------------
# instance methods
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------------------------------------------------
# crée un visitor :
# - crée le visitor, le browser, la geolocation
#----------------------------------------------------------------------------------------------------------------
# input :
# une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
#["return_visitor", "true"]
#["browser", "Firefox"]
#["browser_version", "16.0"]
#["operating_system", "Windows"]
#["operating_system_version", "7"]
#["flash_version", "11.4 r402"]
#["java_enabled", "No"]
#["screens_colors", "24-bit"]
#["screen_resolution", "1366x768"]
#----------------------------------------------------------------------------------------------------------------
    def initialize(visitor_details, browser_type)
      @@logger.an_event.debug "begin initialize visitor"
      raise FunctionalError, "visitor details is not define" if visitor_details.nil?

      @id = visitor_details[:id]

      if browser_type == :sahi
        @home = File.join(DIR_VISITORS, @id)
        @@logger.an_event.info "visitor #{@id} create runtime directory #{@home}"
        begin
          # on fait du nettoyage pour eviter de perturber le proxy avec un paramètrage bancal
          if File.exist?(@home)
            FileUtils.rm_r(@home, :force => true) if File.exist?(@home)
            @@logger.an_event.debug "clean config files visitor dir #{@home}"
          end
          FileUtils.mkdir_p(@home)
        rescue Exception => e
          @@logger.an_event.fatal e
          raise TechnicalError, "visitor #{@id} cannot create runtime directory #{@home}"
          @@logger.an_event.debug "end initialize visitor"
        end
        #------------------------------------------------------------------------------------------------------------
        #
        #Configure SAHI PROXY
        #
        #------------------------------------------------------------------------------------------------------------
        begin
          @proxy = Browsers::SahiCoIn::Proxy.new(@home,
                                                 visitor_details[:browser][:listening_port_proxy],
                                                 visitor_details[:browser][:proxy_ip],
                                                 visitor_details[:browser][:proxy_port],
                                                 visitor_details[:browser][:proxy_user],
                                                 visitor_details[:browser][:proxy_pwd])
          @@logger.an_event.info "visitor #{@id} configure sahi proxy on listening port = #{@proxy.listening_port_proxy}"
        rescue Browsers::FunctionalError => e
          @@logger.an_event.debug e.message
          raise FunctionalError, "configuration of proxy sahi of visitor #{@id} is mistaken"
          @@logger.an_event.debug "end initialize visitor"

        rescue Browsers::TechnicalError => e
          @@logger.an_event.debug e.message
          raise TechnicalError, "cannot build proxy sahi of visitor #{@id}"
          @@logger.an_event.debug "end initialize visitor"
        end

        #------------------------------------------------------------------------------------------------------------
        #
        # configure Browser
        #
        #------------------------------------------------------------------------------------------------------------
        begin
          @browser = Browsers::SahiCoIn::Browser.build(@home,
                                                       visitor_details[:browser])
          @@logger.an_event.info "visitor #{@id} configure browser #{@browser.name} #{@browser.id}"
        rescue FunctionalError => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end initialize visitor"
          raise FunctionalError, PARAM_BROWSER_MISTAKEN

        rescue TechnicalError => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end initialize visitor"
          raise TechnicalError, e.message
        end

        #------------------------------------------------------------------------------------------------------------
        #
        # start SAHI PROXY
        #
        #------------------------------------------------------------------------------------------------------------
        begin
          @proxy.start #demarrage du proxy sahi
          @@logger.an_event.info "visitor #{@id} start sahi proxy pid = #{@proxy.pid}"
        rescue TechnicalError => e
          @@logger.an_event.debug e.message
          raise TechnicalError, "cannot start proxy sahi of visitor #{@id}"
          @@logger.an_event.debug "end initialize visitor"
        end

        @browser.deploy_properties(@home) if @browser.is_a?(Browsers::SahiCoIn::Opera)
      else
        #@geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
        #                                   #TODO peut on partager les proxy entre visiteur de site different ?
        #@browser = Browsers::Webdriver::Browser.build(visitor_details[:browser])
        #@browser.profile = @geolocation.update_profile(@browser.profile)
      end
    end

    def browse(referrer)
      @@logger.an_event.debug "begin browse referrer"
      raise FunctionalError::REFERRER_NOT_DEFINE if referrer.nil?
      #TODO à checker
      landing_page = nil

      case referrer
        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer DIRECT
        #
        #---------------------------------------------------------------------------------------------------------------
        when Direct
          begin
            landing_page = @browser.display_start_page(referrer.landing_url, @id)
            @@logger.an_event.info "visitor #{@id} browse start page"
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise FunctionalError, REFERRER_NOT_DISPLAY_START_PAGE
          end

        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer REFERRAL
        #
        #---------------------------------------------------------------------------------------------------------------
        when Referral
          referral_page = nil
          landing_link = nil
          begin
            referral_page = @browser.display_start_page(referrer.page_url, @id)
            @@logger.an_event.info "visitor #{@id} browse start page"
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise FunctionalError, REFERRER_NOT_DISPLAY_START_PAGE
          end

          @@logger.an_event.info "visitor #{@id} found referral page #{referral_page.url.to_s}"
          referral_page.duration = referrer.duration
          read(referral_page)

          begin
            landing_link = referral_page.link_by_url(referrer.landing_url)
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise FunctionalError, REFERRAL_NOT_FOUND_LANDING_LINK
          end


          begin
            landing_page = @browser.click_on(landing_link)
            @@logger.an_event.info "visitor #{@id} click on landing url #{landing_link.url.to_s}"
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise TechnicalError, REFERRER_NOT_FOUND_LANDING_PAGE
          end

        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer SEARCH
        #
        #---------------------------------------------------------------------------------------------------------------
        when Search
          referrer.keywords = [referrer.keywords] if referrer.keywords.is_a?(String)
          begin
            @browser.display_start_page(referrer.engine_search.page_url, @id)
            @@logger.an_event.info "visitor #{@id} browse start page"
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise FunctionalError, REFERRER_NOT_DISPLAY_START_PAGE
          end

          begin
            landing_link = many_search(referrer)
            @@logger.an_event.info "visitor #{@id} see link of landing url"
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise FunctionalError, SEARCH_NOT_FOUND_LANDING_LINK
          end

          begin
            landing_page = @browser.click_on(landing_link)
            @@logger.an_event.info "visitor #{@id} click on landing url #{landing_link.url.to_s}"
          rescue Exception => e
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end browse referrer"
            raise TechnicalError, REFERRER_NOT_FOUND_LANDING_PAGE
          end
      end
      @@logger.an_event.debug "end browse referrer"
      landing_page
    end


    def close_browser
      @@logger.an_event.debug "begin visitor close browser"
      begin
        @browser.quit
        @@logger.an_event.info "visitor #{@id} close his browser #{@browser.name} #{@browser.id}"
      rescue TechnicalError => e
        @@logger.an_event.error e.message
        raise TechnicalError, "visitor #{@id} cannot close browser #{@browser.name} #{@browser.id}"
      ensure
        @@logger.an_event.debug "end visitor close browser"
      end
    end


    def die
      @@logger.an_event.debug "begin visitor die"
      begin
        @proxy.stop
        @@logger.an_event.info "visitor #{@id} is dead"
      rescue TechnicalError => e
        @@logger.an_event.error e.message
        raise TechnicalError, "visitor #{@id} cannot die"
      ensure
        @@logger.an_event.debug "end visitor die"
      end
    end

    def execute_save(visit)
      begin
        landing_page = browse(visit.referrer)
        page = surf(visit.durations, landing_page, visit.around)
        if !visit.advertising.is_a?(NoAdvertising)
          advertiser = visit.advertising.advertiser
          advert_link = visit.advertising.advert_on(page)
          if advert_link.nil?
            @@logger.an_event.warn "advertising #{visit.advertising.class} not found on page #{page.url}"
          else
            advertiser_page = @browser.click_on(advert_link)
            page = surf(advertiser.durations, advertiser_page, advertiser.arounds)
          end
        end
      rescue Exception => e
        #TODO si erreur tehcnique irrémediable => nettoyage complet et remonté une exception spéciale
        #TODO si erruer fonctionnelle => pas de nettoyage et remonté de lerreur fontionnelle
        @@logger.an_event.debug e
        raise e
      end
    end

    def execute(visit)
      @@logger.an_event.debug "begin execute visit"
      raise FunctionalError::VISIT_NOT_DEFINE if visit.nil?

      landing_page = nil
      begin
        landing_page = browse(visit.referrer)
      rescue FunctionalError::CANNOT_DISPLAY_START_PAGE => e
        @@logger.an_event.debug e.message
        @@logger.an_event.error "visitor #{@id} cannot browser start page"
        @@logger.an_event.debug "end execute visit"
        raise e
      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} not found landing page"
        @@logger.an_event.debug "end execute visit"
        raise FunctionalError::LANDING_PAGE_NOT_FOUND
      end


      @@logger.an_event.debug "end execute visit"
    end

    def inhume()
      @@logger.an_event.debug "begin visitor inhume"
      try_count = 0
      max_try_count = 3
      begin
        @proxy.delete_config
        FileUtils.rm_r(@home) if File.exist?(@home)
        @@logger.an_event.info "visitor #{@id} is inhume"
      rescue Exception => e
        @@logger.an_event.debug "visitor #{@id} is not inhume, try #{try_count}"
        sleep (1)
        try_count +=1
        retry if try_count < max_try_count
        @@logger.an_event.debug e.message
        raise TechnicalError, "visitor #{@id} is not inhume"
      ensure
        @@logger.an_event.debug "end visitor inhume"
      end
    end

    #-----------------------------------------------------------------------------------------------------------------
    # many_search
    #-----------------------------------------------------------------------------------------------------------------
    # input : objet Referrer
    # output : un objet Page
    # exception :
    # FunctionalError :
    # si Referrer n'est pas defini
    # si landing_link not found dans les pages de resultats de toutes les recherches
    #-----------------------------------------------------------------------------------------------------------------
    # permet de realiser plusieurs recherche avec à chaque fois une list de mot clé différent
    # cette liste de mot clé sera calculé par scraperbot en fonction d'un paramètage de statupweb
    # cela permetra par exemple de realisé des recherches qui échouent
    #-----------------------------------------------------------------------------------------------------------------
    def many_search(referrer)
      @@logger.an_event.debug "begin many_search avec referrer"
      #TODO meo plusieurs methodes pour saisir les mots clés et les choisir aléatoirement :
      #TODO afficher la page google.fr, comme c'est le cas actuellement
      #TODO dans la derniere page des resultats, saisir les nouveaux mot clés dans la zone idoine.
      raise FunctionalError::REFERRER_NOT_DEFINE if referrer.nil?
      i = 0
      landing_link = nil
      begin
        landing_link = search(referrer.keywords[i],
                              referrer.engine_search,
                              referrer.durations.map { |d| d },
                              referrer.landing_url)
      rescue Exception => e
        @@logger.an_event.debug e.message
        i+=1
        if i < referrer.keywords.size
          retry
        else
          @@logger.an_event.debug "end many_search avec referrer"
          raise FunctionalError::NONE_SEARCH_NOT_FOUND_LANDING_LINK
        end

      end
      @@logger.an_event.debug "end many_search avec referrer"
      landing_link
    end


    def open_browser
      @@logger.an_event.debug "begin visitor open browser"
      begin
        @browser.open
        @@logger.an_event.info "visitor #{@id} open browser #{@browser.name} #{@browser.id}"
      rescue TechnicalError => e
        @@logger.an_event.error e.message
        raise TechnicalError, "visitor #{@id} cannot open browser #{@browser.name} #{@browser.id}"
      ensure
        @@logger.an_event.debug "end visitor open browser"
      end
    end

    def read(page)
      @@logger.an_event.info "visitor #{@id} read page #{page.url} during #{page.sleeping_time}s (= #{page.duration} - #{page.duration_search_link})"
      @browser.wait_on(page)
    end

    #-----------------------------------------------------------------------------------------------------------------
    # search
    #-----------------------------------------------------------------------------------------------------------------
    # input :
    # keywords : les mots de la recherche
    # engine_search : le moteur utilisé pou la recherche
    # durations : le temps d'attente pas page de résultat de la recherche, fixe egalement le nombre de page de la recherche
    # landing_url : l'url recherchée dans chaque page de résultat
    # output : un objet Page
    # exception :
    # FunctionalError :
    # si keywords n'est pas defini
    # si engine_search n'est pas défini
    # di durations n'est pas défini
    # si landing url n'est pas defini
    # si landing_link not found dans les pages de resultats de la recherche avce ces mots clés
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def search(keywords, engine_search, durations, landing_url)
      @@logger.an_event.debug "begin search keyword with engine search"
      #---------------------------------------------------------------------------------------------------------------
      #
      # search keyword in engine
      #
      #---------------------------------------------------------------------------------------------------------------
      begin
        @@logger.an_event.info "visitor #{@id} search landing page #{landing_url} with keywords #{keywords} on #{engine_search.class}"
        results_page = @browser.search(keywords, engine_search)
      rescue Exception => e
      end
      #---------------------------------------------------------------------------------------------------------------
      #
      # parcours les pages de resultats selon duration
      #
      #---------------------------------------------------------------------------------------------------------------
      i = 0
      landing_link = nil
      begin
        results_page.duration = durations[i]
        read(results_page)
        landing_link = engine_search.exist_link?(results_page, landing_url)
      rescue Exception => e
        i += 1
        if i < durations.size
          begin
            next_page_link = engine_search.next_page_link(results_page, i + 1)
          rescue Exception => e
            # le nombre de page de resultat est inférieur au nombre de pages attendues
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end search keyword with engine search"
            raise FunctionalError::NO_MORE_RESULT_PAGE
          end

          begin
            results_page = @browser.click_on(next_page_link)
          rescue Exception => e
            #un erreur survient lors du click sur le lien de la page suivante.
            @@logger.an_event.debug e.message
            @@logger.an_event.debug "end search keyword with engine search"
            raise TechnicalError::CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE
          end
          retry # on recommence le begin
        else
          #toutes les pages ont été passées en revue et le landing link n'a pas été trouvé
          @@logger.an_event.debug "end search keyword with engine search"
          raise FunctionalError::SEARCH_NOT_FOUND_LANDING_LINK
        end
      end
      # on a trouvé le landing_link
      @@logger.an_event.debug "landing_url is found "
      @@logger.an_event.debug "end search keyword with engine search"
      landing_link
    end

    #-----------------------------------------------------------------------------------------------------------------
    # surf
    #-----------------------------------------------------------------------------------------------------------------
    # input :
    # durations : un tableau de durée de lecture de chaucne des pages
    # page : la page de départ
    # around : un tableau de périmètre de sélection des link pour chaque page
    # output : un objet Page : la derniere
    # exception :
    # FunctionalError :
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------

    def surf(durations, page, around)
      # le surf sur le website prend en entrée un around => arounds est rempli avec cette valeur
      # le surf sur l'advertiser predn en entrée un array de around pré calculé par engine bot en fonction des paramètre saisis au moyen de statupweb
      @@logger.an_event.debug "durations #{durations.inspect}"
      @@logger.an_event.debug "page #{page.to_s}"
      @@logger.an_event.debug "arounds #{around.inspect}"

      raise FunctionalError, PARAM_NOT_DEFINE if durations.nil? or
          durations.size == 0 or
          page.nil? or
          around.nil? or
          around.size == 0

      begin
        arounds = (around.is_a?(Array)) ? around : Array.new(durations.size, around)
        durations.each_index { |i|
          page.duration = durations[i]
          read(page)
          if i < durations.size - 1
            link = page.link_by_around(arounds[i])
            page = @browser.click_on(link)
          end # on ne clique pas quand on est sur la denriere page
        }
        page
      rescue TechnicalError, Exception => e
        @@logger.an_event.debug e.message
        @@logger.an_event.error "visitor #{@id} stop surf at page #{page.url}"
        raise FunctionalError, CANNOT_SURF
      end
    end
  end


end