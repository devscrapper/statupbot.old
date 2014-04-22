require_relative '../../page/page'
module Browsers
  module SahiCoIn
    class Chrome < Browser
      class ChromeException < StandardError

      end
      include Pages
      #----------------------------------------------------------------------------------------------------------------
      # class methods
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------
      #["browser", "Firefox"]
      #["browser_version", "16.0"]
      #["operating_system", "Windows"]
      #["operating_system_version", "7"]
      def initialize(visitor_dir, browser_details)
        super(browser_details)
        @driver = Browsers::SahiCoIn::Driver.new("#{browser_details[:name]}_#{browser_details[:version]}",
                                                 @listening_port_proxy)
        #@method_start_page = NO_REFERER
        @method_start_page = DATA_URI
        customize_properties(visitor_dir)
      end

      def customize_properties(visitor_dir)
        # id_visitor\proxy\config\browser_types\win64.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win64.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win32.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win32.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\mac.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'mac.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\linux.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'linux.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)
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
        @@logger.an_event.debug "link #{link}"
        page = nil
        begin
          link.click
           #TODO pourquoi faut il mettre une temprosisation pour slectioner la page du referral pour recuperer ses proprieyé avec avoir cliquer sur son lien dans la start page ; ce pb n'existe pas avec la methode de lancement DATA_URI
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
      # output : RAS
      # exception : RAS
      #----------------------------------------------------------------------------------------------------------------
      def display_start_page(start_url, visitor_id)
        #@driver.navigate_to "http://jenn.kyrnin.com/about/showreferer.html"
        #fullscreen=yes|no|1|0 	Whether or not to display the browser in full-screen mode. Default is no. A window in full-screen mode must also be in theater mode. IE only
        #height=pixels 	The height of the window. Min. value is 100
        #left=pixels 	The left position of the window. Negative values not allowed
        #menubar=yes|no|1|0 	Whether or not to display the menu bar
        #status=yes|no|1|0 	Whether or not to add a status bar
        #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
        #top=pixels 	The top position of the window. Negative values not allowed
        #width=pixels 	The width of the window. Min. value is 100
        #@driver.open_start_page("width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0")
        # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
        # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
        @@logger.an_event.debug "begin display_start_page"
        raise FunctionalError, "start_url is not define" if start_url.nil? or start_url ==""

        @@logger.an_event.debug "start_url : #{start_url}"
        window_parameters = "width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0"
        @@logger.an_event.debug "windows parameters : #{window_parameters}"

        #TODO variabiliser le port 8080 dans le paramter file yml de visitor_bot
        #TODO prendre en compte les window parameter pour chrome
        #start_page = super("_sahi.open_start_page_ch(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}\",\"#{window_parameters}\")")
        #page = click_on(start_page.link_by_url(start_url))
        #
        #page
        super("_sahi.open_start_page_ch(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}&visitor_id=#{visitor_id}\",\"#{window_parameters}\")")
      end

    end
  end
end