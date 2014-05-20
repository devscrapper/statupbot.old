module Browsers
  module SahiCoIn
    class Firefox < Browser
      #----------------------------------------------------------------------------------------------------------------
      # message exception
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------

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
        @@logger.an_event.debug "BEGIN Firefox.initialize"
        @@logger.an_event.debug "name #{browser_details[:name]}"
        @@logger.an_event.debug "version #{browser_details[:version]}"
        @@logger.an_event.debug "visitor_dir #{visitor_dir}"

        raise ArgumentError, "browser name undefine" if browser_details[:name].nil? or browser_details[:name] == ""
        raise ArgumentError, "browser version undefine" if browser_details[:version].nil? or browser_details[:version] == ""
        raise ArgumentError, "visitor_dir undefine" if visitor_dir.nil? or visitor_dir == ""

        @@logger.an_event.debug "name #{browser_details[:name]}"
        @@logger.an_event.debug "version #{browser_details[:version]}"
        @@logger.an_event.debug "visitor_dir #{visitor_dir}"

        begin
          super(browser_details,
                "#{browser_details[:name]}_#{browser_details[:version]}",
                DATA_URI,
                visitor_dir)
        rescue Exception => e
          raise e
        ensure
          @@logger.an_event.debug "END Firefox.initialize"
        end
      end

      def customize_properties(visitor_dir)
        @@logger.an_event.debug "BEGIN Firefox.customize_properties"
        @@logger.an_event.debug "visitor_dir #{visitor_dir}"

        raise ArgumentError, "visitor_dir undefine" if visitor_dir.nil? or visitor_dir == ""
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
        @@logger.an_event.debug "END Firefox.customize_properties"
      end

      #----------------------------------------------------------------------------------------------------------------
      # display_start_page
      #----------------------------------------------------------------------------------------------------------------
      # ouvre un nouvelle fenetre du navigateur adaptée aux propriété du naviagateur et celle de la visit
      # affiche la root page du site https pour initialisé le référer à non défini
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

      #----------------------------------------------------------------------------------------------------------------
      # input : url (String)
      # output : RAS
      # exception : RAS
      #----------------------------------------------------------------------------------------------------------------
      def display_start_page(start_url, visitor_id)
        @@logger.an_event.debug "BEGIN Firefox.display_start_page"

        @@logger.an_event.debug "start_url : #{start_url}"
        @@logger.an_event.debug "visitor_id : #{visitor_id}"

        raise ArgumentError, "start_url undefine" if start_url.nil? or start_url ==""
        raise ArgumentError, "visitor_id undefine" if visitor_id.nil? or visitor_id == ""

        window_parameters = "width=#{@width},height=#{@height},fullscreen=no,left=0,menubar=yes,scrollbars=yes,status=yes,titlebar=yes,toolbar=yes,top=0"
        @@logger.an_event.debug "windows parameters : #{window_parameters}"

        cmd = "_sahi.open_start_page_ff(\"http://127.0.0.1:8080/start_link?method=#{@method_start_page}&url=#{start_url}&visitor_id=#{visitor_id}\",\"#{window_parameters}\")"
        @@logger.an_event.debug "cmd : #{cmd}"
        begin
          page = super(cmd)
        rescue Exception => e
          raise e
        else
          return page
        ensure
          @@logger.an_event.debug "END Firefox.display_start_page"
        end
      end
    end
  end
end