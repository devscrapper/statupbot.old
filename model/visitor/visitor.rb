require_relative 'geolocation/geolocation'
require_relative '../../model/browser/webdriver/browser'
require_relative '../../model/browser/sahi.co.in/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require_relative 'nationality/nationality'

#require_relative 'customize_queries_connection'
#require_relative 'custom_gif_request/custom_gif_request'

module Visitors
  include Geolocations
  include Nationalities
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings

  class Visitor
    class VisitorException < StandardError
      BAD_VALUE_FOR_RETURN_VISITOR = "value unknown for :return_visitor in visitor_details"
      CANNOT_CONTINUE_VISIT = "visitor cannot continue visit"
      NOT_FOUND_LANDING_PAGE = "visitor not found landing page"
      CANNOT_CONTINUE_SURF = "visitor cannot surf"
      BAD_KEYWORDS = "keywords are bad"
    end

    DIR_VISITORS = File.dirname(__FILE__) + "/../../visitors"

    attr_accessor :id,
                  :browser,
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
      case visitor_details[:return_visitor]
        when :true
          #TODO demander à VisitorFacotry de retourner un visitor
          #TODO si pas de return visitor dispo alors retourne un nouveau visitor
          return Visitor.new(visitor_details,
                             (exist_pub_in_visit == true) ? :webdriver : :sahi,
                             listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd)
        when :false
          return Visitor.new(visitor_details,
                             (exist_pub_in_visit == true) ? :webdriver : :sahi,
                             listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd)
        else
          raise VisitorException::BAD_VALUE_FOR_RETURN_VISITOR
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
      begin
        @id = visitor_details[:id]
        FileUtils.mkdir_p(File.join(DIR_VISITORS, @id))
        if browser_type == :sahi
          @proxy = Browsers::SahiCoIn::Proxy.new(@id, listening_port_sahi_proxy, proxy_ip, proxy_port, proxy_user, proxy_pwd)
          @proxy.start
          @browser = Browsers::SahiCoIn::Browser.build(visitor_details[:browser])
          @@logger.an_event.info "visitor #{@id} is born"
        else

          @geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
                                             #TODO peut on partager les proxy entre visiteur de site different ?
          @browser = Browsers::Webdriver::Browser.build(visitor_details[:browser])
          @browser.profile = @geolocation.update_profile(@browser.profile)
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} dead borned"
      end

    end

    def browse(referrer)
      begin
        case referrer
          when Direct
            return @browser.display(referrer.landing_url)
          when Referral
            referral_page = @browser.display(referrer.page_url)
            referral_page.duration = referrer.duration
            read(referral_page)
            return @browser.click_on(referral_page.link_by_url(referrer.landing_url))
          when Search
            landing_link_found = false
            landing_link = nil
            results_page = @browser.search(referrer.keywords, referrer.engine_search)
            results_page.duration = referrer.durations.shift
            read(results_page)
            landing_link_found, landing_link = referrer.engine_search.exist_link?(results_page, referrer.landing_url)

            if !landing_link_found
              # landing n a pas ete trouvé dans la premiere page de resultats
              # on chercher alors dans les pages suivantes dont le nombre est fixé par la taille du array referrer.durations
              index_current_page = 1
              referrer.durations.each_index { |i|
                next_page_link_found, next_page_link = referrer.engine_search.next_page_link(results_page, index_current_page+1)
                if next_page_link_found
                  # si il existe une page suivante on clique dessus et on  cherche landing_url
                  results_page = @browser.click_on(next_page_link)
                  results_page.duration = referrer.durations[i]
                  read(results_page)
                  landing_link_found, landing_link = referrer.engine_search.exist_link?(results_page, referrer.landing_url)
                  break if landing_link_found #si landing url a ete trouve on sort brutalement
                  index_current_page += 1
                else
                  # on na pas trouve de page suivante, on sort brutalement
                  break
                end
              }
            end
            return @browser.click_on(landing_link) if landing_link_found
            raise VisitorException, "keyword : #{referrer.keywords}" unless landing_link_found
        end
      rescue VisitorException => e
        @@logger.an_event.debug e
        @@logger.an_event.warn "visitor #{@id} not found landing page #{referrer.landing_url} with keywords #{referrer.keywords}"
        raise VisitorException::NOT_FOUND_LANDING_PAGE
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} not found landing page #{referrer.landing_url}"
        raise VisitorException::NOT_FOUND_LANDING_PAGE
      end
    end


    def close_browser
      begin
        @browser.quit
        @@logger.an_event.info "visitor #{@id} has closed his browser"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} cannot close his browser"
      end
    end

    def die
      begin
        @proxy.stop
      rescue Browsers::SahiCoIn::Proxy::ProxyException::PROXY_FAIL_TO_STOP => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} cannot die"
      rescue Browsers::SahiCoIn::Proxy::ProxyException::PROXY_FAIL_TO_CLEAN_PROPERTIES => e
        @@logger.an_event.debug e
        @@logger.an_event.warn "visitor #{@id} die dirty"
      end
      begin
        FileUtils.rm_r(File.join(DIR_VISITORS, @id))
        @@logger.an_event.info "visitor #{@id} is dead"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.warn "visitor #{@id} die dirty"
      end
    end

    def execute(visit)
      @@logger.an_event.info "visitor #{@id} start execution of visit #{visit.id}"
      begin
        landing_page = browse(visit.referrer)
        @@logger.an_event.info "visitor #{@id} browse landing page #{visit.landing_url}"
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
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} cannot execute visit #{visit.id}"
        raise VisitorException::CANNOT_CONTINUE_VISIT
      end
      @@logger.an_event.info "visitor #{@id} stop execution of visit #{visit.id}"
    end

    def open_browser
      begin
        @browser.open
        @@logger.an_event.info "visitor #{@id} open browser #{@browser.name}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} cannot open browser #{@browser.name} #{@browser.id}"
      end
    end

    def read(page)
      @@logger.an_event.info "visitor #{@id} read page #{page.url} during #{page.sleeping_time}s (= #{page.duration} - #{page.duration_search_link})"
      @browser.wait_on(page)
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
            @@logger.an_event.info "visitor #{@id} click on link #{link.url}"
          end # on ne clique pas quand on est sur la denriere page

        }
        page
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor  #{@id} stop surf at page #{page.url}"
        raise VisitorException::CANNOT_CONTINUE_SURF
      end
    end
  end


end