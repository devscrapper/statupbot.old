module Browsers
  module SahiCoIn
    class Firefox < Browser
      class FirefoxException < StandardError

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
        @driver = Browsers::SahiCoIn::Driver.new("firefox", @listening_port_proxy)
        @start_page = "http://www.mozilla.org/fr/"
        customize_properties (visitor_dir)
      end

      def customize_properties(visitor_dir)
        # id_visitor\proxy\config\ff_profile_template\prefs.js :
        # le port d'ecoute du proxy pour firefox
        file_name = File.join(visitor_dir, 'proxy', 'config', 'ff_profile_template', 'prefs.js')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win64.xml :
        # heigth et width du browser pour firefox
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win64.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win32.xml :
        # heigth et width du browser pour firefox
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win32.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\mac.xml :
        # heigth et width du browser pour firefox
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'mac.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\linux.xml :
        # heigth et width du browser pour firefox
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'linux.xml')
        file_custom = File.read(file_name)
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
        #scrollbars=yes|no|1|0 	Whether or not to display scroll bars. IE, Firefox & Opera only
        #status=yes|no|1|0 	Whether or not to add a status bar
        #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
        #toolbar=yes|no|1|0 	Whether or not to display the browser toolbar. IE and Firefox only
        #top=pixels 	The top position of the window. Negative values not allowed
        #width=pixels 	The width of the window. Min. value is 100
        #@driver.open_start_page("width=#{@width},height=#{@height},fullscreen=no,left=0,menubar=yes,scrollbars=yes,status=yes,titlebar=yes,toolbar=yes,top=0")
        #TODO etudeir pour les windows parameter ne sont pas pris en compte lros de l' window.open => tous browser cela merde.
        window_parameters = "width=#{@width},height=#{@height},fullscreen=no,left=0,menubar=yes,scrollbars=yes,status=yes,titlebar=yes,toolbar=yes,top=0"
         # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
        # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
        @driver.fetch("_sahi.open_start_page_ff(\"https://localhost\",\"#{window_parameters}\")")
        #@driver.fetch("_sahi._closeWindow()") marche pas pour fermer la première fenetre

        @driver.popup_name = "defaultSahiPopup"
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
      end
    end
  end
end