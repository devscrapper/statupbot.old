module Browsers
  module SahiCoIn
    class Safari < Browser
      class SafariException < StandardError

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
        @driver = Browsers::SahiCoIn::Driver.new("safari", @listening_port_proxy)
        @start_page = "http://www.apple.com/fr/itunes/"
        customize_properties(visitor_dir)
      end

      def customize_properties(visitor_dir)
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
        #TODO controler le lancement  : voir le comportement comme IE ou FF ou CH
        @driver.open_start_page("width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0")
      end
    end
  end
end
