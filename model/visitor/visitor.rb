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
  include Geolocations
  include Nationalities
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings

  class Visitor
    class VisitorException < StandardError
      CANNOT_CREATE_DIR = "visitor cannot create runtime directory"
      CANNOT_OPEN_BROWSER = "visitor cannot open browser"
      CANNOT_CONTINUE_VISIT = "visitor cannot continue visit"
      NOT_FOUND_LANDING_PAGE = "visitor #{@id} not found landing page"
      CANNOT_CONTINUE_SURF = "visitor cannot surf"
      CANNOT_CLOSE_BROWSER = "visitor #{@id} cannot close his browser"
      CANNOT_DIE = "visitor cannot die"
      DIE_DIRTY = "visitor die dirty"
      BAD_KEYWORDS = "keywords are bad"
    end

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
    def self.build(visitor_details, exist_pub_in_visit,
        listening_port_sahi_proxy = nil, proxy_ip=nil, proxy_port=nil, proxy_user=nil, proxy_pwd=nil)
      #exist_pub_in_visit = true si il existe une pub dans la visit alors on utilise un browser de type webdriver
      #sinon un browser de type sahi
      begin
        return Visitor.new(visitor_details,
                           (exist_pub_in_visit == true) ? :webdriver : :sahi,
                           listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd) if visitor_details[:return_visitor] == :true
        return Visitor.new(visitor_details,
                           (exist_pub_in_visit == true) ? :webdriver : :sahi,
                           listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd) unless visitor_details[:return_visitor] == :true
        @@logger.an_event.info "visitor is built"
      rescue Exception => e
        @@logger.an_event.error "visitor is not built"
        @@logger.an_event.debug e
        raise e
      end
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
    def initialize(visitor_details, browser_type,
        listening_port_sahi_proxy = nil, proxy_ip=nil, proxy_port=nil, proxy_user=nil, proxy_pwd=nil)

      @id = visitor_details[:id]
      @home = File.join(DIR_VISITORS, @id)
      begin
        FileUtils.mkdir_p(@home)
        if browser_type == :sahi
          @proxy = Browsers::SahiCoIn::Proxy.new(@home,
                                                 listening_port_sahi_proxy,
                                                 proxy_ip, proxy_port, proxy_user, proxy_pwd)

          visitor_details[:browser][:listening_port_proxy] = listening_port_sahi_proxy
          @browser = Browsers::SahiCoIn::Browser.build(@home,
                                                       visitor_details[:browser])
          @proxy.start #demarrage du proxy sahi

          @browser.deploy_properties(@home) if @browser.is_a?(Browsers::SahiCoIn::Opera)
        else
          #@geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
          #                                   #TODO peut on partager les proxy entre visiteur de site different ?
          #@browser = Browsers::Webdriver::Browser.build(visitor_details[:browser])
          #@browser.profile = @geolocation.update_profile(@browser.profile)
        end
      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} dead born"
        @@logger.an_event.debug e
        raise e
      end
    end

    def browse_old(referrer)
      begin
        @browser.display_start_page
        case referrer
          when Direct
            return @browser.display(referrer.landing_url)
          when Referral
            referral_page = @browser.display(referrer.page_url)
            referral_page.duration = referrer.duration
            read(referral_page)
            return @browser.click_on(referral_page.link_by_url(referrer.landing_url))
          when Search
            landing_link_found, landing_link = search(referrer.keywords,
                                                      referrer.engine_search,
                                                      referrer.durations,
                                                      referrer.landing_url) if referrer.keywords.is_a?(String)
            landing_link_found, landing_link = many_search(referrer) if referrer.keywords.is_a?(Array)
            return @browser.click_on(landing_link) if landing_link_found
            raise VisitorException, "keyword : #{referrer.keywords}" unless landing_link_found
        end
      rescue VisitorException => e
        @@logger.an_event.error "visitor #{@id} not found landing page #{referrer.landing_url}"
        @@logger.an_event.debug e
        raise VisitorException::NOT_FOUND_LANDING_PAGE
      end
    end

    def browse(referrer)
      begin

        case referrer
          when Direct
            #start_page = @browser.display_start_page(referrer.landing_url)
            #return @browser.click_on(start_page.link_by_url(referrer.landing_url))
            return @browser.display_start_page(referrer.landing_url)
          when Referral
            referral_page = @browser.display_start_page(referrer.page_url)
            #start_page = @browser.display_start_page(referrer.page_url)
            #referral_page = @browser.click_on(start_page.link_by_url(referrer.page_url))
            referral_page.duration = referrer.duration
            read(referral_page)
            return @browser.click_on(referral_page.link_by_url(referrer.landing_url))
          when Search
            referrer.keywords = [referrer.keywords] if referrer.keywords.is_a?(String)
           # start_page = @browser.display_start_page(referrer.engine_search.page_url)
           # @browser.click_on(start_page.link_by_url(referrer.engine_search.page_url))
            @browser.display_start_page(referrer.engine_search.page_url)
            landing_link_found, landing_link = many_search(referrer)
            return @browser.click_on(landing_link) if landing_link_found
            raise VisitorException, "keyword : #{referrer.keywords}" unless landing_link_found
        end
      rescue VisitorException => e
        @@logger.an_event.error "visitor #{@id} not found landing page #{referrer.landing_url}"
        @@logger.an_event.debug e
        raise VisitorException::NOT_FOUND_LANDING_PAGE
      end
    end


    def close_browser
      begin
        @browser.quit
        @@logger.an_event.info "visitor #{@id} has closed his browser"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error VisitorException::CANNOT_CLOSE_BROWSER
        raise VisitorException::CANNOT_CLOSE_BROWSER
      end
    end

    def die
      #TODO ne pas supprimer le context d'execution du visitor lorsque y il y a eu une erreur technique
      #TODO supprimer la log du visitor dans \log quand tout est OK
      begin
        @proxy.stop
        FileUtils.rm_r(@home, :force => true) if File.exist?(@home)
        @@logger.an_event.debug "visitor #{@id} die"
      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} cannot die"
        @@logger.an_event.debug e
        raise VisitorException::CANNOT_DIE
      end
    end

    def execute(visit)
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


  #permet de realiser plusieurs recherche avec à chaque fois une list de mot clé différent
  # cette liste de mot clé sera calculé par scraperbot en fonction d'un paramètage de statupweb
  # cela permetra par exemple de realisé des recherches qui échouent
  def many_search(referrer)
    #TODO meo plusieurs methodes pour saiir les mots clés et les choisir aléatoirement :
    #TODO afficher la page google.fr, comme c'est le cas actuellement
    #TODO dans la derniere page des resultats, saisir les nouveaux mot clés dans la zone idoine.
    referrer.keywords.each { |kw|
      @@logger.an_event.info "visitor #{@id} search landing page #{referrer.landing_url} with keywords #{kw} on #{referrer.engine_search.class}"
      durations = referrer.durations.map { |d| d }
      landing_link_found, landing_link = search(kw,
                                                referrer.engine_search,
                                                durations,
                                                referrer.landing_url)
      @@logger.an_event.info "visitor #{@id} not found landing page #{referrer.landing_url} with keywords #{kw} on #{referrer.engine_search.class}" unless  landing_link_found
      return landing_link_found, landing_link if landing_link_found
    }
    [false, nil]
  end

  def open_browser
    begin
      @browser.open
    rescue Exception => e
      @@logger.an_event.error "visitor #{@id} cannot open browser #{@browser.name} #{@browser.id}"
      @@logger.an_event.debug e
      die
      raise VisitorException::CANNOT_OPEN_BROWSER
    end
  end

  def read(page)
    @@logger.an_event.info "visitor #{@id} read page #{page.url} during #{page.sleeping_time}s (= #{page.duration} - #{page.duration_search_link})"
    @browser.wait_on(page)
  end

  def search(keywords, engine_search, durations, landing_url)
    results_page = @browser.search(keywords, engine_search)
    results_page.duration = durations.shift
    read(results_page)
    landing_link_found, landing_link = engine_search.exist_link?(results_page, landing_url)

    if !landing_link_found
      # landing n a pas ete trouvé dans la premiere page de resultats
      # on chercher alors dans les pages suivantes dont le nombre est fixé par la taille du array referrer.durations
      index_current_page = 1
      durations.each_index { |i|
        next_page_link_found, next_page_link = engine_search.next_page_link(results_page, index_current_page+1)
        if next_page_link_found
          # si il existe une page suivante on clique dessus et on  cherche landing_url
          results_page = @browser.click_on(next_page_link)
          results_page.duration = durations[i]
          read(results_page)
          landing_link_found, landing_link = engine_search.exist_link?(results_page, landing_url)

          break if landing_link_found #si landing url a ete trouve on sort brutalement
          index_current_page += 1
        else
          # on na pas trouve de page suivante, on sort brutalement

          break
        end
      }
    end
    return [landing_link_found, landing_link]
  end

  def surf(durations, page, around)
    # le surf sur le website prend en entrée un around => arounds est rempli avec cette valeur
    # le surf sur l'advertiser predn en entrée un array de around pré calculé par engine bot en fonction des paramètre saisis au moyen de statupweb
    begin
      arounds = (around.is_a?(Array)) ? around : Array.new(durations.size, around)
      durations.each_index { |i|
        page.duration = durations[i]
        read(page)
        if i < durations.size - 1
          link = page.link(arounds[i])
          page = @browser.click_on(link)
        end # on ne clique pas quand on est sur la denriere page

      }
      page
    rescue Exception => e
      @@logger.an_event.debug e
      @@logger.an_event.error "visitor #{@id} stop surf at page #{page.url}"
      raise Visitors::Visitor::VisitorException::CANNOT_CONTINUE_SURF
    end
  end
end


end