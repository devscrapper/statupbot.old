require 'uuid'
require 'uri'
require 'sahi'
require 'json'
require 'csv'
require 'pathname'
require 'os'

require_relative '../../page/link'
require_relative '../../page/page'
require_relative '../../error'

module Browsers

  module SahiCoIn
    class Browser
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      include Errors
      include Pages

      #----------------------------------------------------------------------------------------------------------------
      # Exception message
      #----------------------------------------------------------------------------------------------------------------
      class BrowserError < Error

      end

      ARGUMENT_UNDEFINE = 300
      BROWSER_NOT_CREATE = 301 # à remonter en code retour de statupbot
      BROWSER_UNKNOWN = 302 # à remonter en code retour de statupbot
      BROWSER_NOT_FOUND_LINK = 303 # à remonter en code retour de statupbot
      BROWSER_NOT_DISPLAY_PAGE = 304 # à remonter en code retour de statupbot
      BROWSER_NOT_CLICK = 305
      BROWSER_NOT_OPEN = 306
      BROWSER_NOT_CLOSE = 307
      BROWSER_NOT_SEARCH = 308

      #----------------------------------------------------------------------------------------------------------------
      # constant
      #----------------------------------------------------------------------------------------------------------------
      TMP_DIR = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'tmp')).realpath
      NO_REFERER = "noreferrer"
      DATA_URI = "datauri"

      #----------------------------------------------------------------------------------------------------------------
      # attribut
      #----------------------------------------------------------------------------------------------------------------
      attr_accessor :driver,
                    :listening_port_proxy


      attr_reader :id,
                  :height,
                  :width,
                  :pids,
                  :method_start_page,
                  :version

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
      #         #Les navigateurs disponibles sont definis dans le fichier d:\sahi\userdata\config\browser_types.xml
      #----------------------------------------------------------------------------------------------------------------
      def self.build(visitor_dir, browser_details)
        @@logger.an_event.debug "BEGIN Browser.build"

        @@logger.an_event.debug "visitor_dir #{visitor_dir}"
        @@logger.an_event.debug "browser_details #{browser_details}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "browser_details undefine" if browser_details.nil?

        begin
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
              raise BrowserError.new(BROWSER_UNKNOWN), "browser <#{browser_details[:name]}> unknown"
          end
        rescue Exception => e
          @@logger.an_event.debug e.message
          raise e
        ensure
          @@logger.an_event.debug "END Browser.build"
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
      # StandardError :
      # si le listening_port_proxy n'est pas defini
      # si la resoltion d'ecran du browser n'est pas definie
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def initialize(browser_details, browser_type, method_start_page, visitor_dir)
        @@logger.an_event.debug "BEGIN Browser.initialize"
        @@logger.an_event.debug "browser_details #{browser_details}"
        @@logger.an_event.debug "browser_type #{browser_type}"
        @@logger.an_event.debug "method_start_page #{method_start_page}"
        @@logger.an_event.debug "visitor_dir #{visitor_dir}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "listening port proxy undefine" if browser_details[:listening_port_proxy].nil? or browser_details[:listening_port_proxy] == ""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "screen resolution undefine" if browser_details[:screen_resolution].nil? or browser_details[:screen_resolution] == ""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "browser_type undefine" if browser_type.nil? or browser_type == ""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "method_start_page undefine" if method_start_page.nil? or method_start_page == ""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "visitor_dir undefine" if visitor_dir.nil? or visitor_dir == ""


        @id = UUID.generate
        @method_start_page = method_start_page
        @listening_port_proxy = browser_details[:listening_port_proxy]
        @width, @height = browser_details[:screen_resolution].split(/x/)

        begin
          @driver = Browsers::SahiCoIn::Driver.new(browser_type,
                                                   @listening_port_proxy)
          customize_properties (visitor_dir)
        rescue Exception => e
          @@logger.an_event.fatal "browser #{@id} not create : #{e.message}"
          raise BrowserError.new(BROWSER_NOT_CREATE, e), "browser #{@id} not create"
        ensure
          @@logger.an_event.debug "END Browser.initialize"
        end
      end


      #-----------------------------------------------------------------------------------------------------------------
      # click_on
      #-----------------------------------------------------------------------------------------------------------------
      # input : objet Link
      # output : un objet Page
      # exception :
      # StandardError :
      # si link n'est pas defini
      # StandardError :
      # si impossibilité technique de clicker sur le lien
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def click_on(link)
        @@logger.an_event.debug "BEGIN Browser.click_on"
        @@logger.an_event.debug "link #{link.to_s}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "link undefine" if link.nil?

        if !link.exists?
          @@logger.an_event.fatal "browser #{name} #{@id} not found link #{link.to_s}"
          raise BrowserError.new(BROWSER_NOT_FOUND_LINK), "browser #{name} #{@id} not found link #{link.to_s}"
        end

        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.to_s}"

        begin
          link.click

          @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"


          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = @driver.get_details_current_page

          @@logger.an_event.debug "browser #{name} #{@id} catch details page #{link.url.to_s}"

          page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)

          @@logger.an_event.debug "browser #{name} #{@id} create page #{page.to_s}"

        rescue Error, Exception => e
          @@logger.an_event.error "browser #{name} #{@id} not click on url #{link.url.to_s} in window #{link.window_tab} : #{e.message}"
          raise BrowserError.new(BROWSER_NOT_CLICK, e), "browser #{name} #{@id} not click on url #{link.url.to_s} in window #{link.window_tab}"
        else
          return page
        ensure
          @@logger.an_event.debug "END Browser.click_on"
        end
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
      # StandardError :
      # si il est impossble d'ouvrir la page start
      # StandardError :
      # Si il est impossible de recuperer les propriétés de la page
      #----------------------------------------------------------------------------------------------------------------
      def display_start_page (url_start_page)
        @@logger.an_event.debug "BEGIN Browser.display_start_page"
        @@logger.an_event.debug "url_start_page : #{url_start_page}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "url_start_page undefine" if url_start_page.nil? or url_start_page == ""

        begin
          @driver.fetch(url_start_page)

          @@logger.an_event.debug "browser #{name} #{@id} open start page #{url_start_page}"

          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = @driver.get_details_current_page

          @@logger.an_event.debug "browser #{name} #{@id} catch details start page #{url_start_page}"

          start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)

          @@logger.an_event.debug "browser #{name} #{@id} create start page #{start_page.to_s}"

        rescue Error, Exception => e
          @@logger.an_event.fatal "browser #{name} #{@id} not open start page #{url_start_page} : #{e.message}"
          raise BrowserError.new(BROWSER_NOT_DISPLAY_PAGE, e), "browser #{name} #{@id} not open start page #{url_start_page}"
        else
          return start_page
        ensure
          @@logger.an_event.debug "END Browser.display_start_page"
        end
      end


      #-----------------------------------------------------------------------------------------------------------------
      # get_pid
      #-----------------------------------------------------------------------------------------------------------------
      # input : id_browser
      # output : tableau contenant les pids du browser
      # exception :
      # StandardError :
      # si id_browser n'est pas défini
      # si aucun pid n'a pu être associé à l'id_browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------
