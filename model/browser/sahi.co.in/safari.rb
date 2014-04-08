require_relative '../../page/page'
module Browsers
  module SahiCoIn
    class Safari < Browser
      class SafariException < StandardError

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

        if browser_details[:sandbox] == true and browser_details[:multi_instance_proxy_compatible] == true
          @driver = Browsers::SahiCoIn::Driver.new("#{browser_details[:name]}_#{browser_details[:version]}_#{@listening_port_proxy}",
                                                   @listening_port_proxy)
        else
          @driver = Browsers::SahiCoIn::Driver.new("#{browser_details[:name]}_#{browser_details[:version]}",
                                                   @listening_port_proxy)
        end
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
      def display_start_page(start_url)
        #@driver.navigate_to "http://jenn.kyrnin.com/about/showreferer.html"
        #fullscreen=yes|no|1|0 	Whether or not to display the browser in full-screen mode. Default is no. A window in full-screen mode must also be in theater mode. IE only
        #height=pixels 	The height of the window. Min. value is 100
        #left=pixels 	The left position of the window. Negative values not allowed
        #menubar=yes|no|1|0 	Whether or not to display the menu bar
        #status=yes|no|1|0 	Whether or not to add a status bar
        #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
        #top=pixels 	The top position of the window. Negative values not allowed
        #width=pixels 	The width of the window. Min. value is 100
        #TODO valider le format de l'interface safari au lancment
        #TODO valider l'absence de referer avec safari
        #TODO variabiliser le num de port
        window_parameters = "width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0"
        @driver.fetch("_sahi.open_start_page_sa(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}\",\"#{window_parameters}\")")
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
        page_details = current_page_details

        start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"],)
        page = click_on(start_page.link_by_url(start_url))
        page
      end

      def process_exe
        #TODO valider get pid pour safari
        "safari.exe"
      end

    end
  end
end
