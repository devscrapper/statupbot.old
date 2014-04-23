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

      #-----------------------------------------------------------------------------------------------------------------
      # initialize
      #-----------------------------------------------------------------------------------------------------------------
      # input : hash decrivant les propriétés du browser de la visit
      # :name : Internet Explorer
      # :version : '9.0'
      # :operating_system : Windows
      # :operating_system_version : '7'
      # :flash_version : 11.7 r700   -- not use
      # :java_enabled : 'Yes'        -- not use
      # :screens_colors : 32-bit     -- not use
      # :screen_resolution : 1600 x900
      # output : un objet Browser
      # exception :
      # FunctionalError :
      # si le listening_port_proxy n'est pas defini
      # si la resoltion d'ecran du browser n'est pas definie
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def initialize(browser_details)
        raise FunctionalError, "listening port sahi proxy is not defined" if browser_details[:listening_port_proxy].nil?
        raise FunctionalError, "screen resoluton is not defined" if browser_details[:screen_resolution].nil?
        begin
          @id = UUID.generate
          @listening_port_proxy = browser_details[:listening_port_proxy]
          @width, @height = browser_details[:screen_resolution].split(/x/)
          @proxy_system = browser_details[:proxy_system]
        rescue Exception => e
          @@logger.an_event.debug e
          raise TechnicalError, e.message
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # current_page_details
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : un hash contenant les infos suivantes de la page actuellement affichée dans le browser
      #  url
      #  referrer
      #  titre
      #  array d'objet Link
      #  cookies
      # exception :
      # FunctionalError :
      # si la page n'a aucun lien
      # TechnicalError
      # si impossibilité technique de recuperer les infos details
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def current_page_details
        @@logger.an_event.debug "begin current_page_details"
        page_details = nil
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
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end current_page_details"
          raise TechnicalError, "browser #{name} #{@id} cannot catch current page details"
        end
        if page_details.size == 0
          @@logger.an_event.warn "#{page_details["url"]} has no link"
          @@logger.an_event.debug "end current_page_details"
          raise FunctionalError, "#{page_details["url"]} has no link" if page_details.size == 0
        end
        @@logger.an_event.debug "end current_page_details"
        page_details
      end

      #-----------------------------------------------------------------------------------------------------------------
      # click_on
      #-----------------------------------------------------------------------------------------------------------------
      # input : objet Link
      # output : un objet Page
      # exception :
      # FunctionalError :
      # si link n'est pas defini
      # TechnicalError :
      # si impossibilité technique de clicker sur le lien
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def click_on(link)
        @@logger.an_event.debug "begin click_on"
        raise FunctionalError, "link is not define" if link.nil?
        @@logger.an_event.debug "link #{link.to_s}"
        page = nil
        begin
          link.click
          @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.error "browser #{name} #{@id} cannot try to click on url #{link.url.to_s}"
          raise TechnicalError, "browser #{name} #{@id} cannot try to click on url #{link.url.to_s}"
        end
        @@logger.an_event.debug "end click_on"
        page
      end


      #----------------------------------------------------------------------------------------------------------------
      # display_start_page
      #----------------------------------------------------------------------------------------------------------------
      # ouvre un nouvelle fenetre du navigateur adaptée aux propriété du naviagateur et celle de la visit
      # affiche la root page du site https pour initialisé le référer à non défini
      #----------------------------------------------------------------------------------------------------------------
      # input : url (String)
      # output : Objet Page
      # exception :
      # TechnicalError :
      # si il est impossble d'ouvrir la page start
      # FunctionalError :
      # Si il est impossible de recuperer les propriétés de la page
      #----------------------------------------------------------------------------------------------------------------
      def display_start_page (url_start_page)
        @@logger.an_event.debug "begin display_start_page"
        @@logger.an_event.debug "url_start_page : #{url_start_page}"
        begin
          @driver.fetch(url_start_page)
          @@logger.an_event.debug "browser #{name} #{@id} open start page"
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end display_start_page"
          raise TechnicalError, "browser #{name} #{@id} cannot open start page"
        end

        begin
          page_details = current_page_details
        rescue TechnicalError, FunctionalError, Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end display_start_page"
          raise FunctionalError, "browser #{name} #{@id} cannot catch details start page"
        end
        start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"],)
        @@logger.an_event.debug "end display_start_page"
        start_page
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
=begin
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
=end

      #-----------------------------------------------------------------------------------------------------------------
      # get_pid
      #-----------------------------------------------------------------------------------------------------------------
      # input : id_browser
      # output : tableau contenant les pids du browser
      # exception :
      # FunctionalError :
      # si id_browser n'est pas défini
      # si aucun pid n'a pu être associé à l'id_browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------
      def get_pid(id_browser)
        @@logger.an_event.debug "begin get_pid"
        raise FunctionalError, "id browser is not defined" if id_browser.nil?

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
            @@logger.an_event.fatal "cannot get pid of #{id_browser}"
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise FunctionalError, "cannot get pid of #{id_browser}"
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

      #-----------------------------------------------------------------------------------------------------------------
      # kill
      #-----------------------------------------------------------------------------------------------------------------
      # input : tableau de pids
      # output : none
      # exception :
      # FunctionalError :
      # si aucune pid n'est passé à la fonction
      # TechnicalError :
      # si il n'a pas été possible de tuer le browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------
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
      # output : le nom du browser
      #----------------------------------------------------------------------------------------------------------------
      def name
        @driver.browser_type
      end

      #-----------------------------------------------------------------------------------------------------------------
      # open
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # TechnicalError :
      # si il n'a pas été possible de lancer le browser  au moyen de sahi
      # si le titre de la fenetre du browser n'a pas pu être initialisé avec ld_browser
      # si le pid du browser n'a pas pu être recuperé
      #-----------------------------------------------------------------------------------------------------------------
      #   1-ouvre le browser
      #   2-affecte le titre du browser avec l'id_browser
      #   3-recupere le pid du browser
      #-----------------------------------------------------------------------------------------------------------------
      def open
        @@logger.an_event.debug "begin open browser"
        begin
          @driver.open
          @@logger.an_event.debug "browser #{name} #{@id} is opened"
        rescue TechnicalError => e
          @@logger.an_event.debug e.message
          @@logger.an_event.debug "end open browser"
          raise TechnicalError, "browser #{name} #{@id} cannot be opened"
        end

