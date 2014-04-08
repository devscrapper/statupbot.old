require_relative '../../page/page'
module Browsers
  module SahiCoIn
    class Opera < Browser
      class OperaException < StandardError

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
        customize_properties(visitor_dir)
      end

      def customize_properties (visitor_dir)
        #TODO disable autoupdate
        #TODO supprimer le warning des certificats autosigné
        # id_visitor\proxy\config\opera_profile_template\operaprefs.ini :
        # les dimensions de la fenetre de opera
        file_name = File.join(visitor_dir, 'proxy', 'config', 'opera_profile_template', 'operaprefs.ini')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        file_custom.gsub!(/height_browser/, @height)
        file_custom.gsub!(/width_browser/, @width)
        File.write(file_name, file_custom)
      end

      def deploy_properties(visitor_dir)
        FileUtils.mkdir_p(File.join(visitor_dir, 'proxy', 'userdata', 'browser', 'opera', 'profiles'))
        FileUtils.cp(File.join(visitor_dir, 'proxy', 'config', 'opera_profile_template', 'operaprefs.ini'), File.join(visitor_dir, 'proxy', 'userdata', 'browser', 'opera', 'profiles', 'operaprefs.ini'))
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
        #location=yes|no|1|0 	Whether or not to display the address field. Opera only
        #menubar=yes|no|1|0 	Whether or not to display the menu bar
        #scrollbars=yes|no|1|0 	Whether or not to display scroll bars. IE, Firefox & Opera only
        #status=yes|no|1|0 	Whether or not to add a status bar
        #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
        #top=pixels 	The top position of the window. Negative values not allowed
        #width=pixels 	The width of the window. Min. value is 100
        #TODO controler le format de l'interface au lancement de opera
        #TODO controler le noreferer pour opera
        #TODO variabiliser le num de port
        window_parameters = "width=#{@width},height=#{@height},fullscreen=0,left=0,location=1,menubar=1,scrollbars=1,status=1,titlebar=1,top=0"
        @driver.fetch("_sahi.open_start_page_op(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}\",\"#{window_parameters}\")")
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
        page_details = current_page_details
        start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"],)
        start_page
      end

      def process_exe
        #TODO valider getpid pour opera
      "opera.exe"
      end

    end
  end
end
