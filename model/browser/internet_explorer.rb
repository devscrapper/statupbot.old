# encoding: utf-8
require_relative '../../lib/error'
module Browsers
  class InternetExplorer < Browser
    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
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
      @@logger.an_event.debug "name #{browser_details[:name]}"
      @@logger.an_event.debug "version #{browser_details[:version]}"
      @@logger.an_event.debug "proxy system #{browser_details[:proxy_system]}"
      @@logger.an_event.debug "visitor_dir #{visitor_dir}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser name"}) if browser_details[:name].nil? or browser_details[:name] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser version"}) if browser_details[:version].nil? or browser_details[:version] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_dir"}) if visitor_dir.nil? or visitor_dir == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "proxy_system"}) if browser_details[:proxy_system].nil? or browser_details[:proxy_system] == ""


        super(browser_details,
              "#{browser_details[:name]}_#{browser_details[:version]}" + (browser_details[:proxy_system] ? "" : "_#{@listening_port_proxy}"),
              DATA_URI,
              visitor_dir)
      rescue Exception => e
        raise e

      else
        @@logger.an_event.debug "internet explorer #{@version} initialize"

      ensure

      end
    end

    def customize_properties(visitor_dir)
      @@logger.an_event.debug "visitor_dir #{visitor_dir}"

      begin

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_dir"}) if visitor_dir.nil? or visitor_dir == ""

        # id_visitor\proxy\config\sahi.properties
        # Time (in milliseconds) delay between steps
        # script.time_between_steps=wait_time
        file_name = File.join(visitor_dir, 'proxy', 'config', 'sahi.properties')
        file_custom = File.read(file_name)
        file_custom.gsub!(/wait_time/, 1000.to_s)
        File.write(file_name, file_custom)

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
        #file_custom.gsub!(/tool_sandboxing_browser_runtime_path/, Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'tools', 'sandboxing_browser.rb')).realpath.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win32.xml :
        # le port d'ecoute du proxy pour internet explorer
        file_name = File.join(visitor_dir, 'proxy', 'config', 'browser_types', 'win32.xml')
        file_custom = File.read(file_name)
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        #file_custom.gsub!(/tool_sandboxing_browser_runtime_path/, Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'tools', 'sandboxing_browser.rb')).realpath.to_s)
        File.write(file_name, file_custom)
      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(BROWSER_NOT_CUSTOM_FILE, :values => {:browser => name}, :error => e)

      else
        @@logger.an_event.debug "internet explorer #{@version} customize config file proxy sahi"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # display_start_page
    #----------------------------------------------------------------------------------------------------------------
    # ouvre un nouvelle fenetre du navigateur adaptée aux propriété du naviagateur et celle de la visit
    # affiche la root page du site https pour initialisé le référer à non défini
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

    #----------------------------------------------------------------------------------------------------------------
    # input : url (String)
    # output : Objet Page
    # exception :
    # StandardError :
    # si il est impossble d'ouvrir la page start
    # StandardError :
    # Si il est impossible de recuperer les propriétés de la page
    #----------------------------------------------------------------------------------------------------------------
    def display_start_page (start_url, visitor_id)

#TODO la size du browser nest pas gerer car window.open dans le self


      @@logger.an_event.debug "start_url : #{start_url}"
      @@logger.an_event.debug "visitor_id : #{visitor_id}"
      begin
        raise BrowserError.new(ARGUMENT_UNDEFINE), "start_url undefine" if start_url.nil? or start_url ==""
        raise BrowserError.new(ARGUMENT_UNDEFINE), "visitor_id undefine" if visitor_id.nil? or visitor_id == ""


        window_parameters = "width=#{@width},height=#{@height},channelmode=0,fullscreen=0,left=0,menubar=1,resizable=1,scrollbars=1,status=1,titlebar=1,toolbar=1,top=0"
        @@logger.an_event.debug "windows parameters : #{window_parameters}"


        encode_start_url = Addressable::URI.encode_component(start_url, Addressable::URI::CharacterClasses::UNRESERVED)

        start_page_visit_url = "http://#{$start_page_server_ip}:#{$start_page_server_port}/start_link?method=#{@method_start_page}&url=#{encode_start_url}&visitor_id=#{visitor_id}"
        @@logger.an_event.debug "start_page_visit_url : #{start_page_visit_url}"


        super(start_page_visit_url, window_parameters)

      rescue Exception => e
        raise e

      else
        @@logger.an_event.debug "#{name} display start page #{start_url}"

      ensure

      end
    end

    #-----------------------------------------------------------------------------------------------------------------
    # get_pid
    #-----------------------------------------------------------------------------------------------------------------
    # input : id_browser
    # output : tableau contenant les pids du browser
    # exception :
    # StandardError :
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
            raise StandardError, "file #{pids_name_file} not found"
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
      # StandardError :
      # si aucune pid n'est passé à la fonction
      # StandardError :
      # si il n'a pas été possible de tuer le browser
      #-----------------------------------------------------------------------------------------------------------------
      # est utilisé pour recuperer le pid, pour tuer le browser si Sahi n'a pas réussi
      #-----------------------------------------------------------------------------------------------------------------

      def kill(pid_arr)
        @@logger.an_event.debug "begin kill"

        raise StandardError, "no pid" if pid_arr == []

        pid_arr.each { |pid|
          begin
            cmd = 'powershell -NoLogo -NoProfile "Stop-Process ' + pid.to_s + '; exit $LASTEXITCODE" < NUL'
            @@logger.an_event.debug "command powershell : #{cmd}"
            ps_pid = Process.spawn(cmd)
            Process.waitpid(ps_pid)
          rescue Exception => e
            @@logger.an_event.debug e.message
            raise StandardError, "cannot kill pid #{pid}"
          ensure
            @@logger.an_event.debug "end kill"
          end
        }
      end

=end

    def set_input_search(type, input, keywords)
        r =  "#{type}(\"#{input}\", \"#{keywords}\")"
        eval(r)
        # google pour IE au travers de sahi fait ubn redirect wevrs www.google.fr/webhp? ... en supprimant les keywords
        # on rejoue alors l'affectation de la zone de recherche par le keyword
        eval(r)
    end
  end
end

