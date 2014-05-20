require 'csv'
require 'yaml'
module VisitorFactory
  class BrowserTypes
    STAGING = 0
    OS = 1
    OS_VERSION = 2
    BROWSER = 3
    BROWSER_VERSION = 4
    RUNTIME_PATH = 5
    PROXY_SYSTEM = 6
    START_LISTENING_PORT_PROXY = 7
    COUNT_PROXY = 8

    attr :hash
    #staging;os;os_version;browser;browser_version;runtime_path;sandbox;multi_instance_proxy_compatible;start_listening_port_proxy;count_proxy
    #development;Windows;7;Chrome;33.0.1750.117;C:\Users\ET00752\AppData\Local\Google\Chrome\Application\chrome.exe;false;true;9908;10
    def initialize(filename)
      raise StandardError, "file #{filename} not found" unless File.exist?(filename)

      rows = CSV.read(filename)
      title = rows.shift
      rows.each { |row|
        elt_arr = row[0].split(/;/)
        if elt_arr[STAGING] == $staging
          os = elt_arr[OS]
          os_version = elt_arr[OS_VERSION]
          browser = elt_arr[BROWSER]
          browser_version = elt_arr[BROWSER_VERSION]
          data = {
              "runtime_path" => elt_arr[RUNTIME_PATH],
              "proxy_system" => elt_arr[PROXY_SYSTEM],
              "listening_port_proxy" => Array.new(elt_arr[COUNT_PROXY].to_i) { |index| -1 * (index - elt_arr[START_LISTENING_PORT_PROXY].to_i) }
          }

          @hash = {os => {os_version => {browser => {browser_version => data}}}} if @hash.nil?
          @hash[os] = {os_version => {browser => {browser_version => data}}} if @hash[os].nil?
          @hash[os][os_version] = {browser => {browser_version => data}} if @hash[os][os_version].nil?
          @hash[os][os_version][browser] = {browser_version => data} if @hash[os][os_version][browser].nil?
          @hash[os][os_version][browser][browser_version] = data if @hash[os][os_version][browser][browser_version].nil?
        end
      }
    end

    def os
      os_arr = []
      @hash.each_key { |os| os_arr << os }
      os_arr
    end

    def os_version(os)
      os_version_arr = []
      @hash[os].each_key { |os_version| os_version_arr << os_version }
      os_version_arr
    end

    def browser(os, os_version)
      browser_arr = []
      @hash[os][os_version].each_key { |browser| browser_arr << browser }
      browser_arr
    end

    def browser_version(os, os_version, browser)
      browser_version_arr = []
      @hash[os][os_version][browser].each_key { |browser_version| browser_version_arr << browser_version }
      browser_version_arr
    end

    def proxy_system?(os, os_version, browser, browser_version)
      begin
        @hash[os][os_version][browser][browser_version]["proxy_system"]=="true"
      rescue Exception => e
        raise StandardError, "#{os} #{os_version} #{browser} #{browser_version} not define in browser type"
      ensure
      end
    end

    def listening_port_proxy(os, os_version, browser, browser_version)
      begin
        @hash[os][os_version][browser][browser_version]["listening_port_proxy"]
      rescue Exception => e
        raise StandardError, "#{os} #{os_version} #{browser} #{browser_version} not define in browser type"
      ensure
      end
    end

    def to_yaml
      @hash
    end

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
        details["listening_port_proxy"].each { |port|
          name =""
          use_system_proxy = ""
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
                --proxy-server=localhost:listening_port_proxy --disable-popup-blocking --window-size=width_browser,height_browser
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
    end

    def browsers(browsers)
      res = ""
      browsers.each { |browser|
        case browser[0]
          when "Internet Explorer"
            res += Internet_Explorer(browser[1])
          when "Firefox"
            res += Firefox(browser[1])
          when "Chrome"
            res += Chrome(browser[1])
        end
      } unless browsers.nil?
      res
    end

    def to_win32(out_filename)
      # si la var envir "ProgramFiles(x86)" n'existe pas : XP, quid de Vista, 8
      data = <<-_end_of_xml_
<browserTypes>
#{browsers(@hash["Windows"]["XP"])}
#{browsers(@hash["Windows"]["VISTA"])}
</browserTypes>
      _end_of_xml_
      data
      f = File.new(out_filename, "w+")
      f.write(data)
      f.close
    end

    def to_win64 (out_filename)
      # si la var envir "ProgramFiles(x86)" existe : Seven, quid de Vista, 8
      data = <<-_end_of_xml_
<browserTypes>
 #{browsers(@hash["Windows"]["7"])}
 #{browsers(@hash["Windows"]["8"])}
</browserTypes>
      _end_of_xml_
      f = File.new(out_filename, "w+")
      f.write(data)
      f.close
    end

    def to_mac (out_filename)
      data = <<-_end_of_xml_
                  <browserTypes>
                   #{browsers(@hash["Windows"]["MAC"])}
                  </browserTypes>
      _end_of_xml_
      p data
      #  File.new(out_filename).write(data)
    end

    def to_linux(out_filename)
      data = <<-_end_of_xml_
                  <browserTypes>
                   #{browsers(@hash["Windows"]["LINUX"])}
                  </browserTypes>
      _end_of_xml_
      p data
      #  File.new(out_filename).write(data)
    end
  end
end