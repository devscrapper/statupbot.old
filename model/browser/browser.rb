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


    def initialize(domain_path="*")
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
      LINKS_LIST_FAILED = "catch links failed"

    end
    VISITORS_DIR = File.dirname(__FILE__) + "/../../visitors"
    EXTENSION_DIR = File.dirname(__FILE__) + "/../../extension"
    LOG_DIR = File.dirname(__FILE__) + "/../../log"
    EXTENSION_URL_REWRITING = "urlrewriting@statupbot.com"
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
      @profile = Selenium::WebDriver::Firefox::Profile.new
      # le separator utiliser par ruby est / qq soit l'os. Ruby gere en interne l'adaptation au file system
      # le chemin du fichier de paramétrage visitor est manipuler par javascript dans une extension firefox. Ruby ne peut
      # donc faire l'adaptation au file system. En conséquence il y a obligation de gérer le séparator pour javascript manuellement
      # car il ne comprend pas le separator '/' sous windows
      case RbConfig::CONFIG['host_os']
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          @profile["extensions.#{EXTENSION_URL_REWRITING}.visitor.filename"] = File.join(File.absolute_path(VISITORS_DIR), "#{user_agent}.json").gsub("/","\\")
          @profile["extensions.#{EXTENSION_URL_REWRITING}.log.filename"] = File.join(File.absolute_path(LOG_DIR), "#{EXTENSION_URL_REWRITING}.log").gsub("/","\\")
        when /linux/
          @profile["extensions.#{EXTENSION_URL_REWRITING}.visitor.filename"] = File.join(File.absolute_path(VISITORS_DIR), "#{user_agent}.json")
          @profile["extensions.#{EXTENSION_URL_REWRITING}.log.filename"] = File.join(File.absolute_path(LOG_DIR), "#{EXTENSION_URL_REWRITING}.log")
        else
          raise BrowserException, "unknown os: #{RbConfig::CONFIG['host_os']}"
      end
      @profile["extensions.#{EXTENSION_URL_REWRITING}.visitor.id"] = user_agent
      @profile["extensions.checkCompatibility"] = false
      @profile.add_extension(File.join(EXTENSION_DIR, EXTENSION_URL_REWRITING))
      @profile['intl.charset.default'] = "UTF-8"
      @profile['javascript.enabled'] = true
      #---------------------------------------------------------------------------------------------------------------
      # ATTENTION : suuprimer du fichier D:\Ruby193\lib\ruby\gems\1.9.1\gems\selenium-webdriver-2.33.0\lib\selenium\webdriver\firefox\extension\prefs.json
      # contenu dans le gem selenium, les variables :
      # browser.link.open_newwindow
      # browser.link.open_newwindow.restriction
      # afin de pouvoir les modifier avec les valeurs suivantes :
      #Where to open links that would normally open in a new window
      #2 (default in SeaMonkey and Firefox 1.5): In a new window
      #3 (default in Firefox 2 and above): In a new tab
      #1 (or anything else): In the current tab or window
      #Note: In Firefox 1.5, this can be changed via "Tools → Options → Tabs → Force links that open new windows to open in:"; in Firefox 2 and above, via “Tools → Options → Tabs → New pages should be opened in:” (same as browser.link.open_external) and, in SeaMonkey, via "Edit -> Preferences -> Navigator -> Tabbed browsing / Link open behavior -> Open links meant to open a new window in".
      @profile['browser.link.open_newwindow'] = 3 #open link always in current tab =>never new tab and never new window
      #Firefox and SeaMonkey only. Source: The Burning Edge.
      #0 (Default in Firefox 1.0.x and SeaMonkey): Force all new windows opened by JavaScript into tabs.
      #1: Let all windows opened by JavaScript open in new windows. (Default behavior in IE.)
      #2 (Default in Firefox 1.5 and above): Catch new windows opened by JavaScript that do not have specific values set (how large the window should be, whether it should have a status bar, etc.) This is useful because some popups are legitimate — it really is useful to be able to see both the popup and the original window at the same time. However, most advertising popups also open in new windows with values set, so beware.
      @profile['browser.link.open_newwindow.restriction'] = 0
      #---------------------------------------------------------------------------------------------------------------
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
        @@logger.an_event.info "browser click on url #{link.url.to_s} in window #{link.window_tab}"
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
        lnks = links
        page = Page.new(@driver.current_url, get_window_handle(@driver.current_url), lnks, Time.now - start_time)
      rescue TimeoutError => e
        @@logger.an_event.warn "Timeout on browser #{@id} on click link #{link.url.to_s}"
        refresh
        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
        lnks = links
        page = Page.new(@driver.current_url, get_window_handle(@driver.current_url), lnks, Time.now - start_time)
      rescue RuntimeError => e
        @@logger.an_event.debug "browser : #{error_label}"
        @@logger.an_event.error "browser not found url #{link.url.to_s}"
        raise e
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser cannot try to click on url #{link.url.to_s}"
        raise BrowserException::DISPLAY_FAILED
      end
      return page
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
          @@logger.an_event.info "browser browse url #{url.to_s} in windows #{@driver.window_handle}"
          @@logger.an_event.debug "cookies GA : #{cookies_ga}"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          lnks = links
          page = Page.new(@driver.current_url, get_window_handle(@driver.current_url), lnks, Time.now - start_time)
          stop = true
        rescue TimeoutError => e
          stop = false
          @@logger.an_event.warn "Timeout on browser #{@id} on display url #{url.to_s}"
        rescue RuntimeError => e
          @@logger.an_event.debug "browser : #{error_label}"
          @@logger.an_event.error "browser  not found url #{url.to_s}"
          raise e
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser try to browse url #{url.to_s}"
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

    def get_window_handle(url)
      current_window_handle = @driver.window_handle
      @driver.window_handles.each { |h|
        @driver.switch_to.window(h)
        if @driver.current_url == url
          @driver.switch_to.window(current_window_handle)
          return h
        end
      }
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
      begin
        path_crt_frame << crt_frame unless crt_frame.nil?

        switch_to_frame(path_crt_frame)
        html_tag_a = @driver.find_elements(:tag_name, "a")
        html_tag_a.select! { |l|
          l.enabled? and \
            l.displayed? and \
            !l[:href].nil? and \
            well_formed?(l[:href]) and \
            l[:href].start_with?("http") and \
            l[:href] != @driver.current_url and \
            !l[:href].end_with?("png") and \
            !l[:href].end_with?("jpg") and \
            !l[:href].end_with?("jpeg") and \
            !l[:href].end_with?("gif") and \
            !l[:href].end_with?("pdf") and \
            !l[:href].end_with?("svg")
        }

        html_tag_a.uniq! { |l| l[:href] }
        lnks = (html_tag_a.size > 0) ? html_tag_a.map { |link| Link.new(URI.parse(link[:href]), link, @driver.window_handle, Array.new(path_crt_frame)) } : []

        @driver.find_elements(:tag_name, "iframe").each { |frame|
          lnks += links(path_crt_frame, frame)

          path_crt_frame.pop
          switch_to_frame(path_crt_frame)
        }
        lnks
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        return links
      rescue Exception => e
        @@logger.an_event.debug e.message
        @@logger.an_event.debug "current window : #{@driver.window_handle}"
        @@logger.an_event.debug "current page : #{@driver.current_url}"
        @@logger.an_event.debug "current frame : #{path_crt_frame}"
        raise BrowserException::LINKS_LIST_FAILED
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
        firefox_binary_path = @@firefox_path || Selenium::WebDriver::Firefox::Binary.path
        raise BrowserException, "firefox binary path not exist :#{firefox_binary_path}" unless File.exists?(firefox_binary_path)

        Selenium::WebDriver::Firefox.path = firefox_binary_path
        @driver = Selenium::WebDriver.for :firefox, :profile => @profile
        @@logger.an_event.info "browser is opened"
        width, height = @screen_resolution.split(/x/)
        @driver.manage.window.resize_to(width.to_i, height.to_i)
        @@logger.an_event.debug "cookies GA : #{cookies_ga}"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser is not opend"
        raise BrowserException, e.message
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # quit
    #----------------------------------------------------------------------------------------------------------------
    # close un webdriver
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def quit
      begin
        #@driver.manage.delete_all_cookies()
        @driver.quit
        @@logger.an_event.info "browser is closed"
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser is not closed"
        raise BrowserException, e.message
      end
    end

    def refresh
      display = false
      while !display
        begin
          @@logger.an_event.warn "browser refresh url #{@driver.current_url}"
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
        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
        lnks = links
        page = Page.new(@driver.current_url, get_window_handle(@driver.current_url), lnks, Time.now - start_time)
      rescue TimeoutError => e
        refresh
        element = @driver.find_element(engine_search.tag_search, engine_search.id_search)
        element.send_keys keywords
        element.submit
        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
        lnks = links
        page = Page.new(@driver.current_url, get_window_handle(@driver.current_url), lnks, Time.now - start_time)
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "browser cannot search #{keywords} with engine #{engine_search.class}"
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
      @@logger.an_event.debug "browser start waiting on page #{page.url}"
      @driver.switch_to.window(page.window_tab)
      sleep page.sleeping_time
      @@logger.an_event.debug "browser finish waiting on page #{page.url}"
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