=begin
      def get_pid(id_browser)
        @@logger.an_event.debug "begin get_pid"
        raise StandardError, "id browser is not defined" if id_browser.nil?

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
              raise StandardError, "none mainWindowTitle in powershell contains id browser #{id_browser}" if pid_arr == []
            else
              raise StandardError, "file #{pids_name_file} not found"
            end
          rescue StandardError => e
            @@logger.an_event.debug "none mainWindowTitle in powershell contains id browser #{id_browser}, try #{try_count}"
            sleep (1)
            try_count += 1
            retry if pid_arr == [] and try_count < max_try_count
            @@logger.an_event.fatal "cannot get pid of #{id_browser}"
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise StandardError, "cannot get pid of #{id_browser}"
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
=end

      #-----------------------------------------------------------------------------------------------------------------
      # kill
      #-----------------------------------------------------------------------------------------------------------------
      # input : tableau de pids
      # output : none
      # exception :
      # StandardError :
      # si aucune pid n'est passé à la fonction
      # StandardError :
      # si il n'a pas été possible de tuer le browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------
=begin
      def kill(pid_arr)
        @@logger.an_event.debug "begin kill"
        raise StandardError, "no pid" if pid_arr == []

        pid_arr.each { |pid|
          if OS.windows?
            begin
              cmd = 'powershell -NoLogo -NoProfile "Stop-Process ' + pid.to_s + '; exit $LASTEXITCODE" < NUL'
              @@logger.an_event.debug "command powershell : #{cmd}"
              ps_pid = Process.spawn(cmd)
              Process.waitpid(ps_pid)
            rescue Exception => e
              @@logger.an_event.debug e.message
              raise StandardError, "cannot kill pid #{pid}"
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
=end

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
      # StandardError :
      # si il n'a pas été possible de lancer le browser  au moyen de sahi
      # si le titre de la fenetre du browser n'a pas pu être initialisé avec ld_browser
      # si le pid du browser n'a pas pu être recuperé
      #-----------------------------------------------------------------------------------------------------------------
      #   1-ouvre le browser
      #   2-affecte le titre du browser avec l'id_browser
      #   3-recupere le pid du browser
      #-----------------------------------------------------------------------------------------------------------------
      def open
        #TODO suivre les cookies du browser : s'assurer qu'il sont vide et alimenté quand il faut hahahahaha
        @@logger.an_event.debug "BEGIN Browser.open"
        begin
          @driver.open

          @@logger.an_event.debug "browser #{name} #{@id} open"

        rescue Error, Exception => e
          @@logger.an_event.error "browser #{name} #{@id} not open : #{e.message}"
          raise BrowserError.new(BROWSER_NOT_OPEN, e), "browser #{name} #{@id} not open "

        ensure
          @@logger.an_event.debug "END Browser.open"
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
        rescue StandardError => e
          @@logger.an_event.error e.message
          @@logger.an_event.debug "end open browser"
          raise StandardError, "browser #{name} no set title #{title_updt} with #{@id}"
        end
        #----------------------------------------------------------------------------------------------------
        #
        # recupere le PID du browser en fonction de l'id du browser dans le titre de la fenetre du browser
        #
        #-----------------------------------------------------------------------------------------------------
        begin
          @pids = get_pid(@id)
          @@logger.an_event.debug "browser #{name} #{@id} pid is retrieve"
        rescue StandardError => e
          @@logger.an_event.fatal e.message
          @@logger.an_event.debug "end open browser"
          raise StandardError, "browser #{name} #{@id} cannot get its pid"
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
      # StandardError :
      # si il n'a pas été possible de killer le browser automatiquement avec sahi ou manuellement
      #-----------------------------------------------------------------------------------------------------------------
      #   1-demande la fermeture du browser au driver
      #   2- si la demande échoue alors on kill manuellement le browser avec ses pids
      #   3-recupere le pid du browser
      #-----------------------------------------------------------------------------------------------------------------
      def quit
        @@logger.an_event.debug "BEGIN Browser.quit"
        begin
          @driver.close
          @@logger.an_event.debug "browser #{name} #{@id} close"

        rescue Error, Exception => e
          @@logger.an_event.error "browser #{name} #{@id} not close : #{e.message}"
          raise BrowserError.new(BROWSER_NOT_CLOSE, e), "browser #{name} #{@id} not close"
        ensure
          @@logger.an_event.debug "END Browser.quit"
=begin
          #----------------------------------------------------------------------------------------------------
          #
          # kill le browser en fonction de ses Pids
          #
          #-----------------------------------------------------------------------------------------------------
          begin
            kill(@pids)
            @@logger.an_event.debug "browser #{name} #{@id} is killed"
          rescue StandardError => e
            @@logger.an_event.error e.message
            @@logger.an_event.debug "end browser quit"
            raise StandardError, "browser #{name} #{@id} is not killed"
          ensure

          end
=end
        end

      end

      #-----------------------------------------------------------------------------------------------------------------
      # search
      #-----------------------------------------------------------------------------------------------------------------
      # input : les mots et le moteur de recherche
      # output : L'objet Page de la première page des resultats rendu par le moteur
      # exception :
      # StandardError :
      # si les mots cle ne sont pas defini
      # si le moteur de recherche n'est pas defini
      #-----------------------------------------------------------------------------------------------------------------
      #   1-saisie les mots clé dans la zone de saisie du moteur
      #   2-valide la saisie par le click sur el bouton
      #   3-recupere les détails de la page recue
      #   4-retourne un objet Page
      #-----------------------------------------------------------------------------------------------------------------
      def search(keywords, engine_search)
        @@logger.an_event.debug "BEGIN Browser.search"
        @@logger.an_event.debug "keywords #{keywords}"
        @@logger.an_event.debug "engine_search #{engine_search.class}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "keywords undefine" if keywords.nil? or keywords==""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "engine_search undefine" if engine_search.nil?

        begin
          @driver.search(keywords, engine_search)

          @@logger.an_event.debug "browser #{name} #{@id} submit search form #{engine_search.class}"

          start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
          page_details = @driver.get_details_current_page

          @@logger.an_event.debug "browser #{name} #{@id} catch details search page"

          search_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)

          @@logger.an_event.debug "browser #{name} #{@id} create search page #{search_page.to_s}"

        rescue Error, Exception => e
          @@logger.an_event.error "browser #{name} #{@id} cannot submit search form #{engine_search.class} : #{e.message}"
          @@logger.an_event.debug "END Browser.search"
          raise BrowserError.new(BROWSER_NOT_SEARCH, e), "browser #{name} #{@id} cannot submit search form #{engine_search.class}"
        else
          return search_page
        ensure
          @@logger.an_event.debug "END Browser.search"

        end

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
        @@logger.an_event.debug "BEGIN Browser.wait_on"
        @@logger.an_event.debug "page #{page.to_s}"

        raise BrowserError.new(ARGUMENT_UNDEFINE), "page undefine" if page.nil?

        @@logger.an_event.debug "browser #{name} #{@id} start waiting on page #{page.url}"

        sleep page.sleeping_time

        @@logger.an_event.debug "browser #{name} #{@id} finish waiting on page #{page.url}"
        @@logger.an_event.debug "END Browser.wait_on"
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
require_relative 'driver'
require_relative 'proxy'