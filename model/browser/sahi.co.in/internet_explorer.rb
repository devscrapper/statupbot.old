require_relative '../../page/page'
require_relative 'driver'
module Browsers
  module SahiCoIn
    class InternetExplorer < Browser

      class InternetExplorerException < StandardError

      end
      include Pages

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
        @@logger.an_event.debug "begin initialize internet explorer"
        super(browser_details)
        @method_start_page = DATA_URI

        begin

          if @proxy_system
            browser_type = "#{browser_details[:name]}_#{browser_details[:version]}"
          else
            browser_type ="#{browser_details[:name]}_#{browser_details[:version]}_#{@listening_port_proxy}"
          end
          @driver = Driver.new(browser_type,
                               @listening_port_proxy)
        rescue FunctionalError => e
          @@logger.an_event.error e.message
          raise FunctionalError, "configuration of Internet Explorer #{@id} is mistaken"
        ensure
          @@logger.an_event.debug "end initialize internet explorer"
        end


        begin
          customize_properties(visitor_dir)
        rescue Exception => e
          @@logger.an_event.error e.message
          raise FunctionalError, "customisation of configuration of Internet Explorer #{@id} failed"
        ensure
          @@logger.an_event.debug "end initialize internet explorer"
        end
      end

      def customize_properties(visitor_dir)
        begin
          # id_visitor\proxy\tools\proxy.properties :
          # le port d'ecoute du proxy pour internet explorer
          file_name = File.join(visitor_dir, 'proxy', 'tools', 'proxy.properties')
          file_custom = File.read(file_name)
          file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
          File.write(file_name, file_custom)


          # id_visitor\proxy\config\browser_types\win64.xml :
          # le port d'ecoute du proxy pour internet explorer
          file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win64.xml')
          file_custom = File.read(file_name)
          file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
          file_custom.gsub!(/tool_sandboxing_browser_runtime_path/, Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co', 'tools', 'sandboxing_browser.rb')).realpath.to_s)
          File.write(file_name, file_custom)

          # id_visitor\proxy\config\browser_types\win32.xml :
          # le port d'ecoute du proxy pour internet explorer
          file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win32.xml')
          file_custom = File.read(file_name)
          file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
          file_custom.gsub!(/tool_sandboxing_browser_runtime_path/, Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co', 'tools', 'sandboxing_browser.rb')).realpath.to_s)
          File.write(file_name, file_custom)
        rescue Exception => e
          @@logger.an_event.error e.message
          raise TechnicalError, e.message
        end

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
      def display_start_page (start_url)
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
        #TODO variabiliser le num de port
        window_parameters = "width=#{@width},height=#{@height},channelmode=0,fullscreen=0,left=0,menubar=1,resizable=1,scrollbars=1,status=1,titlebar=1,toolbar=1,top=0"
        @@logger.an_event.info "display start page with parameters : #{window_parameters}"
        @driver.fetch("_sahi.open_start_page_ie(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}\",\"#{window_parameters}\")")
        page_details = current_page_details
        start_page = Page.new(page_details["url"], page_details["referrer"], page_details["title"], nil, page_details["links"], page_details["cookies"],)
        start_page
      end

      def process_exe
        "iexplore.exe"
      end

      def quit

        if @proxy_system
          @@logger.an_event.debug "begin quit internet explorer with proxy system"
          # qd il y a plusieurs instance de iexplorer.exe, le kill de sahi ne fonctionne pas.
          # on est alors obliger de killer manuellement le internet explorer.
          # il faut donc recuperer le pid d'internet explorer, 2 cas :
          # - Si internet explorer utilise le proxy system de windows alors il faut récuperer le pid avant de demander à
          # sahi de killer le process, car sahi supprime de la base de registre les info du proxy system. Alors il n'est plus
          # possible d'utiliser la methode d'identification du process iexplorer en utilisant le titre de la fenetre
          # d'internet explorer.
          # - Si internet explorer n'utilise pas le  proxy system qd il est sandboxé (parametrage du proxy IE local au sandbox)
          # alors on peut demander à sahi de killer Internet Explorer et si cela ne marche pas utiliser la methode d'identification
          # au moyen du titre de la fenetre => on se retrouve dans la procédure classique d'arret d'un browser
          # on utilise alors la super methode définit dans Browser.
          #----------------------------------------------------------------------------------------------------
          #
          # affecte l'id du browser dans le title de la fenetre
          #
          #-----------------------------------------------------------------------------------------------------
          begin
            title_updt = @driver.set_title(@id)
            @@logger.an_event.debug "browser #{name} has set title #{title_updt}"
          rescue TechnicalError => e
            @@logger.an_event.error e.message
            raise TechnicalError, "browser #{name} cannot close"
            @@logger.an_event.debug "end quit internet explorer with proxy system"
          ensure

          end
          #----------------------------------------------------------------------------------------------------
          #
          # recupere le PID du browser en fonction de l'id du browser dans le titre de la fenetre du browser
          #
          #-----------------------------------------------------------------------------------------------------
          begin
            @pids = @driver.get_pids(@id)
            @@logger.an_event.debug "browser #{name} pid #{@pids} is retrieve"
          rescue TechnicalError => e
            @@logger.an_event.error e.message
            raise TechnicalError, "browser #{name} cannot get pid"
            @@logger.an_event.debug "end quit internet explorer with proxy system"
          ensure

          end

          begin
            @driver.close
            @@logger.an_event.debug "browser #{name} is closed"
          rescue TechnicalError => e
            @@logger.an_event.debug e.message
            #----------------------------------------------------------------------------------------------------
            #
            # kill le browser en fonction de ses Pids
            #
            #-----------------------------------------------------------------------------------------------------
            begin
              @driver.kill(@pids)
              @@logger.an_event.debug "browser #{name} is killed"
            rescue TechnicalError => e
              @@logger.an_event.error e.message
              raise TechnicalError, "browser #{name} #{@id} is not killed"
            ensure
              @@logger.an_event.debug "end quit internet explorer with proxy system"
            end
          ensure
            @@logger.an_event.debug "end quit internet explorer with proxy system"
          end

        else
          # internet explorer n'utilise pas le proxy system car il est sandboxé
          super
        end
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
