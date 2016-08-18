require_relative '../../lib/error'
require_relative '../../lib/os'
require 'csv'
require 'yaml'

class BrowserTypes
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include Errors

  #----------------------------------------------------------------------------------------------------------------
  # Message exception
  #----------------------------------------------------------------------------------------------------------------
  ARGUMENT_NOT_DEFINE = 1100
  BROWSER_TYPE_NOT_DEFINE = 1101
  BROWSER_VERSION_NOT_DEFINE = 1102
  BROWSER_TYPE_EMPTY = 1103
  OS_VERSION_UNKNOWN = 1104
  OS_UNKNOWN = 1105
  BROWSER_TYPE_NOT_PUBLISH = 1106
  BROWSER_TYPE_NOT_CREATE = 1107
  #----------------------------------------------------------------------------------------------------------------
  # constants
  #----------------------------------------------------------------------------------------------------------------
  BROWSER_TYPE = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'repository', 'browser_type.csv')).realpath
  WIN32_XML = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'config', 'browser_types', 'win32.xml')).realpath
  WIN64_XML = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'config', 'browser_types', 'win64.xml')).realpath
  LINUX_XML = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'config', 'browser_types', 'linux.xml')).realpath
  MAC_XML = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'config', 'browser_types', 'mac.xml')).realpath

  STAGING = 0
  OPERATING_SYSTEM = 1
  OPERATING_SYSTEM_VERSION = 2
  BROWSER = 3
  BROWSER_VERSION = 4
  RUNTIME_PATH = 5
  PROXY_SYSTEM = 6
  START_LISTENING_PORT_PROXY = 7
  COUNT_PROXY = 8

  #----------------------------------------------------------------------------------------------------------------
  # attributs
  #----------------------------------------------------------------------------------------------------------------
  #TODO reviser les parametre de lancement des navigateur  :size window, ....
  attr :browsers,
       :current_os,
       :current_os_version,
       :logger
  #staging;os;os_version;browser;browser_version;runtime_path;sandbox;multi_instance_proxy_compatible;start_listening_port_proxy;count_proxy
  #development;Windows;7;Chrome;33.0.1750.117;C:\Users\ET00752\AppData\Local\Google\Chrome\Application\chrome.exe;false;true;9908;10

  #----------------------------------------------------------------------------------------------------------------
  # class methods
  #----------------------------------------------------------------------------------------------------------------
  def self.list
    begin
      raise Error.new(BROWSER_TYPE_NOT_DEFINE, values => {:path => BROWSER_TYPE}) unless File.exist?(BROWSER_TYPE)
      @current_os = OS.name
      @current_os_version = OS.version

      list = []
      rows = CSV.read(BROWSER_TYPE)
      rows.each { |row|
        elt_arr = row[0].split(/;/)
        if elt_arr[STAGING] == $staging and
            elt_arr[OPERATING_SYSTEM].to_sym == @current_os and
            elt_arr[OPERATING_SYSTEM_VERSION].to_sym == @current_os_version

          browser = elt_arr[BROWSER]
          browser_version = elt_arr[BROWSER_VERSION]
          list << "#{elt_arr[BROWSER]} - #{elt_arr[BROWSER_VERSION]}"
        end
      }
    rescue Exception => e
      raise Error.new(BROWSER_TYPE_NOT_CREATE, :error => e)

    else
      list

    end
  end


  def initialize(logger)
    #--------------------------------------------------------------------------------------------------------------
    #--------------------------------------------------------------------------------------------------------------
    # ATTENTION
    #----------
    # la variable Listening port proxy sahi du repository browser_type.csv n'est pas utilisé pour paraméter le
    # browser. Le browser est paramétrer lors du patch du custom_properties du navigateur
    # TODO revision du model browser_type
    #--------------------------------------------------------------------------------------------------------------
    #--------------------------------------------------------------------------------------------------------------
    begin
      raise Error.new(BROWSER_TYPE_NOT_DEFINE, values => {:path => BROWSER_TYPE}) unless File.exist?(BROWSER_TYPE)
      @current_os = OS.name
      @current_os_version = OS.version
      @logger = logger
      @logger.a_log.debug $staging
      @logger.a_log.debug @current_os
      @logger.a_log.debug @current_os_version
      rows = CSV.read(BROWSER_TYPE)
      rows.each { |row|
        unless row.empty?
          elt_arr = row[0].split(/;/)

          if elt_arr[STAGING] == $staging and
              elt_arr[OPERATING_SYSTEM].to_sym == @current_os and
              elt_arr[OPERATING_SYSTEM_VERSION].to_sym == @current_os_version

            browser = elt_arr[BROWSER]
            browser_version = elt_arr[BROWSER_VERSION]
            data = {
                "runtime_path" => elt_arr[RUNTIME_PATH],
                "proxy_system" => elt_arr[PROXY_SYSTEM],
                "listening_port_proxy" => elt_arr[START_LISTENING_PORT_PROXY].to_i
            }
            @logger.a_log.debug data
            @browsers = {browser => {browser_version => data}} if @browsers.nil?
            @browsers[browser] = {browser_version => data} if @browsers[browser].nil?
            @browsers[browser][browser_version] = data if @browsers[browser][browser_version].nil?
          end
        end

      }
    rescue Exception => e
      raise Error.new(BROWSER_TYPE_NOT_CREATE, :error => e)
    else
    ensure
    end
  end

  #----------------------------------------------------------------------------------------------------------------
  # instance methods
  #----------------------------------------------------------------------------------------------------------------
  def publish_to_sahi


