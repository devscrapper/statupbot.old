# encoding: utf-8
require 'uuid'
require 'uri'
require 'json'
require 'csv'
require 'pathname'
require 'nokogiri'
require 'addressable/uri'
require 'win32/screenshot'

require_relative '../engine_search/engine_search'
require_relative '../page/link'
require_relative '../page/page'
require_relative '../../lib/error'
require_relative '../../lib/flow'
#require_relative '../../lib/sahi'

module Browsers
  class Browser
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Pages
    include EngineSearches
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
    BROWSER_NOT_GO_BACK = 314
    BROWSER_NOT_SUBMIT_FORM = 315
    BROWSER_NOT_FOUND_ALL_LINK = 316
    BROWSER_NOT_FOUND_URL = 317
    BROWSER_NOT_FOUND_TITLE = 318
    BROWSER_NOT_GO_TO = 319
    BROWSER_NOT_FOUND_BODY = 320
    BROWSER_CLICK_MAX_COUNT = 321
    BROWSER_NOT_SET_INPUT_SEARCH = 322
    BROWSER_NOT_SET_INPUT_CAPTCHA = 323
    BROWSER_NOT_TAKE_CAPTCHA = 324
    BROWSER_NOT_RELOAD = 325
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    NO_REFERER = "noreferrer"
    DATA_URI = "datauri"
    WITHOUT_LINKS = false #utiliser pour préciser que on ne recupere pas les links avec la fonction de l'extension javascript : get_details_cuurent_page
    WITH_LINKS = true
    DIR_TMP = [File.dirname(__FILE__), "..", "..", "tmp"]
    #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_accessor :driver, # moyen Sahi pour piloter le browser
                  :listening_port_proxy # port d'ecoute du proxy Sahi


    attr_reader :id, #id du browser
                :height, :width, #dimension de la fenetre du browser
                :current_page, #page/onglet visible du navigateur
                :method_start_page, # pour cacher le referrer aux yeux de GA, on utiliser 2 methodes choisies en focntion
                # du type de browser.
                :version, # la version du browser
                :engine_search #moteur de recherche associé par defaut au navigateur

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
      @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

      @@logger.an_event.debug "browser_details #{browser_details}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser name"}) if browser_details.nil? or \
        browser_details[:name].nil? or \
        browser_details[:name] == ""

        browser_name = browser_details[:name]
        # le browser name doit rester une chaine de car (et pas un symbol) car tout le param BrowserType utilise le format chaine de caractere
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
          when "Opera"
            return Opera.new(visitor_dir, browser_details)

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
    # all_links
    #-----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : tableau de link
    # Array of {'href' => ...., 'target' => ...., 'text' => ...}
    # exception :
    # si aucun link n'a été trouvé
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def all_links

      links = []
      count = 5
      i = 0
      begin

        results_str = @driver.links

        raise "_sahi.links() not return links of page" if results_str == "" or results_str.nil?

        results_hsh = JSON.parse(results_str)

        @@logger.an_event.debug "results_hsh #{results_hsh}"
        links_str = results_hsh["links"]


        @@logger.an_event.debug "links_str String ? #{links_str.is_a?(String)}"
        @@logger.an_event.debug "links_str Array ? #{links_str.is_a?(Array)}"

        if links_str.is_a?(String)
          links_arr = JSON.parse(links_str)
        else
          links_arr = links_str
        end
        @@logger.an_event.debug "links_str #{links_arr}"

        links_arr.each { |d|
          if d["text"] != "undefined"
            links << {"href" => d["href"], "text" => URI.unescape(d["text"].gsub(/&#44;/, "'"))} # if @driver.link(d["href"]).visible?
          else
            links << {"href" => d["href"], "text" => d["href"]}
          end
        }

        @@logger.an_event.debug "links #{links}"

      rescue Exception => e
        if i < count
          @@logger.an_event.warn e.message
          sleep 1
          i += 1
          retry
        else
          @@logger.an_event.fatal e.message
          raise Error.new(BROWSER_NOT_FOUND_ALL_LINK, :values => {:browser => name}, :error => e)
        end

      else
        @@logger.an_event.debug "browser #{name} #{@id} found all links #{links}"
        links

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # body
    #----------------------------------------------------------------------------------------------------------------
    # fournit le source du body de la page courante
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : Nokogiri Object contenant le body
    # exception :
    # si on ne trouve pas le body
    # si parsing html du source echoue
    #----------------------------------------------------------------------------------------------------------------
    def body
      count_retry = 0
      src = ""

      begin
        src = ""

        src = @driver.body
        @@logger.an_event.debug "src : #{src}"

        raise "body #{url} is empty" if src.empty?
          #@@logger.an_event.debug src

      rescue Exception => e
        @@logger.an_event.warn "browser #{@id} #{e.message}"
        count_retry += 1
        sleep 1
        retry if count_retry < 20
        @@logger.an_event.error "browser #{@id} #{e.message}"
        raise Error.new(BROWSER_NOT_FOUND_BODY, :values => {:browser => name}, :error => e)

      else

      end

      begin

        body = Nokogiri::HTML(src)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_FOUND_BODY, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} get body"
        body

      end
    end


    #-----------------------------------------------------------------------------------------------------------------
    # click_on
    #-----------------------------------------------------------------------------------------------------------------
    # input : objet Link, elementStub, String, URI
    # output : RAS
    # exception :
    # StandardError :
    # si link n'est pas defini
    # StandardError :
    # si impossibilité technique de clicker sur le lien
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def click_on(link, accept_popup = false)
      @@logger.an_event.debug "link #{link}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "link"}) if link.nil?


        if link.is_a?(Sahi::ElementStub)
          link_element = link
          raise "browser #{@id} not found Sahi::ElementStub #{link_element.to_s}" unless link_element.exists?

          # on sait que le link exist, mais on ne sait pas avec element il a été identifié
          # alors on re-test l'existance pour trouver le bon find_element
        elsif link.is_a?(Pages::Link)
          found = false
          [link.text, link.url, link.url_escape].each { |l|
            @@logger.an_event.debug "link #{l}"
            unless l == Pages::Link::EMPTY
              link_element = @driver.link(l)

              begin # pour eviter les exception sahi
                if found = link_element.exists?
                  break
                else
                  @@logger.an_event.warn "browser #{@id} not found Pages::Link #{link_element.to_s}"
                end
              rescue Exception => e
              end
            end
          }
          raise "browser #{@id} not found Pages::Link #{link_element.to_s}" unless found

        elsif link.is_a?(URI)
          link_element = @driver.link(link.to_s)
          raise "browser #{@id} not found URI #{link_element.to_s}" unless link_element.exists?

        elsif link.is_a?(String)
          link_element = @driver.link(link)
          raise "browser #{@id} not found String #{link_element.to_s}" unless link_element.exists?

        end
      rescue Exception => e
        @@logger.an_event.error e.message

        raise Error.new(BROWSER_NOT_FOUND_LINK, :values => {:browser => name}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} #{@id} found link #{link}" if link.is_a?(String)
        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.url}" if link.is_a?(Pages::Link)
        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.to_s}" if link.is_a?(URI)
        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.identifiers}" if link.is_a?(Sahi::ElementStub)

        @@logger.an_event.debug "link_element #{link_element.to_s}"

      end


      # limite du nombre d'essaie de click à 5
      # si nombre max atteint, leve une exception  : BROWSER_CLICK_MAX_COUNT
      count = 5
      begin
        # on interdit les ouvertures de fenetre pour rester dans la fenetre courante.
        if !accept_popup and link_element.fetch("target") == "_blank"
          link_element.setAttribute("target", "")
          @@logger.an_event.debug "target of #{link_element} change to ''"
        end


        url_before = url
        @@logger.an_event.debug "url before #{url_before}"

        link_element.click

        # on attend tq que les url_before et url courante sont identiques, au max 5s.
        @driver.wait(10)
        @@logger.an_event.debug "click on #{link_element}"

        # on autorise d'ouvrir un nouvel onglet ou fenetre que pour les pub qui le demande sinon les autres liens
        #restent dans leur fenetre.
        # est ce qu'uen nouvelle fenetre ou onlget a été créé qui est difféerent de celui sur lequel on est qd on est
        # déjà sur une nouvelle fenetre ou onglet
        if @driver.new_popup_is_open?(url)
          if accept_popup
            # si popup est ouverte sur au click d'une pub alors on remplace le driver principal par celui de la nouvelle fenetre
            @driver = @driver.focus_popup
            @@logger.an_event.debug "replace driver by popup driver"
          else
            # si un bout de code javascript ouvre une nouvelle fenetre <=> impossible de l'identifier et de corriger le
            #comportement avant de cliquer sur le lien
            # => clos les fenetres apres le click.
            @driver.close_popups
            @@logger.an_event.debug "close popup"
          end

        else
          raise "same url after click : #{url_before}" if url_before == url

        end

      rescue Exception => e
        @@logger.an_event.warn e.message
        count -= 1
        retry if count > 0
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_CLICK, :values => {:browser => name}, :error => e) if count > 0
        raise Error.new(BROWSER_CLICK_MAX_COUNT, :values => {:browser => name, :link => url_before}, :error => e) unless count > 0

      else
        @@logger.an_event.debug "browser #{name} #{@id} click on url #{link}" if link.is_a?(String)
        @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.url}" if link.is_a?(Pages::Link)
        @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.to_s}" if link.is_a?(URI)
        @@logger.an_event.debug "browser #{name} #{@id} click on url #{link.identifiers}" if link.is_a?(Sahi::ElementStub)
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
    def display_start_page (url_start_page, window_parameters)

      @@logger.an_event.debug "url_start_page : #{url_start_page}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "url_start_page"}) if url_start_page.nil? or url_start_page == ""

        old_page_title = @driver.title

        @driver.display_start_page(url_start_page, window_parameters)

        begin
          hostname = URI.parse(url_start_page).hostname
        rescue Exception => e
          hostname = URI.parse(URI.escape(url)).hostname
        end
        #pb de connection reseau par exemple
        raise Error.new(BROWSER_NOT_CONNECT_TO_SERVER, :values => {:browser => name, :domain => hostname}) if @driver.div("error_connect").exists?

        new_page_title = @driver.title
        #erreur sahi...on est tj sur la page initiale de sahi
        raise Error.new(BROWSER_NOT_ACCESS_URL, :values => {:browser => name, :url => url_start_page}) if new_page_title == old_page_title

        @@logger.an_event.debug "browser #{name} #{@id} open start page #{url}"

      rescue Exception => e
        @@logger.an_event.fatal e.message

        raise Error.new(BROWSER_NOT_DISPLAY_START_PAGE, :values => {:browser => name, :page => url_start_page}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} display start page"
          #  start_page

      ensure

      end
    end

     #----------------------------------------------------------------------------------------------------------------
    # exist_element?
    #----------------------------------------------------------------------------------------------------------------
    # test l'existance d'un element sur la page courante
    #----------------------------------------------------------------------------------------------------------------
    # input : type de l'objet html(textbox, button, ...), id de lobjet html
    # output : true si trouvé, sinon false
    #
    #----------------------------------------------------------------------------------------------------------------
    def exist_element?(type, id)
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "type"}) if type.nil? or type.empty?
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "id"}) if id.nil? or id.empty?

      @@logger.an_event.debug "type #{type}"
      @@logger.an_event.debug "id #{id}"

      r = "@driver.#{type}(\"#{id}\")"
      @@logger.an_event.debug "r : #{r}"
      @@logger.an_event.debug "eval(r) : #{eval(r)}"

      exist = eval(r).exists?
      @@logger.an_event.debug "eval(r).exists? : #{exist}"

      exist

    end
    #----------------------------------------------------------------------------------------------------------------
    # exist_link
    #----------------------------------------------------------------------------------------------------------------
    # test l'existance du link
    #----------------------------------------------------------------------------------------------------------------
    # input : Object Link, Objet URI, String url   , elementStub,
    # output : RAS si trouvé, sinon une exception Browser not found link
    #
    #----------------------------------------------------------------------------------------------------------------
    def exist_link?(link)
      @@logger.an_event.debug "link #{link}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "link"}) if link.nil?

        exist = false
        if link.is_a?(Browsers::Sahi::ElementStub)
          link_element = link
          raise "link #{link.to_s} not exist" unless link_element.exists?

        else
          if link.is_a?(Pages::Link)
            exist = false
            [link.text, link.url, link.url_escape].each { |l|
              link_element = @driver.link(l)
              begin # pour eviter les exception sahi
                if link_element.exists?
                  exist = true
                  break
                end
              rescue Exception => e
              end
              raise "link #{link.to_s} not exist" unless exist
            }
          elsif link.is_a?(URI)
            link_element = @driver.link(link.url)
            raise "link #{link.to_s} not exist" unless link_element.exists?

          elsif link.is_a?(String)
            link_element = @driver.link(link)
            raise "link #{link.to_s} not exist" unless link_element.exists?

          end

        end

      rescue Exception => e
        @@logger.an_event.error e.message

        raise Error.new(BROWSER_NOT_FOUND_LINK, :values => {:domain => "", :identifier => link.to_s}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} #{@id} found link #{link.to_s}"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # go_back
    #----------------------------------------------------------------------------------------------------------------
    # cick sur le bouton back du navigateur
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def go_back
      begin
        @driver.back

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_GO_BACK, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} go back"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # go_to
    #----------------------------------------------------------------------------------------------------------------
    # force le navigateur à aller à la page referencée par l'url
    #----------------------------------------------------------------------------------------------------------------
    # input : url
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def go_to (url)
      begin
        @driver.navigate_to(url)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_GO_TO, :values => {:browser => name, :url => url}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} go to #{url}"

      ensure

      end
    end

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

        @driver = Sahi::Browser.new(browser_type,
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
        @driver.resize(@width.to_i, @height.to_i)

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

        @driver.quit

      rescue Exception => e
        @@logger.an_event.warn "browser #{name} close : #{e.message}"

        begin
          @driver.kill

        rescue Exception => e
          @@logger.an_event.error "browser #{name} kill : #{e.message}"
          raise Error.new(BROWSER_NOT_CLOSE, :values => {:browser => name}, :error => e)

        else
          @@logger.an_event.debug "browser #{name} kill"

        end

      else
        @@logger.an_event.debug "browser #{name} close"

      ensure

      end

    end

        #----------------------------------------------------------------------------------------------------------------
    # reload
    #----------------------------------------------------------------------------------------------------------------
    # recharge la page courant
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def reload
      begin
        @driver.reload

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_RELOAD, :values => {:url => url}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} reload #{url}"

      ensure

      end
    end
    #----------------------------------------------------------------------------------------------------------------
    # searchbox
    #----------------------------------------------------------------------------------------------------------------
    # affecte une valeur à une searchbox
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # nom de la variable
    # valeur de la variable
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def searchbox(var, val)
      input = @driver.searchbox(var)
      input.value = val
    end

    #----------------------------------------------------------------------------------------------------------------
    # set_input_search
    #----------------------------------------------------------------------------------------------------------------
    # affecte les mot clés dans la zone de recherche du moteur de recherche
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # type :
    # input :
    # keywords :
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def set_input_search(type, input, keywords)
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "type"}) if type.nil? or type == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "input"}) if input.nil? or input == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keywords"}) if keywords.nil? or keywords == ""

        @@logger.an_event.debug "type : #{type}"
        @@logger.an_event.debug "input : #{input}"
        @@logger.an_event.debug "keywords : #{keywords}"

        #teste la présence de la zone de saisie pour eviter d'avoir une erreur technique
        raise "search textbox not found" unless exist_element?(type, input)

        #remplissage de la zone caractère par caractère pour simuler qqun qui tape au clavier
        kw = ""
        keywords.split(//).each { |c|
          kw += c
          r = "#{type}(\"#{input}\", \"#{kw}\")"
          @@logger.an_event.debug "eval(r) : #{r}"
          eval(r)
        }


      rescue Exception => e
        @@logger.an_event.fatal "set input search #{type} #{input} with #{keywords} : #{e.message}"
        raise Error.new(BROWSER_NOT_SET_INPUT_SEARCH, :values => {:browser => name, :type => type, :input => input, :keywords => keywords}, :error => e)

      else
        @@logger.an_event.debug "set input search #{type} #{input} with #{keywords}"

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # set_input_captcha
    #----------------------------------------------------------------------------------------------------------------
    # affecte le mot du captcha dans la zone de saisie du captcha
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # type :
    # input :
    # keywords :
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def set_input_captcha(type, input, captcha)
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "type"}) if type.nil? or type == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "input"}) if input.nil? or input == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "captcha"}) if captcha.nil? or captcha == ""

        @@logger.an_event.debug "type : #{type}"
        @@logger.an_event.debug "input : #{input}"
        @@logger.an_event.debug "captcha : #{captcha}"

        r = "#{type}(\"#{input}\", \"#{captcha}\")"
        @@logger.an_event.debug "eval(r) : #{r}"
        eval(r)

      rescue Exception => e
        @@logger.an_event.fatal "set input captcha #{type} #{input} with #{captcha} : #{e.message}"
        raise Error.new(BROWSER_NOT_SET_INPUT_CAPTCHA, :values => {:browser => name, :type => type, :input => input, :keywords => captcha}, :error => e)

      else
        @@logger.an_event.debug "set input search #{type} #{input} with #{captcha}"

      end
    end

    #-----------------------------------------------------------------------------------------------------------------
    # submit
    #-----------------------------------------------------------------------------------------------------------------
    # input : un formulaire
    # output : RAS
    # exception :
    # StandardError :
    # si la soumission echoue
    # si le formulaire n'est pas fourni
    #-----------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------
    def submit(form)

      @@logger.an_event.debug "form #{form}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "form"}) if form.nil?

        @driver.submit(form).click

      rescue Exception => e
        @@logger.an_event.error "browser #{name} #{@id} submit form #{form} : #{ e.message}"
        raise Error.new(BROWSER_NOT_SUBMIT_FORM, :values => {:browser => name, :form => form}, :error => e)

      else
        @@logger.an_event.debug "browser #{name} #{@id} submit form #{form}"

      ensure

      end

    end

    #-----------------------------------------------------------------------------------------------------------------
    # take_screenshot
    #-----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : image du contenu du browser stocker dans un fichier :
    #  localisé dans le repertoire screenshot (par default), sinon défini par le flow
    #  nom du fichier : browser_name, beowser_version, title_crt_page[0..32], date du jour.png, nombre de minute depuis 00:00
    #  sinon défini par le flow
    # exception : none
    #-----------------------------------------------------------------------------------------------------------------
    # on ne genere pas d'execption pour ne pas perturber la remonter des exception de visitor_bot, car ce n'est pas
    # grave si on ne pas faire de screenshot
    # => on ne fait que logger
    #-----------------------------------------------------------------------------------------------------------------


    def take_screenshot(output_file=nil)

      begin
        if output_file.nil?

          title = @driver.title
          @@logger.an_event.debug title
          output_file = Flow.new(DIR_TMP,
                                 @driver.name.gsub(" ", "-"),
                                 title[0..32],
                                 Date.today,
                                 Time.parse(Tim.now).hour * 3600 + Time.parse(Time.now).min * 60,
                                 ".png")

        end

        @driver.take_screenshot(output_file.absolute_path)

      rescue Exception => e
        @@logger.an_event.error e.message
        @@logger.an_event.error Messages.instance[BROWSER_NOT_TAKE_SCREENSHOT, {:browser => name, :title => title}]

      else

        @@logger.an_event.info "browser #{name} take screen shot"

      ensure

      end

    end

    #-----------------------------------------------------------------------------------------------------------------
    # take_captcha
    #-----------------------------------------------------------------------------------------------------------------
    # input : output file captcha, coordonate of captcha on screen
    # output : image du captcha
    # exception : technique
    #-----------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------


    def take_captcha(output_file, coord_captcha)

      begin

        @driver.take_area_screenshot(output_file.absolute_path, coord_captcha)

      rescue Exception => e
        @@logger.an_event.fatal "take captcha : #{e.message}"
        raise Error.new(BROWSER_NOT_TAKE_SCREENSHOT, :values => {:browser => name, :title => title}, :error => e)

      else

        @@logger.an_event.info "browser #{name} take captcha"

      ensure

      end

    end

    #----------------------------------------------------------------------------------------------------------------
    # textbox
    #----------------------------------------------------------------------------------------------------------------
    # affecte une valeur à un textbox
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # nom de la variable
    # valeur de la variable
    # output : RAS
    #----------------------------------------------------------------------------------------------------------------
    def textbox(var, val)
      input = @driver.textbox(var)
      input.value = val
    end

    #-----------------------------------------------------------------------------------------------------------------
    # title
    #-----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : titre de la page courante
    # exception :
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def title

      begin
        title = nil
        title = @driver.title

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_FOUND_TITLE, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} found title #{title}"
        title

      ensure

      end
    end

    #-----------------------------------------------------------------------------------------------------------------
    # url
    #-----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # output : url de la page
    # exception :
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def url
      count = 0
      begin
        url = nil
        url = @driver.current_url
        raise "url empty" if url.empty? or url.nil?

      rescue Exception => e
        @@logger.an_event.warn e.message
        count += 1
        sleep 1
        retry if count < 5
        @@logger.an_event.error e.message
        raise Error.new(BROWSER_NOT_FOUND_URL, :values => {:browser => name}, :error => e)

      else

        @@logger.an_event.debug "browser #{name} #{@id} found url #{url} of current page"
        url
      end
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