=begin
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
          @@logger.an_event.debug "end open browser"
          raise TechnicalError, "browser #{name} no set title #{title_updt} with #{@id}"
        end
        #----------------------------------------------------------------------------------------------------
        #
        # recupere le PID du browser en fonction de l'id du browser dans le titre de la fenetre du browser
        #
        #-----------------------------------------------------------------------------------------------------
        begin
          @pids = get_pid(@id)
          @@logger.an_event.debug "browser #{name} #{@id} pid is retrieve"
        rescue TechnicalError => e
          @@logger.an_event.fatal e.message
          @@logger.an_event.debug "end open browser"
          raise TechnicalError, "browser #{name} #{@id} cannot get its pid"
        ensure
          @@logger.an_event.debug "end open browser"
        end
=end
      end


      #-----------------------------------------------------------------------------------------------------------------
      # quit
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # TechnicalError :
      # si il n'a pas été possible de killer le browser automatiquement avec sahi ou manuellement
      #-----------------------------------------------------------------------------------------------------------------
      #   1-demande la fermeture du browser au driver
      #   2- si la demande échoue alors on kill manuellement le browser avec ses pids
      #   3-recupere le pid du browser
      #-----------------------------------------------------------------------------------------------------------------
      def quit
        @@logger.an_event.debug "begin browser quit"
        begin
          @driver.close
          @@logger.an_event.debug "browser #{name} is closed"
        rescue TechnicalError => e
          @@logger.an_event.debug e.message
=begin
          #----------------------------------------------------------------------------------------------------
          #
          # kill le browser en fonction de ses Pids
          #
          #-----------------------------------------------------------------------------------------------------
          begin
            kill(@pids)
            @@logger.an_event.debug "browser #{name} #{@id} is killed"
          rescue TechnicalError => e
            @@logger.an_event.error e.message
            @@logger.an_event.debug "end browser quit"
            raise TechnicalError, "browser #{name} #{@id} is not killed"
          ensure

          end
=end
        end
        @@logger.an_event.debug "end browser quit"
      end

      #-----------------------------------------------------------------------------------------------------------------
      # search
      #-----------------------------------------------------------------------------------------------------------------
      # input : les mots et le moteur de recherche
      # output : L'objet Page de la première page des resultats rendu par le moteur
      # exception :
      # FunctionalError :
      # si les mots cle ne sont pas defini
      # si le moteur de recherche n'est pas defini
      #-----------------------------------------------------------------------------------------------------------------
      #   1-saisie les mots clé dans la zone de saisie du moteur
      #   2-valide la saisie par le click sur el bouton
      #   3-recupere les détails de la page recue
      #   4-retourne un objet Page
      #-----------------------------------------------------------------------------------------------------------------
      def search(keywords, engine_search)
        @@logger.an_event.debug "begin browser search"
        raise FunctionalError, "keywords ar not define" if keywords.nil? or keywords==""
        raise FunctionalError, "engine search is not define" if engine_search.nil?

        page = nil
        begin
          @driver.textbox(engine_search.id_search).value = keywords
          @@logger.an_event.debug "browser #{name} #{@id} enter keywords #{keywords} in search forma #{engine_search.class}"
          @driver.submit(engine_search.label_search_button).click
          @@logger.an_event.debug "browser #{name} #{@id} submit search form #{engine_search.class}"
          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = current_page_details
          @@logger.an_event.debug "browser #{name} #{@id} get details page #{engine_search.page_url.to_s}"
          page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)
        rescue Exception => e
          @@logger.an_event.debug e.message
          raise FunctionalError, "browser #{name} #{@id} cannot search #{keywords} with engine #{engine_search.class}"
        end
        @@logger.an_event.debug "end browser search"
        page
      end

      #-----------------------------------------------------------------------------------------------------------------
      # wait_on
      #-----------------------------------------------------------------------------------------------------------------
      # input : un objet Page
      # output : none
      # exception : none
      #-----------------------------------------------------------------------------------------------------------------
      #   sleep during some delay of page
      #-----------------------------------------------------------------------------------------------------------------
      def wait_on(page)
        @@logger.an_event.debug "browser #{name} #{@id} start waiting on page #{page.url}"
        sleep page.sleeping_time
        @@logger.an_event.debug "browser #{name} #{@id} finish waiting on page #{page.url}"
      end
=begin

      def well_formed?(url)
        begin
          URI.parse(url)
          return true
        rescue Exception => e
          @@logger.an_event.debug "#{e.message}, url"
          return false
        end
      end
=end

    end

  end
end
require_relative 'firefox'
require_relative 'internet_explorer'
require_relative 'chrome'
require_relative 'safari'
require_relative 'opera'