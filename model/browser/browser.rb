# encoding: utf-8
require 'uuid'
require 'uri'
require 'json'
require 'csv'
require 'pathname'
require 'win32/screenshot'

require_relative '../engine_search/engine_search'
require_relative '../page/link'
require_relative '../page/page'
require_relative '../../lib/error'
require_relative '../../lib/flow'
require_relative '../../lib/sahi'

module Browsers
  class Browser
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Pages

    #----------------------------------------------------------------------------------------------------------------
    # Exception message
    #----------------------------------------------------------------------------------------------------------------
    ARGUMENT_UNDEFINE = 300
    BROWSER_NOT_CREATE = 301
    BROWSER_UNKNOWN = 302
    BROWSER_NOT_FOUND_LINK = 303
    BROWSER_NOT_DISPLAY_PAGE = 304
    BROWSER_NOT_CLICK = 305
    BROWSER_NOT_OPEN = 306
    BROWSER_NOT_CLOSE = 307
    BROWSER_NOT_SEARCH = 308
    BROWSER_NOT_TAKE_SCREENSHOT = 309
    BROWSER_NOT_CUSTOM_FILE = 310
    BROWSER_NOT_ACCESS_URL = 311
    BROWSER_NOT_DISPLAY_START_PAGE = 312
    BROWSER_NOT_CONNECT_TO_SERVER = 313
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    TMP_DIR = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp')).realpath
    SCREENSHOT = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'screenshot')).realpath
    NO_REFERER = "noreferrer"
    DATA_URI = "datauri"
    WITHOUT_LINKS = false #utiliser pour préciser que on ne recupere pas les links avec la fonction de l'extension javascript : get_details_cuurent_page
    WITH_LINKS = true
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_accessor :driver, # moyen Sahi pour piloter le browser
                  :listening_port_proxy # port d'ecoute du proxy Sahi


    attr_reader :id, #id du browser
                :height, :width, #dimension de la fenetre du browser
                :method_start_page, # pour cacher le referrer aux yeux de GA, on utiliser 2 methodes choisies en focntion
                # du type de browser.
                :version, # la version du browser
                :engine_search  #moteur de recherche associé par defaut au navigateur

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # build
    #----------------------------------------------------------------------------------------------------------------
    # crée un geolocation :
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # repertoire de runtime du visitor
    # détails du browser issue du fichier de visit :
    # :name: Chrome
    # :version: '33.0.1750.117'
    # :operating_system: Windows
    # :operating_system_version: '7'
    # :flash_version: 11.5 r502      # 2014/09/10 : non utilisé
    # :java_enabled: 'Yes'           # 2014/09/10 : non utilisé
    # :screens_colors: 32-bit        # 2014/09/10 : non utilisé
    # :screen_resolution: 1366x768
    # output : none
    # StandardError :
    # les paramètres en entrée font défaut
    # le type de browser est inconnu
    # une exception provenant des classes Firefox, InterneEexplorer, Chrome
    #----------------------------------------------------------------------------------------------------------------
    #         #Les navigateurs disponibles sont definis dans le fichier d:\sahi\userdata\config\browser_types.xml
    #----------------------------------------------------------------------------------------------------------------
    def self.build(visitor_dir, browser_details)
      @@logger.an_event.debug "browser_details #{browser_details}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser name"}) if browser_details.nil? or \
        browser_details[:name].nil? or \
        browser_details[:name] == ""

        browser_name = browser_details[:name]

        case browser_name
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
            raise Error.new(BROWSER_UNKNOWN, :values => {:browser => browser_name})
        end
      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(BROWSER_NOT_CREATE, :values => {:browser => browser_name}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} create"
      ensure

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
    # si la resolution d'ecran du browser n'est pas definie
    # si le type de browser n'est pas definie
    # si la méthode démarrage n'est pas définie
    # si le runtime dir n'est pas definie
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def initialize(browser_details, browser_type, method_start_page, visitor_dir)


      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "listening_port_proxy"}) if browser_details[:listening_port_proxy].nil? or browser_details[:listening_port_proxy] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "screen_resolution"}) if browser_details[:screen_resolution].nil? or browser_details[:screen_resolution] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "method_start_page"}) if method_start_page.nil? or method_start_page == ""

        @@logger.an_event.debug "listening_port_proxy #{browser_details[:listening_port_proxy]}"
        @@logger.an_event.debug "screen_resolution #{browser_details[:screen_resolution]}"
        @@logger.an_event.debug "method_start_page #{method_start_page}"

        @id = UUID.generate
        @method_start_page = method_start_page
        @listening_port_proxy = browser_details[:listening_port_proxy]
        @width, @height = browser_details[:screen_resolution].split(/x/)

        @engine_search = EngineSearch.build(browser_details[:engine_search])

        @driver = Browsers::Driver.new(browser_type,
                                       @listening_port_proxy)

        customize_properties (visitor_dir)

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise e

      else
        @@logger.an_event.debug "browser #{name} initialize"
      ensure

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
      @@logger.an_event.debug "link #{link.to_s}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "link"}) if link.nil?

        link.exists?

        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.text}"

        link.click

        @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.url.to_s} in window #{link.window_tab}"

        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens

        page_details = @driver.get_details_current_page(link.url.to_s)

        @@logger.an_event.debug "browser #{name} #{@id} catch details page #{link.url.to_s}"

        page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)

        @@logger.an_event.debug "browser #{name} #{@id} create page #{page.to_s}"

      rescue Exception => e
        @@logger.an_event.error e.message

        raise Error.new(BROWSER_NOT_CLICK, :values => {:browser => name, :link => link.text}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} display page #{page.to_s}"
        return page

      ensure

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
    def display_start_page (sahi_cmd, url_start_page)

      @@logger.an_event.debug "url_start_page : #{url_start_page}"
      @@logger.an_event.debug "sahi_cmd : #{sahi_cmd}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "url_start_page"}) if url_start_page.nil? or url_start_page == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "sahi_cmd"}) if sahi_cmd.nil? or sahi_cmd == ""

        old_page_title = @driver.title

        @driver.fetch("#{sahi_cmd}(\"#{url_start_page}\")")

        url = url_start_page.split(",")[0]
        hostname = URI.parse(url[0..url.size - 2]).hostname
        #pb de connection reseau par exemple
        raise Error.new(BROWSER_NOT_CONNECT_TO_SERVER, :values => {:browser => name, :domain => hostname}) if @driver.div("error_connect").exists?

        new_page_title = @driver.title
        #erreur sahi...on est tj sur la page initiale de sahi
        raise Error.new(BROWSER_NOT_ACCESS_URL, :values => {:browser => name, :url => url_start_page}) if new_page_title == old_page_title

        @@logger.an_event.debug "browser #{name} #{@id} open start page #{url}"

        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens

        page_details = @driver.get_details_current_page(url_start_page)

        @@logger.an_event.debug "browser #{name} #{@id} catch details start page #{url_start_page}"

        start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)

        @@logger.an_event.debug "browser #{name} #{@id} create start page #{start_page.to_s}"

      rescue Exception => e
        @@logger.an_event.fatal e.message

        raise Error.new(BROWSER_NOT_DISPLAY_START_PAGE, :values => {:browser => name, :page => url_start_page}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} display start page #{start_page.to_s}"
        return start_page

      ensure

      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # find_link
    #----------------------------------------------------------------------------------------------------------------
    # retourne un link identifié par le domain de la page html et un attribut de la balise html <a>
    #----------------------------------------------------------------------------------------------------------------
    # input : nom de domaine, identifier du link
    # output : un objet sahi représentant le link ou nil si non trouvé
    #----------------------------------------------------------------------------------------------------------------
    def find_link(domain = nil, identifier)

      @@logger.an_event.debug "domain : #{domain}"
      @@logger.an_event.debug "identifier : #{identifier}"

      link = nil

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "identifier"}) if identifier.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "domain"}) if domain.nil?

        link = @driver.domain(domain).link(identifier)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_FOUND_LINK, :values => {:domain => domain, :identifier => identifier}, :error => e)

      else
        @@logger.an_event.debug "link #{domain} #{identifier} found : #{link.to_s}"

        return link

      ensure

      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # find_links
    #----------------------------------------------------------------------------------------------------------------
    # retourne un array de link identifié par le domain de la page html et un attribut de la balise html <a>
    #----------------------------------------------------------------------------------------------------------------
    # input : nom de domaine, identifier du link
    # output : un objet sahi représentant le link ou nil si non trouvé
    #----------------------------------------------------------------------------------------------------------------
    def find_links(domain = nil, identifier)

      @@logger.an_event.debug "domain : #{domain}"
      @@logger.an_event.debug "identifier : #{identifier}"


      links = []

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "domain"}) if domain.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "identifier"}) if identifier.nil?

        frame = @driver.domain(domain)
        if frame.exists?
          links = frame.link(identifier).collect_similar

        end
      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_FOUND_LINK, :values => {:domain => domain, :identifier => identifier}, :error => e)

      else
        @@logger.an_event.debug "links #{domain} #{identifier} found : #{links.to_s}"

        return links

      ensure

      end
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

      begin
        @driver.open

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_OPEN, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} open"

      ensure

      end

    end


    #-----------------------------------------------------------------------------------------------------------------
    # quit
    #-----------------------------------------------------------------------------------------------------------------
    # input : none
    # output : none
    # StandardError :
    # si il n'a pas été possible de killer le browser automatiquement avec sahi
    #-----------------------------------------------------------------------------------------------------------------
    #   1-demande la fermeture du browser au driver
    #   3-recupere le pid du browser
    #-----------------------------------------------------------------------------------------------------------------
    def quit

      begin

        @driver.close

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_CLOSE, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} close"

      ensure

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
    def search(keywords)

      @@logger.an_event.debug "keywords #{keywords}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keywords"}) if keywords.nil? or keywords==""



        @engine_search.search(keywords, @driver)

        @@logger.an_event.debug "browser #{name} #{@id} submit search form #{@engine_search.class}"

        start_time = Time.now # permet de déduire du temps de lecture de la page le temps passé à chercher les liens
        page_details = @driver.get_details_current_page(@engine_search.page_url, WITHOUT_LINKS)

        @@logger.an_event.debug "browser #{name} #{@id} catch details search page"

        search_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"], Time.now - start_time)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_SEARCH, :values => {:browser => name, :url => @engine_search.page_url}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} create search page #{search_page.to_s}"
        return search_page

      ensure

      end

    end

    #-----------------------------------------------------------------------------------------------------------------
    # screenshot
    #-----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : image du contenu du browser dans le repertoire screenshot
    # exception : none
    #-----------------------------------------------------------------------------------------------------------------
    # on ne genere pas d'execption pour ne pas perturber la remonter des exception de visitor_bot, car ce n'est pas
    # grave si on ne pas faire de screenshot
    # => on ne fait que logger
    #-----------------------------------------------------------------------------------------------------------------
    def screenshot(id_visitor, vol = 1)

      if id_visitor.nil?
        @@logger.an_event.error  Messages.instance[ARGUMENT_UNDEFINE, {:variable => "id_visitor"}]
      else
        begin
          @@logger.an_event.debug @driver.title

          title = @driver.title #suppression des carracteres non ascii
          @@logger.an_event.debug title
          output_file = Flow.new(SCREENSHOT, id_visitor, title[0..32], Date.today, vol, ".png")
          output_file.delete if output_file.exist?
          #Win32::Screenshot::Take.of(:window, :title => title).write(output_file.absolute_path)

        rescue Exception => e
          @@logger.an_event.error e.message
          @@logger.an_event.error Messages.instance[BROWSER_NOT_TAKE_SCREENSHOT,{:browser => name, :title => title}]

        else

          @@logger.an_event.info "browser #{name} take screen shot of #{title}"

        ensure

        end
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

      @@logger.an_event.debug "page #{page.to_s}"

      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "page"}) if page.nil?

      @@logger.an_event.debug "browser #{name} #{@id} start waiting on page #{page.url}"

      sleep page.sleeping_time

      @@logger.an_event.debug "browser #{name} #{@id} finish waiting on page #{page.url}"

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