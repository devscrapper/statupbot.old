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
      # output : Objet Page
      # exception :
      # TechnicalError :
      # si il est impossble d'ouvrir la page start
      # FunctionalError :
      # Si il est impossible de recuperer les propriétés de la page
      #----------------------------------------------------------------------------------------------------------------
      def display_start_page (start_url, visitor_id)
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
        @@logger.an_event.debug "begin display_start_page"
        raise FunctionalError, "start_url is not define" if start_url.nil? or start_url ==""

        @@logger.an_event.debug "start_url : #{start_url}"
        window_parameters = "width=#{@width},height=#{@height},channelmode=0,fullscreen=0,left=0,menubar=1,resizable=1,scrollbars=1,status=1,titlebar=1,toolbar=1,top=0"
        @@logger.an_event.debug "windows parameters : #{window_parameters}"

        super("_sahi.open_start_page_ie(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}&visitor_id=#{visitor_id}\",\"#{window_parameters}\")")
      end

        #-----------------------------------------------------------------------------------------------------------------
      # get_pid
      #-----------------------------------------------------------------------------------------------------------------
      # input : id_browser
      # output : tableau contenant les pids du browser
      # exception :
      # FunctionalError :
      # si id_browser n'est pas défini
      # si aucun pid n'a pu être associé à l'id_browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------

=begin
      def get_pid(id_browser)
        @@logger.an_event.debug "begin get_pid"
        raise FunctionalException, "id browser is not defined" if id_browser.nil?
        pid_arr = nil
        pids_name_file = File.join(TMP_DIR, "#{id_browser}_pids.csv")
        begin
          File.delete(pids_name_file) if File.exist?(pids_name_file)
          cmd = 'powershell -NoLogo -NoProfile "get-process |  where-object {$_.mainWindowTitle -like \"' + "#{id_browser}*" + '\"} | Export-Csv -notype ' + pids_name_file + '; exit $LASTEXITCODE" < NUL'
          @@logger.an_event.debug "command powershell : #{cmd}"
          @pid = Process.spawn(cmd)
          Process.waitpid(@pid)
          if File.exist?(pids_name_file)
            pid_arr = CSV.table(pids_name_file).by_col[:id]
            @@logger.an_event.debug "pids catch : #{pid_arr}"
            File.delete(pids_name_file)
          else
            raise TechnicalError, "file #{pids_name_file} not found"
          end
        rescue Exception => e
          @@logger.an_event.debug e.message
          raise "cannot get pid of #{id_browser}"
        ensure
          @@logger.an_event.debug "end get_pid"
        end
        pid_arr
      end

        #-----------------------------------------------------------------------------------------------------------------
      # kill
      #-----------------------------------------------------------------------------------------------------------------
      # input : tableau de pids
      # output : none
      # exception :
      # FunctionalError :
      # si aucune pid n'est passé à la fonction
      # TechnicalError :
      # si il n'a pas été possible de tuer le browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------

      def kill(pid_arr)
        @@logger.an_event.debug "begin kill"

        raise FunctionalError, "no pid" if pid_arr == []

        pid_arr.each { |pid|
          begin
            cmd = 'powershell -NoLogo -NoProfile "Stop-Process ' + pid.to_s + '; exit $LASTEXITCODE" < NUL'
            @@logger.an_event.debug "command powershell : #{cmd}"
            ps_pid = Process.spawn(cmd)
            Process.waitpid(ps_pid)
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise TechnicalError, "cannot kill pid #{pid}"
          ensure
            @@logger.an_event.debug "end kill"
          end
        }
      end
=end


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
