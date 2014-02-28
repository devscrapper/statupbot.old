module Browsers
  module SahiCoIn
    class Chrome < Browser
      class ChromeException < StandardError

      end
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
        @driver = Browsers::SahiCoIn::Driver.new("chrome", @listening_port_proxy)
        #TODO supprimer @start_page
        @start_page = "http://www.google.fr/?nord=1"
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
      def display_start_page
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
        window_parameters = "width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0"
        @driver.fetch("_sahi.open_start_page_ch(\"https://localhost\",\"#{window_parameters}\")")
        @driver.popup_name = "defaultSahiPopup"
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
      end
    end
  end
end