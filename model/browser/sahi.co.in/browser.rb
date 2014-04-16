require 'uuid'
require 'uri'
require 'sahi'
require 'json'
require 'csv'
require 'pathname'
require 'os'
require_relative '../../page/link'
require_relative '../../page/page'
require_relative 'driver'
require_relative 'proxy'

module Browsers
  class FunctionalError < StandardError

  end
  class TechnicalError < StandardError

  end
  module SahiCoIn
    class Browser
      class FunctionalException < StandardError

      end
      class TechnicalException < StandardError

      end

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
      VISITORS_DIR = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'visitors')).realpath
      LOG_DIR = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'log')).realpath
      TMP_DIR = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'tmp')).realpath
      NO_REFERER = "noreferrer"
      DATA_URI = "datauri"
      attr_accessor :driver,
                    :listening_port_proxy


      attr_reader :id,
                  :height,
                  :width,
                  :pids,
                  :method_start_page,
                  :version,
                  :proxy_system # le browser utilise le proxy de windows

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
            @@logger.an_event.warn "browser <#{browser_details[:name]}> unknown"
            raise FunctionalError, "browser <#{browser_details[:name]}> unknown"
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
        raise FunctionalException, "listening port sahi proxy is not defined" if browser_details[:listening_port_proxy].nil?
        raise FunctionalException, "screen resoluton is not defined" if browser_details[:screen_resolution].nil?
        begin
          @id = UUID.generate
          @listening_port_proxy = browser_details[:listening_port_proxy]
          @width, @height = browser_details[:screen_resolution].split(/x/)
          @proxy_system = browser_details[:proxy_system]
        rescue Exception => e
          @@logger.an_event.debug e
          raise Browsers::SahiCoIn::Browser::TechnicalException, e.message
        end
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
        begin
          page_details = @driver.current_page_details
          page_details["links"].map! { |link|
            if ["", "_top", "_self", "_parent"].include?(link["target"])
              Link.new(URI.parse(link["href"]), @driver.link(link["href"]), page_details["title"], link["text"], nil)
            else
              @@logger.an_event.debug "link, href <#{link["href"]}> has bad target <#{link["target"]}>, so it is rejected"
              nil
            end
          }.compact
          raise FunctionalException, "current page has no link" if page_details.size == 0
          page_details
        rescue Exception => e
          @@logger.an_event.debug e
          raise Browsers::SahiCoIn::Browser::TechnicalException, e.message
        end
      end

      def click_on(link)
        page = nil
        begin
          link.click
          @@logger.an_event.info "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"

          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)
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
            page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)
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


      def get_pid(id_browser)
        @@logger.an_event.debug "begin get_pid"
        raise FunctionalException, "id browser is not defined" if id_browser.nil?

        if OS.windows?
          pid_arr = nil
          pids_name_file = File.join(TMP_DIR, "#{id_browser}_pids.csv")
          try_count = 0
          max_try_count = 10
          begin
            File.delete(pids_name_file) if File.exist?(pids_name_file)
            cmd = 'powershell -NoLogo -NoProfile "get-process | where-object {$_.mainWindowTitle -like \"' + "#{id_browser}*" + '\"} | Export-Csv -notype ' + pids_name_file + '; exit $LASTEXITCODE" < NUL'
            @@logger.an_event.debug "command powershell : #{cmd}"
            @pid = Process.spawn(cmd)
            Process.waitpid(@pid)
            if File.exist?(pids_name_file)
              pid_arr = CSV.table(pids_name_file).by_col[:id]
              @@logger.an_event.debug "pids catch : #{pid_arr}"
              File.delete(pids_name_file)
              raise FunctionalError, "none mainWindowTitle in powershell contains id browser #{id_browser}" if pid_arr == []
            else
              raise TechnicalError, "file #{pids_name_file} not found"
            end
          rescue FunctionalError => e
            @@logger.an_event.debug "none mainWindowTitle in powershell contains id browser #{id_browser}, try #{try_count}"
            sleep (1)
            try_count += 1
            retry if pid_arr == [] and try_count < max_try_count
            @@logger.an_event.FATAL "cannot get pid of #{id_browser}"
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise "cannot get pid of #{id_browser}"
          ensure
            @@logger.an_event.debug "end get_pid"
          end
        elsif OS.mac?
          #TODO determiner le get_pid pour mac
        elsif OS.linux?
          #TODO determiner le get_pid pour linux
        end


        pid_arr
      end


      def kill(pid_arr)
        @@logger.an_event.debug "begin kill"
        raise FunctionalError, "no pid" if pid_arr == []

        pid_arr.each { |pid|
          if OS.windows?
            begin
              cmd = 'powershell -NoLogo -NoProfile "Stop-Process ' + pid.to_s + '; exit $LASTEXITCODE" < NUL'
              @@logger.an_event.debug "command powershell : #{cmd}"
              ps_pid = Process.spawn(cmd)
              Process.waitpid(ps_pid)
            rescue Exception => e
              @@logger.an_event.debug e.message
              raise TechnicalError, "cannot kill pid #{pid}"
            ensure
              @@logger.an_event.debug "end kill"
            end
          elsif OS.mac?
            #TODO determiner le get_pid pour mac
          elsif OS.linux?
            #TODO determiner le get_pid pour linux
          end
        }
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
        @@logger.an_event.debug "begin open browser"
        begin
          @driver.open
          @@logger.an_event.debug "browser #{name} #{@id} is opened"
        rescue TechnicalError => e
          @@logger.an_event.debug e.message
          raise TechnicalError, "browser #{name} #{@id} cannot be opened"
        ensure
          @@logger.an_event.debug "end open browser"
        end

        #----------------------------------------------------------------------------------------------------
        #
        # affecte l'id du browser dans le title de la fenetre
        #
        #-----------------------------------------------------------------------------------------------------
        begin
          title_updt = @driver.set_title(@id)
          @@logger.an_event.debug "browser #{name} has set title #{title_updt}"
        rescue TechnicalError => e
          @@logger.an_event.error e.message
          raise TechnicalError, "browser #{name} cannot close"
        ensure
          @@logger.an_event.debug "end open browser"
        end
        #----------------------------------------------------------------------------------------------------
        #
        # recupere le PID du browser en fonction de l'id du browser dans le titre de la fenetre du browser
        #
        #-----------------------------------------------------------------------------------------------------
        begin
          @pids = get_pid(@id)
          @@logger.an_event.debug "browser #{name} pid is retrieve"
        rescue TechnicalError => e
          @@logger.an_event.FATAL e.message
          raise TechnicalError, "browser #{name} cannot get pid"
        ensure
          @@logger.an_event.debug "end open browser"
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
        @@logger.an_event.debug "begin browser quit"
        begin
          @driver.close
          @@logger.an_event.debug "browser #{name} is closed"
        rescue TechnicalError => e
          @@logger.an_event.debug e.message
          # recuperation des pid du browser au cas ou le kill de sahi ne fonctionne pas qd il y a plusieurs instance du
          # du même process lancé.
          #----------------------------------------------------------------------------------------------------
          #
          # kill le browser en fonction de ses Pids
          #
          #-----------------------------------------------------------------------------------------------------
          begin
            kill(@pids)
            @@logger.an_event.debug "browser #{name} is killed"
          rescue TechnicalError => e
            @@logger.an_event.error e.message
            raise TechnicalError, "browser #{name} #{@id} is not killed"
          ensure
            @@logger.an_event.debug "end browser quit"
          end
        end
      end


      def search(keywords, engine_search)
        page = nil
        begin
          @driver.textbox(engine_search.id_search).value = keywords
          @driver.submit(engine_search.label_search_button).click
          @@logger.an_event.debug "browser #{name} #{@id} open url #{engine_search.page_url.to_s} in a new window"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "browser #{name} #{@id} cannot search #{keywords} with engine #{engine_search.class}"
        end
        page
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