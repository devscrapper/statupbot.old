require 'selenium-webdriver'
require 'uuid'
require 'uri'
require_relative '../page/page'
require_relative '../page/link'

module Browsers
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
      URL_NOT_FOUND = "url not found"
      DISPLAY_FAILED = "an exception raise during browser display an url"
      LINK_NOT_FOUND = "link not found"
      CLICK_ON_FAILED = "an exception raise during browser click on an url"
    end
    attr :driver,
         :screen_resolution

    attr_accessor :profile

    attr_reader :id,
                :custom_queries


    #TODO meo le monitoring de l'activité du browser
    include Pages
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
    def self.build(browser_details, nationality, user_agent)
      #TODO Faire un point sur les navigateurs pris en charge par      StatupBot et les naviateurs dont on récupère les propriétés avec ScraperBot
      case browser_details[:name]
        when "Firefox"
          return Firefox.new(browser_details, nationality, user_agent)
        when "Internet Explorer"
          return InternetExplorer.new(browser_details, nationality, user_agent)
        when "Chrome"
          return Chrome.new(browser_details, nationality, user_agent)
        when "Safari"
          return Safari.new(browser_details, nationality, user_agent)
        else
          raise BrowserException, "browser <#{browser_details[:name]}> unknown"
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

    def initialize(browser_details, user_agent)
      @id = UUID.generate
      @screen_resolution = browser_details[:screen_resolution]
      @custom_queries = CustomQueries.new
      @custom_queries.add_var_http("User-Agent", user_agent(browser_details[:version], \
                                                            browser_details[:operating_system], \
                                                            browser_details[:operating_system_version]))
      @profile = Selenium::WebDriver::Firefox::Profile.new
      @profile['javascript.enabled'] = true
      @profile['network.http.accept-encoding'] = "gzip,deflate"
      @profile['general.useragent.override'] = user_agent
      #TODO supprimer le user agent du profil et le remplacer par le visitor_id
      @profile['general.useragent.override'] = user_agent(browser_details[:version], \
                                                            browser_details[:operating_system], \
                                                            browser_details[:operating_system_version])

    end

    #----------------------------------------------------------------------------------------------------------------
    # click_on
    #----------------------------------------------------------------------------------------------------------------
    # click sur un lien
    #----------------------------------------------------------------------------------------------------------------
    # input : object Link
    # output : Object Page
    # exception : URL_NOT_FOUND, CLICK_ON_FAILED
    #----------------------------------------------------------------------------------------------------------------


    def click_on(link)
      page = nil
      begin
        @driver.switch_to.window(link.window_tab)
        switch_to_frame(link.path_frame)
        raise BrowserException::LINK_NOT_FOUND unless link.exist?
        link.click
        raise BrowserException::URL_NOT_FOUND if error?
        @@logger.an_event.info "browser #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
        #page = Page.new(link.url, links)
        page = Page.new(@driver.current_url, @driver.window_handle, links)
      rescue TimeoutError => e
        @@logger.an_event.warn "Timeout on browser #{@id} on click link #{link.url.to_s}"
        refresh
        page = Page.new(@driver.current_url, @driver.window_handle, links)
      rescue RuntimeError => e
        @@logger.an_event.debug "browser #{@id} : #{error_label}"
        @@logger.an_event.error "browser #{@id} not found url #{link.url.to_s}"
        raise e
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} cannot try to click on url #{link.url.to_s}"
        raise BrowserException::DISPLAY_FAILED
      end
      return page
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

    def cookies_ga
      cookies = []
      driver.manage.all_cookies.each { |cookie|
        cookies << cookie if  ["__utma", "__utmb", "__utmc", "__utmz"].include?(cookie[:name])
      }
      cookies
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # accède à une url
    #----------------------------------------------------------------------------------------------------------------
    # input : url
    # output : Object Page
    # exception : URL_NOT_FOUND, DISPLAY_FAILED
    #----------------------------------------------------------------------------------------------------------------
    def display(url)
      stop = false
      page = nil
      while !stop
        begin
          @driver.get url.to_s
          raise BrowserException::URL_NOT_FOUND if error?
          @@logger.an_event.info "browser #{@id} browse url #{url.to_s} in windows #{@driver.window_handle}"
          @@logger.an_event.debug "cookies GA : #{cookies_ga}"
          page = Page.new(@driver.current_url, @driver.window_handle, links)
          #page = Page.new(url, links)
          stop = true
        rescue TimeoutError => e
          stop = false
          @@logger.an_event.warn "Timeout on browser #{@id} on display url #{url.to_s}"
        rescue RuntimeError => e
          @@logger.an_event.debug "browser #{@id} : #{error_label}"
          @@logger.an_event.error "browser #{@id} not found url #{url.to_s}"
          raise e
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser #{@id} try to browse url #{url.to_s}"
          raise BrowserException::DISPLAY_FAILED
        end
      end
      return page
    end

    def error?
      begin
        @driver.find_element(:id, "errorShortDescText").enabled? and @driver.find_element(:id, "errorShortDescText").displayed?
      rescue Selenium::WebDriver::Error::NoSuchElementError => e
        false
      end
    end

    def error_label
      @driver.find_element(:id, "errorShortDescText").text
    end



    #----------------------------------------------------------------------------------------------------------------
    # links
    #----------------------------------------------------------------------------------------------------------------
    # dans la page courante, liste tous les href issue des tag : <a>, <map>.
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : Array de Link
    #----------------------------------------------------------------------------------------------------------------
    def links(path_crt_frame=[], crt_frame=nil)
      #TODO faire la liste de toutes les balises html qui referencent un lien http (a, map,...)
      path_crt_frame << crt_frame unless crt_frame.nil?

      switch_to_frame(path_crt_frame)

      html_tag_a = @driver.find_elements(:tag_name, "a")
      html_tag_a.select! { |l| l.enabled? and \
                                l.displayed? and \
                                !l[:href].nil? and \
                                well_formed?(l[:href]) and \
                                l[:href].start_with?("http:") and \
                                l[:href] != @driver.current_url and \
                                !l[:href].end_with?("png") and \
                                !l[:href].end_with?("jpg") and \
                                !l[:href].end_with?("jpeg") and \
                                !l[:href].end_with?("gif") and \
                                !l[:href].end_with?("pdf") and \
                                !l[:href].end_with?("svg")
      }

      html_tag_a.uniq! { |p| p[:href] }
      lnks = (html_tag_a.size > 0) ? html_tag_a.map { |link| Link.new(URI.parse(link[:href]), link, @driver.window_handle, Array.new(path_crt_frame)) } : []

      @driver.find_elements(:tag_name, "iframe").each { |frame|
        lnks += links(path_crt_frame, frame)

        path_crt_frame.pop
        switch_to_frame(path_crt_frame)
      }
      lnks
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
        firefox_binary_path = @@firefox_path || Selenium::WebDriver::Firefox::Binary.path
        raise BrowserException, "firefox binary path not exist :#{firefox_binary_path}" unless File.exists?(firefox_binary_path)

        Selenium::WebDriver::Firefox.path = firefox_binary_path
        @driver = Selenium::WebDriver.for :firefox, :profile => @profile
        @@logger.an_event.info "browser #{@id} is opened"
        width, height = @screen_resolution.split(/x/)
        @driver.manage.window.resize_to(width.to_i, height.to_i)
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} is not opend"
        raise BrowserException, e.message
      end
    end

    def refresh
      display = false
      while !display
        begin
          @@logger.an_event.warn "browser #{@id} refresh url #{@driver.current_url}"
          @driver.navigate.refresh
          display = true
        rescue TimeoutError => e

        end
      end
    end

    def search(keywords, engine_search)
      page = nil
      begin
        @driver.get engine_search.page_url
        element = @driver.find_element(engine_search.tag_search, engine_search.id_search)
        element.send_keys keywords
        element.submit
        lnks = links
        page = Page.new(@driver.current_url, @driver.window_handle, lnks)
      rescue TimeoutError => e
        refresh
        page = Page.new(@driver.current_url, @driver.window_handle, links)
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser #{@id} cannot search a with engine #{engine_search.class}"
      end
      page
    end

    def switch_to_frame(path_frame)
      begin
        @driver.switch_to.default_content
        path_frame.each { |frame| @driver.switch_to.frame(frame) }
      rescue Exception => e
        raise BrowserException, e.message
      end
    end

    def wait_on(page)
      @@logger.an_event.debug "browser #{@id} start waiting on page #{page.url}"
      @driver.switch_to.window(page.window_tab)
      sleep page.duration
      @@logger.an_event.debug "browser #{@id} finish waiting on page #{page.url}"
    end

    def well_formed?(url)
      begin
        URI.parse(url)
        return true
      rescue Exception => e
        @@logger.an_event.debug "#{e.message}, url"
        return false
      end
    end
  end


end

require_relative 'firefox'
require_relative 'internet_explorer'
require_relative 'chrome'
require_relative 'safari'