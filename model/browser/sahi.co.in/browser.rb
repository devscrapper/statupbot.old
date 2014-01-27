require 'uuid'
require 'uri'
require_relative '../../page/link'
require_relative '../../page/page'
require 'sahi'
require_relative 'driver'
require_relative 'proxy'
require 'json'
module Browsers
  module SahiCoIn
    class Browser
      class BrowserException < StandardError
        URL_NOT_FOUND = "url not found"
        DISPLAY_FAILED = "an exception raise during browser display an url"
        LINK_NOT_FOUND = "link not found"
        CLICK_ON_FAILED = "an exception raise during browser click on an url"
        LINKS_LIST_FAILED = "catch links failed"

      end
      VISITORS_DIR = File.dirname(__FILE__) + "/../../visitors"
      LOG_DIR = File.dirname(__FILE__) + "/../../log"

      attr :driver,
           :screen_resolution

      attr_reader :id

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
      def self.build(browser_details)
        #Les navigateurs disponibles sont definis dans le fichier d:\sahi\userdata\config\browser_types.xml
        case browser_details[:name]
          when "Firefox"
            return Browser.new(browser_details, "firefox")
          when "Internet Explorer"
            return Browser.new(browser_details, "ie")
          when "Chrome"
            return Browser.new(browser_details, "chrome")
          when "Safari"
            return Browser.new(browser_details, "safari")
          when "Opera"
            return Browser.new(browser_details, "opera")
          else
            @@logger.an_event.debug "browser <#{browser_details[:name]}> unknown"
            raise BrowserException, "browser <#{browser_details[:name]}> unknown"
        end
      end

      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------
      # input :
      # une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
      #["flash_version", "11.4 r402"]   : fourni par la machine hote
      #["java_enabled", "No"]            : fourni par la machine hote
      #["screens_colors", "24-bit"]      : fourni par le navigateur utilisé
      #["screen_resolution", "1366x768"]

      def initialize(browser_details, browser_type)
        @id = UUID.generate
        @screen_resolution = browser_details[:screen_resolution]
        @driver = Driver.new(browser_type)
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
          link.click
          #raise BrowserException::URL_NOT_FOUND if error?
          @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"
          #@@logger.an_event.debug "cookies GA : #{cookies_ga}"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          lnks = links
          page = Page.new(@driver.current_url, nil, lnks, Time.now - start_time)
        rescue TimeoutError => e
          @@logger.an_event.warn "Timeout on browser #{name} #{@id} on click link #{link.url.to_s}"
          refresh
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          lnks = links
          page = Page.new(@driver.current_url, nil, lnks, Time.now - start_time)
        rescue RuntimeError => e
          @@logger.an_event.debug "browser #{name} #{@id}  : #{error_label}"
          @@logger.an_event.error "browser #{name} #{@id} not found url #{link.url.to_s}"
          raise e
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser #{name} #{@id} cannot try to click on url #{link.url.to_s}"
          raise BrowserException::DISPLAY_FAILED
        end
        return page
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
            @driver.navigate_to url.to_s
            @@logger.an_event.debug "browser #{name} #{@id} display url #{url.to_s}"
            start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
            lnks = links
            page = Page.new(@driver.current_url, nil, lnks, Time.now - start_time)
            stop = true
          rescue TimeoutError => e
            stop = false
            @@logger.an_event.warn "Timeout on browser #{name} #{@id}  on display url #{url.to_s}"
          rescue RuntimeError => e
            @@logger.an_event.error "browser #{name} #{@id} not found url #{url.to_s}"
            raise e
          rescue Exception => e
            @@logger.an_event.debug e
            @@logger.an_event.error "browser #{name} #{@id} try to browse url #{url.to_s}"
            raise BrowserException::DISPLAY_FAILED
          end
        end
        return page
      end

      #def error?
      #  begin
      #    @driver.find_element(:id, "errorShortDescText").enabled? and @driver.find_element(:id, "errorShortDescText").displayed?
      #  rescue Selenium::WebDriver::Error::NoSuchElementError => e
      #    false
      #  end
      #end

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
      def links
        begin
          @driver.fetch("_sahi.links()").split("|").map { |link| Link.new(URI.parse(link), @driver.link(link), @driver.title, nil) }
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "browser #{name} #{@id} cannot retrieve links in window : #{@driver.title}"
          raise BrowserException::LINKS_LIST_FAILED
        end
      end

      #----------------------------------------------------------------------------------------------------------------
      # name
      #----------------------------------------------------------------------------------------------------------------
      # retourne le nom du navigateur
      #----------------------------------------------------------------------------------------------------------------
      # input : RAS
      # output : Array de Link
      #----------------------------------------------------------------------------------------------------------------
      def name
        @driver.browser_type
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
          @driver.open
          @@logger.an_event.debug "browser #{name} #{@id} is opened"
            #TODO resize la fenetre du browser.
            #width, height = @screen_resolution.split(/x/)
            #@driver.manage.window.resize_to(width.to_i, height.to_i)
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser #{name} #{@id} cannot be opened"
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
          @driver.close
          @@logger.an_event.info "browser #{name} #{@id} is closed"
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser #{name} #{@id} cannot be closed"
          raise BrowserException, e.message
        end
      end

      def refresh
        display = false
        while !display
          begin
            @@logger.an_event.warn "browser #{name} #{@id} refresh url #{@driver.current_url}"
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
          @@logger.an_event.error "browser #{name} #{@id} cannot search #{keywords} with engine #{engine_search.class}"
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
        @@logger.an_event.debug "browser #{name} #{@id} start waiting on page #{page.url}"
        # @driver.switch_to.window(page.window_tab)
        sleep page.sleeping_time
        @@logger.an_event.debug "browser #{name} #{@id} finish waiting on page #{page.url}"
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
end
