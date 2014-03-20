require 'uuid'
require 'uri'
require_relative '../../page/link'
require_relative '../../page/page'
require 'sahi'
require_relative 'driver'
require_relative 'proxy'
require 'json'
require 'csv'
module Browsers
  module SahiCoIn
    class Browser
      class BrowserException < StandardError
        URL_NOT_FOUND = "url not found"
        DISPLAY_FAILED = "an exception raise during browser display an url"
        LINK_NOT_FOUND = "link not found"
        CLICK_ON_FAILED = "an exception raise during browser click on an url"
        LINKS_LIST_FAILED = "catch links failed"
        GO_TO_FAILED = "go to failed"
        BROWSER_NOT_STARTED = "browser #{name} #{@id} cannot be opened"
        BROWSER_NOT_CLOSE = "browser #{name} #{@id} cannot be closed"
        BROWSER_NOT_NAVIGATE = "browser  cannot navigate to "
      end
      VISITORS_DIR = File.dirname(__FILE__) + "/../../visitors"
      LOG_DIR = File.dirname(__FILE__) + "/../../log"
      NO_REFERER = "noreferrer"
      DATA_URI = "datauri"
      attr_accessor :driver,
                    :listening_port_proxy


      attr_reader :id,
                  :height,
                  :width,
                  :pids,
                  :method_start_page,
                  :start_page #TODO supprimer variable start_page

      #TODO meo le monitoring de l'activité du browser
      #TODO suivre les cookies du browser : s'assurer qu'il sont vide et alimenté quand il faut hahahahaha
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
      def self.build(visitor_dir, browser_details)
        #Les navigateurs disponibles sont definis dans le fichier d:\sahi\userdata\config\browser_types.xml
        case browser_details[:name]
          when "Firefox"
            return Firefox.new(visitor_dir, browser_details)
          when "Internet Explorer"
            return InternetExplorer.new(visitor_dir, browser_details)
          when "Chrome"
            return Chrome.new(visitor_dir, browser_details)
          #when "Safari"
          #TODO mettre en oeuvre Safari
          #  return Safari.new(visitor_dir, browser_details)
          #when "Opera"
          #TODO mettre en oeuvre Opera
          #  return Opera.new(visitor_dir, browser_details)
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

      def initialize(browser_details)
        @id = UUID.generate
        @listening_port_proxy = browser_details[:listening_port_proxy]
        @width, @height = browser_details[:screen_resolution].split(/x/)
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
      def current_page_details
        page_details = @driver.current_page_details
        page_details["links"].map! { |link|
          if ["", "_top", "_self", "_parent"].include?(link["target"])
            Link.new(URI.parse(link["href"]), @driver.link(link["href"]), page_details["title"], link["text"], nil)
          else
            @@logger.an_event.debug "link, href <#{link["href"]}> has bad target <#{link["target"]}>, so it is rejected"
            nil
          end
        }.compact
        page_details
      end

      def click_on(link)
        page = nil
        begin
          link.click
          #raise BrowserException::URL_NOT_FOUND if error?
          @@logger.an_event.info "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"
          #@@logger.an_event.debug "cookies GA : #{cookies_ga}"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          page = Page.new(page_details["url"],page_details["referrer"],page_details["title"], nil, page_details["links"],  page_details["cookies"],Time.now - start_time)
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
      # input : url  (uri)
      # output : Object Page
      # exception : URL_NOT_FOUND, DISPLAY_FAILED
      #----------------------------------------------------------------------------------------------------------------
      def display(url)
        stop = false
        page = nil
        while !stop
          begin
            @driver.navigate_to url.to_s
            @@logger.an_event.info "browser #{name} #{@id} display url #{url.to_s}"
            start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
            page_details = current_page_details
            page = Page.new(page_details["url"],page_details["referrer"],page_details["title"], nil, page_details["links"],page_details["cookies"], Time.now - start_time)
            stop = true
          rescue TimeoutError => e
            stop = false
            @@logger.an_event.warn "Timeout on browser #{name} #{@id}  on display url #{url.to_s}"
          rescue RuntimeError => e
            @@logger.an_event.debug e
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

      def get_pid(process_exe)
        f = IO.popen("tasklist /FO CSV /NH /V /FI \"WINDOWTITLE eq #{@id}*\"")
        @@logger.an_event.info "tasklist /FO CSV /NH /V /FI \"WINDOWTITLE eq #{@id}*\""
        @pids=nil
        #TODO prendre en compte l'UTF8
        f.readlines("\n").each { |l|
          CSV.parse(l) do |row|
            @@logger.an_event.info "row : #{row}"
            @pids = @pids.nil? ? [row[1]] : @pids + [row[1]]
          end
        }
        @@logger.an_event.warn "browser #{@id} pid not found #{@pids}" if @pids == [nil]
        if @pids == [nil]
          f = IO.popen("tasklist /FO CSV /NH /V /FI \"IMAGENAME eq  #{process_exe}\" /FI \"CPUTIME lt 0:00:01\"")
          @@logger.an_event.info "tasklist /FO CSV /NH /V /FI \"IMAGENAME eq  #{process_exe}\" /FI \"CPUTIME lt 0:00:01\""
          @pids=nil
          f.readlines("\n").each { |l| #TODO gerer l'utf8
            @@logger.an_event.info "l : #{l}"
            CSV.parse(l) do |row|
              @@logger.an_event.info "row : #{row}"
              @pids = @pids.nil? ? [row[1]] : @pids + [row[1]]
            end
          }
        end
        @@logger.an_event.error "browser #{process_exe} pid not found #{@pids}" if @pids == [nil]
        @@logger.an_event.info "browser #{process_exe} has pid #{@pids}" unless @pids == [nil]
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
          #TODO à supprimer si mass test et qu'aucune erreur nest affichée ne reproduit pas l'ouverture de tab dans IE
          start_time = Time.now
          arr = JSON.parse(@driver.fetch("_sahi.links()"))
          if arr.is_a?(String)
            @@logger.an_event.debug "error from extension.js : #{arr}"
            raise BrowserException::LINKS_LIST_FAILED
          end

          arr.map! { |link|
            if ["", "_top", "_self", "_parent"].include?(link["target"])
              Link.new(URI.parse(link["href"]), @driver.link(link["href"]), @driver.title, link["text"], nil)
            else
              @@logger.an_event.debug "link, href <#{link["href"]}> has bad target <#{link["target"]}>, so it is rejected"
              nil
            end
          }.compact
          #p "delay #{Time.now - start_time}"
          arr
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
      # open un sahi driver
      #----------------------------------------------------------------------------------------------------------------
      # input :
      #----------------------------------------------------------------------------------------------------------------
      def open
        count_try = 1
        max_count_try = 3
        fin = false
        while !fin
          begin
            @driver.open(@id)
            get_pid
            fin = true
            @@logger.an_event.debug "browser #{name} #{@id} is opened"
          rescue Exception => e
            @@logger.an_event.warn "browser #{name} #{@id} cannot be opened, try #{count_try}"
            @@logger.an_event.debug e
            count_try += 1
            fin = count_try > max_count_try
          end

        end
        if  count_try > max_count_try
          @@logger.an_event.error "browser #{name} #{@id} cannot be opened"
          raise BrowserException::BROWSER_NOT_STARTED
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
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.warn "browser #{name} #{@id} is not closed"
          begin
            @driver.kill(@pids)
          rescue Exception => e
            @@logger.an_event.debug e
            @@logger.an_event.error "browser #{name} #{@id} is not killed"
            raise BrowserException::BROWSER_NOT_CLOSE
          end
        end
        @@logger.an_event.debug "browser #{name} #{@id} is closed"
      end



      def search(keywords, engine_search)
        page = nil
        begin
          @driver.textbox(engine_search.id_search).value = keywords
          @driver.submit(engine_search.label_search_button).click
          @@logger.an_event.debug "browser #{name} #{@id} open url #{engine_search.page_url.to_s} in a new window"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          page = Page.new(page_details["url"],page_details["referrer"],page_details["title"], nil, page_details["links"],page_details["cookies"], Time.now - start_time)
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
require_relative 'firefox'
require_relative 'internet_explorer'
require_relative 'chrome'
require_relative 'safari'
require_relative 'opera'