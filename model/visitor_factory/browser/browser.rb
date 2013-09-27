require 'selenium-webdriver'
require 'uuid'
require_relative '../search_engine/engine'
module VisitorFactory
  require 'json'
  class CustomQuery
    attr :var_query,
         :var_http
    attr_reader :domain_path #shceme/domain/path


    def initialize(domain_path)
      @domain_path = domain_path
      @var_query = {}
      @var_http = {}
    end

    def add_var_http(var, value)
      @var_http.merge!({var => value})
    end

    def add_var_query(var, value)
      @var_query.merge!({var => value})
    end

    def query()
      @domain_path
    end

    def to_json(*a)
      {'var_http' => @var_http,
       'var_query' => @var_query}
      .to_json(*a)
    end

  end

  class CustomQueries
    attr :queries

    def initialize
      @queries = {}
    end

    def << (a)
      @queries.merge!({a.domain_path => a})
    end

    def add_var_http(var, value)
      @queries.merge!({var => value})
    end

    def to_json(*a)
      @queries.to_json(*a)
    end
  end


  class Browser
    class BrowserException < StandardError
    end
    attr :logger,
         :profile,
         :driver,
         :screen_resolution

    attr_reader :id,
                :custom_queries

    include VisitorFactory::SearchEngines
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # build
    #----------------------------------------------------------------------------------------------------------------
    # crée un geolocation :
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
    #["flash_version", "11.4 r402"]
    #["java_enabled", "No"]
    #["screens_colors", "24-bit"]
    #["screen_resolution", "1366x768"]
    # mot clé utulisés pour les requetes de scraping de google analitycs :
    # Browser : "Chrome", "Firefox", "Internet Explorer", "Safari"
    # operatingSystem:  "Windows", "Linux", "Macintosh"
    #----------------------------------------------------------------------------------------------------------------
    def self.build(browser_details, visitor)
      #TODO Faire un point sur les navigateurs pris en charge par
      StatupBot et les naviateurs dont on récupère les propriétés avec ScraperBot
      geolocation = visitor.geolocation
      nationality = visitor.nationality
      visitor_id = visitor.id
      case browser_details[:browser]
        when "Firefox"
          return Firefox.new(browser_details, nationality, geolocation, visitor_id)
        when "Internet Explorer"
          return InternetExplorer.new(browser_details, nationality, geolocation, visitor_id)
        when "Chrome"
          return Chrome.new(browser_details, nationality, geolocation, visitor_id)
        when "Safari"
          return Safari.new(browser_details, nationality, geolocation, visitor_id)
        else
          raise BrowserException, "browser <#{browser_details[:browser]}> unknown"
      end
    end

    #TODO faire travailler firefox en http et pas https avce google
    #TODO VALIDATE les variables HTTP, et UTM envoyé vers googlenanlytics reflete le FakeBrowser
    #TODO essayer de remplacer le mitm proxy par de l'injection de code javascript pour faker les function javascript du DOM utiliser par le script ga.js   ; (WebDriver::Element, ...) execute_script(script, *args) (also: #script)
    #TODO valider le ssl  : firefox accepte les certificats ; assume_untrusted_certificate_issuer?
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
    #["flash_version", "11.4 r402"]
    #["java_enabled", "No"]
    #["screens_colors", "24-bit"]
    #["screen_resolution", "1366x768"]

    def initialize(browser_details, geolocation, visitor_id)
      @id = UUID.generate
      @screen_resolution = browser_details[:screen_resolution]
      @custom_queries = CustomQueries.new
      @custom_queries.add_var_http("User-Agent", user_agent(browser_details[:browser_version], \
                                                            browser_details[:operating_system], \
                                                            browser_details[:operating_system_version]))
      @profile = Selenium::WebDriver::Firefox::Profile.new
      @profile['javascript.enabled'] = true
      @profile['network.http.accept-encoding'] = "gzip,deflate"
      @profile['general.useragent.override'] = visitor_id
      #TODO supprimer le user agent du profil et le remplacer par le visitor_id
      @profile['general.useragent.override'] = user_agent(browser_details[:browser_version], \
                                                            browser_details[:operating_system], \
                                                            browser_details[:operating_system_version])
      @profile = geolocation.update_profile(@profile)
    end

    #----------------------------------------------------------------------------------------------------------------
    # click
    #----------------------------------------------------------------------------------------------------------------
    # accède à une url
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def click(url)
      begin
        url_found = false
        @@logger.an_event.debug "url to find #{url}"
        @driver.find_elements(:tag_name, "a").each { |a|
          @@logger.an_event.debug "href : #{a[:href]}"
          if a[:href] == url
            @@logger.an_event.info "browser #{@id} click on url #{url} on page #{@driver.current_url}"
            a.click
            url_found = true
            break
          end
        }
        if url_found
          sleep(5)
          @@logger.an_event.debug "cookies GA : #{cookies_ga}"
        else
          @@logger.an_event.warn "browser #{@id} not found url #{url} on page #{@driver.current_url}"
          browse(url)
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} cannot click on url #{url} on page #{@driver.current_url}"
        raise BrowserException, e.message
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # close
    #----------------------------------------------------------------------------------------------------------------
    # close un webdriver
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def close
      begin
        @driver.manage.delete_all_cookies()
        @driver.close
        @@logger.an_event.info "browser #{@id} is closed"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} is not closed"
        raise BrowserException, e.message
      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # go
    #----------------------------------------------------------------------------------------------------------------
    # accède à une url
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------


    def browse(url)
      begin
        @driver.get url
        @@logger.an_event.info "browser #{@id} browse url #{url}"
        sleep(5)
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} cannot browse url #{url}"
        raise BrowserException, e.message
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # open
    #----------------------------------------------------------------------------------------------------------------
    # open un webdriver
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def open
      begin
        firefox_binary_path = VisitorFactory.firefox_path || Selenium::WebDriver::Firefox::Binary.path
        raise BrowserException, "firefox binary path not exist :#{firefox_binary_path}" unless File.exists?(firefox_binary_path)

        Selenium::WebDriver::Firefox.path = firefox_binary_path
        @driver = Selenium::WebDriver.for :firefox, :profile => @profile
        @@logger.an_event.info "browser #{@id} is opend"
        width, height = @screen_resolution.split(/x/)
        @driver.manage.window.resize_to(width.to_i, height.to_i)
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} is not opend"
        raise BrowserException, e.message
      end
    end

    # realise la recherche dans le moteur et passe en revue les pages de resultat pour localiser la landing page
    # le nombre de page maximum et le temporisation est calculé lors del planification de la visite (open visit/start visit)
    # retourn true si la landing page a été localisé dans une page de resultat
    # false sinon (cout_max_page dépassé ou pas de page suivante ou pas de resultat de recherche)
    # le temps d'affichage de chaque page est defini pour s'assurer que les pages sont chargées car api drriver de chargement de page (get/click) sous windows on bloquante
    def search(search_engine, landing_page_url, keywords, sleeping_time, count_max_page)
      begin
        search_engine = SearchEngine.build(search_engine, @driver, sleeping_time)
        count_page = search_engine.search(keywords)
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
        landing_page_found = false
        # on boucle tanque la landing page n'a pas été trouvé ou bien que le nombre de page de resultat n'est pas atteint ou bien qu'il eixte une page suivante
        # count_page == 0 est synonyme de page non trouve ou affichée
        while 0 < count_page and \
          count_page <= count_max_page and \
          !landing_page_found
          @@logger.an_event.info "browser #{@id} display result page #{count_page} of #{search_engine.class} search with #{keywords}"
          landing_page_found = search_engine.exist?(landing_page_url)
          count_page = search_engine.next if !landing_page_found
          @@logger.an_event.debug "cookies GA : #{cookies_ga}"
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.warn "browser #{@id} cannot found url #{landing_page_url}"
      ensure
        return landing_page_found
      end
    end


    def click_on_pub(advertising, duration_pages)
      begin
        advert = Publicity.build(advertising, @driver)
        if advert.nil?
          @@logger.an_event.info "none publicity #{advertising} is found on #{@driver.current_url}"
        else
          advertiser = advert.click
          @@logger.an_event.info "browser #{@id} click on publicity #{@driver.current_url}"
          duration_pages.each { |duration|
            sleep duration
            advertiser.click_on(advertiser.select_link)
            @@logger.an_event.info "after click on pub, browser #{@id} click on #{@driver.current_url}"
          }
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "an error occurend when browser #{@id} click on pub or later"
      end
    end

    def cookies_ga
      cookies = []
      driver.manage.all_cookies.each { |cookie|
        cookies << cookie if  ["__utma", "__utmb", "__utmc", "__utmz"].include?(cookie[:name])
      }
      cookies
    end
  end


end

require_relative 'firefox'
require_relative 'internet_explorer'
require_relative 'chrome'
require_relative 'safari'