# si la var envir "ProgramFiles(x86)" n'existe pas : XP, Vista
    begin
      raise Error.new(BROWSER_TYPE_EMPTY) if @browsers.nil?

      data = <<-_end_of_xml_
<browserTypes>
#{publish_browsers}
</browserTypes>
      _end_of_xml_
      data

      case @current_os
        when :windows
          case @current_os_version
            when :xp, :vista
              out_filename = WIN32_XML
            when :seven
              out_filename = WIN64_XML
            else
              raise Error.new(OS_VERSION_UNKNOWN, :value => {:os => @current_os, :vrs => @current_os_version})
          end
        when :linux
          out_filename = LINUX_XML
        when :mac
          out_filename = MAC_XML
        else
          raise Error.new(OS_UNKNOWN, :value => {:os => @current_os})
      end
      f = File.new(out_filename, "w+")
      f.write(data)
      f.close

    rescue Exception => e
      raise Error.new(BROWSER_TYPE_NOT_PUBLISH, :error => e)
    else
    ensure
    end
  end


  def browser
    browser_arr = []
    @browsers.each_key { |browser| browser_arr << browser }
    browser_arr
  end

  def browser_version(browser)
    browser_version_arr = []
    @browsers[browser].each_key { |browser_version| browser_version_arr << browser_version }
    browser_version_arr
  end

  def proxy_system?(browser, browser_version)
    begin
      @browsers[browser][browser_version]["proxy_system"]=="true"
    rescue Exception => e
      raise Error.new(BROWSER_VERSION_NOT_DEFINE, :values => {:browser => browser, :vrs => browser_version})
    ensure
    end
  end

  def listening_port_proxy(browser, browser_version)
    begin
      @browsers[browser][browser_version]["listening_port_proxy"]
    rescue Exception => e
      raise Error.new(BROWSER_VERSION_NOT_DEFINE, :values => {:browser => browser, :vrs => browser_version})
    ensure
    end
  end

  def runtime_path(browser, browser_version)
    begin
      @browsers[browser][browser_version]["runtime_path"]
    rescue Exception => e
      raise Error.new(BROWSER_VERSION_NOT_DEFINE, :values => {:browser => browser, :vrs => browser_version})
    ensure
    end
  end

  def to_yaml
    @browsers.to_yaml
  end

  #----------------------------------------------------------------------------------------------------------------
  # instance methods  private
  #----------------------------------------------------------------------------------------------------------------
  private
  def browser_type(name, display_name, icon, path, options, process_name, use_system_proxy)
=begin
            <browserType>
              <name>Internet_Explorer_8.0</name>
              <displayName>IE 8</displayName>
              <icon>ie.png</icon>
              <path>C:\Program Files (x86)\Internet Explorer\iexplore.exe</path>
              <options>-noframemerging</options>
              <processName>iexplore.exe</processName>
              <useSystemProxy>false</useSystemProxy>
              <capacity>1</capacity>
            </browserType>

