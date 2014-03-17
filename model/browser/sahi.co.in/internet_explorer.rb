module Browsers
  module SahiCoIn
    class InternetExplorer < Browser
      class InternetExplorerException < StandardError

      end

      #TODO la size du browser nest pas gerer car window.open dans le self
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
        @driver = Browsers::SahiCoIn::Driver.new("ie", @listening_port_proxy)
        @start_page = "http://www.bing.fr"
        customize_properties(visitor_dir)
      end

      def customize_properties(visitor_dir)
        # id_visitor\proxy\tools\proxy.properties :
        # le port d'ecoute du proxy pour internet explorer
        file_name = File.join(visitor_dir, 'proxy', 'tools', 'proxy.properties')
        file_custom = File.read(file_name)
        #TODO remplacer par un gsub!
        3.times { file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s) }
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
        #channelmode=yes|no|1|0 	Whether or not to display the window in theater mode. Default is no. IE only
        #fullscreen=yes|no|1|0 	Whether or not to display the browser in full-screen mode. Default is no. A window in full-screen mode must also be in theater mode. IE only
        #height=pixels 	The height of the window. Min. value is 100
        #left=pixels 	The left position of the window. Negative values not allowed
        #menubar=yes|no|1|0 	Whether or not to display the menu bar
        #resizable=yes|no|1|0 	Whether or not the window is resizable. IE only
        #scrollbars=yes|no|1|0 	Whether or not to display scroll bars. IE, Firefox & Opera only
        #status=yes|no|1|0 	Whether or not to add a status bar
        #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
        #toolbar=yes|no|1|0 	Whether or not to display the browser toolbar. IE and Firefox only
        #top=pixels 	The top position of the window. Negative values not allowed
        #width=pixels 	The width of the window. Min. value is 100
        #@driver.open_start_page("width=#{@width},height=#{@height},channelmode=0,fullscreen=0,left=0,menubar=1,resizable=1,scrollbars=1,status=1,titlebar=1,toolbar=1,top=0")

        # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
        # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
        window_parameters = "width=#{@width},height=#{@height},channelmode=0,fullscreen=0,left=0,menubar=1,resizable=1,scrollbars=1,status=1,titlebar=1,toolbar=1,top=0"
        @driver.fetch("_sahi.open_start_page_ie(\"https://sahi.example.com/_s_/dyn/Driver_initialized\",\"#{window_parameters}\")")
        #TODO comment google fait pour recuperer le referrer sur un https ?
        @driver.navigate_to "https://www.sfr.fr"
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
      end
      def get_pid
        super
        if @pids == [nil]
          f = IO.popen("tasklist /FO CSV /NH /V /FI \"IMAGENAME eq  iexplore.exe\" /FI \"CPUTIME lt 0:00:01\"")
          @@logger.an_event.info "tasklist /FO CSV /NH /V /FI \"IMAGENAME eq  iexplore.exe\" /FI \"CPUTIME lt 0:00:01\""
          @pids=nil
          f.readlines("\n").each { |l|
            @@logger.an_event.info "l : #{l}"
            CSV.parse(l) do |row|
              @@logger.an_event.info "row : #{row}"
              @@logger.an_event.info "row[1] : #{row[1]}"
              @pids = @pids.nil? ? [row[1]] : @pids + [row[1]]
              @@logger.an_event.info "pids : #{@pids}"
            end
          }
        end
        @@logger.an_event.error "browser #{@id} pid not found #{@pids}" if @pids == [nil]
        @@logger.an_event.info "browser #{@id} pid #{@pids} is opened" unless @pids == [nil]
      end
      #----------------------------------------------------------------------------------------------------------------
      # links
      #----------------------------------------------------------------------------------------------------------------
      # dans la page courante, liste tous les href issue des tag : <a>, <map>.
      #----------------------------------------------------------------------------------------------------------------
      # input : RAS
      # output : Array de Link
      #----------------------------------------------------------------------------------------------------------------
      def links
        sleep(3.5)
        super
      end


    end

  end
end
