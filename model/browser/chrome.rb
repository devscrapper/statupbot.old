require_relative '../../lib/error'
module Browsers
  class Chrome < Browser
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
      @@logger.an_event.debug "visitor_dir #{visitor_dir}"


      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser name"}) if browser_details[:name].nil? or browser_details[:name] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser version"}) if browser_details[:version].nil? or browser_details[:version] == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_dir"}) if visitor_dir.nil? or visitor_dir == ""


        super(browser_details,
              "#{browser_details[:name]}_#{browser_details[:version]}",
              NO_REFERER,
              visitor_dir)
      rescue Exception => e
        raise e

      else
        @@logger.an_event.debug "chrome #{@version} initialize"

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
        file_custom.gsub!(/wait_time/, 100.to_s)
        File.write(file_name, file_custom)

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

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(BROWSER_NOT_CUSTOM_FILE, :values => {:browser => name}, :error => e)

      else
        @@logger.an_event.debug "chrome #{@version} customize config file proxy sahi"

      ensure

      end
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
    #status=yes|no|1|0 	Whether or not to add a status bar
    #titlebar=yes|no|1|0 	Whether or not to display the title bar. Ignored unless the calling application is an HTML Application or a trusted dialog box
    #top=pixels 	The top position of the window. Negative values not allowed
    #width=pixels 	The width of the window. Min. value is 100
    #@driver.open_start_page("width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0")
    # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
    # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
    #----------------------------------------------------------------------------------------------------------------
    # input : url (String)
    # output : RAS
    # exception : RAS
    #----------------------------------------------------------------------------------------------------------------
    def display_start_page(start_url, visitor_id)
      @@logger.an_event.debug "start_url : #{start_url}"
      @@logger.an_event.debug "visitor_id : #{visitor_id}"


      #TODO prendre en compte les window parameter pour chrome
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "start_url"}) if start_url.nil? or start_url ==""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_id"}) if visitor_id.nil? or visitor_id == ""

        window_parameters = "width=#{@width},height=#{@height},fullscreen=0,left=0,menubar=1,status=1,titlebar=1,top=0"
        @@logger.an_event.debug "windows parameters : #{window_parameters}"

        start_page_visit_url = "http://#{$start_page_server_ip}:#{$start_page_server_port}/start_link?method=#{@method_start_page}&url=#{start_url}&visitor_id=#{visitor_id}\",\"#{window_parameters}"
        @@logger.an_event.debug "start_page_visit_url : #{start_page_visit_url}"

        start_page = super("_sahi.open_start_page_ch", start_page_visit_url)
        #TODO à corriger


        page = click_on(start_url)

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(BROWSER_NOT_DISPLAY_PAGE, :values => {:browser => name, :page => start_url}, :error => e)

      else
        @@logger.an_event.debug "#{name} display start page #{start_url}"

        return page

      ensure

      end
    end
  end
end