=end
    a = <<-_end_of_xml_
  <browserType>
      <name>#{name}</name>
      <displayName>#{display_name}</displayName>
      <icon>#{icon}</icon>
      <path>#{path}</path>
      <options>#{options}</options>
      <processName>#{process_name}</processName>
      <useSystemProxy>#{use_system_proxy}</useSystemProxy>
      <capacity>1</capacity>
  </browserType>
    _end_of_xml_
    a
  end

  def Internet_Explorer(browser_versions)
    res = ""
    browser_versions.each_pair { |version, details|
      port = details["listening_port_proxy"]

      if details["proxy_system"] == "true"
        name = "Internet_Explorer_#{version}"
        use_system_proxy = "true"
      else
        name = "Internet_Explorer_#{version}_#{port}"
        use_system_proxy = "false"
      end
      if details["sandbox"] == "true" and (details["multi_instance_proxy_compatible"] == "true" or details["multi_instance_proxy_compatible"] == "false")
        name = "Internet_Explorer_#{version}_#{port}"
        use_system_proxy = "false"
      end

      display_name = "IE #{version}"
      icon = "ie.png"
      path = details["runtime_path"]
      options = "-noframemerging"
      process_name = "iexplore.exe"

      res += browser_type(name, display_name, icon, path, options, process_name, use_system_proxy)

    }
    res
  end

  def Firefox(browser_versions)
    res = ""
    browser_versions.each_pair { |version, details|
      name ="Firefox_#{version}"
      use_system_proxy = "false"
      display_name = "Firefox #{version}"
      icon = "firefox.png"
      path = details["runtime_path"]
      options = "-profile \"$userDir/browser/ff/profiles/sahi$threadNo\" -no-remote -height height_browser -width width_browser"
      process_name = "firefox.exe"

      res += browser_type(name, display_name, icon, path, options, process_name, use_system_proxy)
    }
    res
  end

  def Chrome(browser_versions)
    res = ""
    browser_versions.each_pair { |version, details|
      name ="Chrome_#{version}"
      use_system_proxy = "false"
      display_name = "Chrome #{version}"
      icon = "chrome.png"
      path = details["runtime_path"]
      options = "--user-data-dir=$userDir\\browser\\chrome\\profiles\\sahi$threadNo
                --proxy-server=localhost:listening_port_proxy --disable-popup-blocking --always-authorize-plugins --allow-outdated-plugins --incognito --window-size=width_browser,height_browser
                --window-position=0,0"
      process_name = "chrome.exe"

      res += browser_type(name, display_name, icon, path, options, process_name, use_system_proxy)
    }
    res
  end

  def Safari(browser_versions)
    #appliquer la methode internet explorer
  end

  def Opera(browser_versions)
    # verifier que l'on peut appliquer la methode firefox, sinon sandboxing comme IE
    # <browserType>
    # 	<name>opera</name>
    # 	<displayName>Opera</displayName>
    # 	<icon>opera.png</icon>
    # 	<path>$ProgramFiles\Opera\opera.exe</path>
    # 	<options> </options>
    # 	<processName>opera.exe</processName>
    # 	<useSystemProxy>true</useSystemProxy>
    # 	<capacity>1</capacity>
    # </browserType>
    res = ""
    browser_versions.each_pair { |version, details|
      name ="Opera_#{version}"
      use_system_proxy = "true"
      display_name = "Opera #{version}"
      icon = "opera.png"
      path = details["runtime_path"]
      options = ""
      process_name = "opera.exe"

      res += browser_type(name, display_name, icon, path, options, process_name, use_system_proxy)
    }
    res
  end

  def publish_browsers
    res = ""
    @browsers.each { |browser|
      case browser[0]
        when "Internet Explorer"
          res += Internet_Explorer(browser[1])
        when "Firefox"
          res += Firefox(browser[1])
        when "Chrome"
          res += Chrome(browser[1])
        when "Opera"
          res += Opera(browser[1])
      end
    } unless browsers.nil?
    res
  end

end
