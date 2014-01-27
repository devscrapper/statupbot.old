module Browsers
  module SahiCoIn
    class Proxy
      class ProxyException < StandardError
        PROXY_NOT_STARTED = "Sahi proxy is not started"
        PROXY_FAIL_TO_STOP ="Stop of Sahi proxy failed"
        PROXY_FAIL_TO_CLEAN_PROPERTIES = "proxy cannot clean file completly"
      end
      DIR_VISITORS = File.join(File.dirname(__FILE__), '..', '..', '..', 'visitors')
      DIR_SAHI = File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co')
      CLASS_PATH = File.join(DIR_SAHI, 'lib', 'sahi.jar') + ';' +
          File.join(DIR_SAHI, 'extlib', 'rhino', 'js.jar') + ';' +
          File.join(DIR_SAHI, 'extlib', 'apc', 'commons-codec-1.3.jar')


      attr :pid, #pid du process java -classpath %class_path% net.sf.sahi.Proxy "%home%" "%user_home%"
           :listening_port_proxy, #port d'écoute de Sahi_proxy
           :home, # répertoire de config de Sahi_proxy
           :user_home, # répertoire de config du visitor (user)
           :ip_geo_proxy,
           :port_geo_proxy,
           :user_geo_proxy,
           :pwd_geo_proxy,
           :visitor_id

      def initialize(visitor_id, listening_port_proxy, ip_geo_proxy, port_geo_proxy, user_geo_proxy, pwd_geo_proxy)
        @ip_geo_proxy = ip_geo_proxy
        @port_geo_proxy = port_geo_proxy
        @user_geo_proxy = user_geo_proxy
        @pwd_geo_proxy = pwd_geo_proxy
        @listening_port_proxy = listening_port_proxy
        @visitor_id = visitor_id
        @home = File.join(DIR_VISITORS, visitor_id, 'proxy')
        @user_home = File.join(DIR_VISITORS, visitor_id, 'proxy', 'userdata')
      end

      def start
        begin
          copy_config
          customize_properties
          @pid = spawn("java -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" ")
          @@logger.an_event.debug "Sahi proxy is started"
        rescue Exception => e
          @@logger.an_event.debug "Sahi proxy is not started"
          @@logger.an_event.debug e
          raise ProxyException::PROXY_NOT_STARTED
        end
      end

      def stop
        begin
          Process.kill("KILL", @pid)
        rescue SignalException => e
          @@logger.an_event.debug "java Sahi proxy failed to stop"
          @@logger.an_event.debug e
          raise ProxyException::PROXY_FAIL_TO_STOP
        end

        begin

          Process.waitall
          @@logger.an_event.debug "java Sahi proxy is stopped"
        rescue Exception => e
          @@logger.an_event.error "java Sahi proxy is not stopped"
          @@logger.an_event.debug e
          raise ProxyException::PROXY_FAIL_TO_STOP
        end

        begin
          FileUtils.rm_r File.join(DIR_VISITORS, @visitor_id, 'proxy'), :force => true
          @@logger.an_event.debug "all customize files are deleted"
        rescue Exception => e
          @@logger.an_event.warn "all customize files are not completly deleted"
          @@logger.an_event.debug e
          raise ProxyException::PROXY_FAIL_TO_CLEAN_PROPERTIES
        end
      end

      def copy_config
        # statupbot\lib\sahi.in.co\userdata\config to #id_visitor\proxy\userdata\config\userdata\config
        # statupbot\lib\sahi.in.co\config to #id_visitor\proxy\config
        # statupbot\lib\sahi.in.co\htdocs to #id_visitor\proxy\htdocs
        # statupbot\lib\sahi.in.co\tools to #id_visitor\proxy\tools
        FileUtils.mkdir_p(File.join(DIR_VISITORS, @visitor_id, 'proxy', 'userdata', 'config'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'config'), File.join(DIR_VISITORS, @visitor_id, 'proxy', 'userdata'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'config'), File.join(DIR_VISITORS, @visitor_id, 'proxy'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'htdocs'), File.join(DIR_VISITORS, @visitor_id, 'proxy'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'tools'), File.join(DIR_VISITORS, @visitor_id, 'proxy'))
      end

      def customize_properties
        # id_visitor\proxy\tools\proxy.properties :
        # le port d'ecoute du proxy pour internet explorer
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'tools', 'proxy.properties')
        file_custom = File.read(file_name)
        3.times { file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s) }
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\ff_profile_template\prefs.js :
        # le port d'ecoute du proxy pour firefox
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'ff_profile_template', 'prefs.js')
        file_custom = File.read(file_name)
        2.times { file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s) }
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win64.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'browser_types', 'win64.xml')
        file_custom = File.read(file_name)
        file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\win32.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'browser_types', 'win32.xml')
        file_custom = File.read(file_name)
        file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\mac.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'browser_types', 'mac.xml')
        file_custom = File.read(file_name)
        file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\browser_types\linux.xml :
        # le port d'ecoute du proxy pour chrome
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'browser_types', 'linux.xml')
        file_custom = File.read(file_name)
        file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)

        # id_visitor\proxy\config\sahi.properties   avec :
        # le port d'ecoute du proxy
        # #id_visitor\proxy\userdata\config\userdata\config\userdata.properties avec  :
        # ip:port@user:pwd du proxy de geolocation (ou NTLM)
        file_name = File.join(DIR_VISITORS, @visitor_id, 'proxy', 'config', 'sahi.properties')
        file_custom = File.read(file_name)
        2.times { file_custom.sub!(/ip_geo_proxy/, @ip_geo_proxy)
        file_custom.sub!(/port_geo_proxy/, @port_geo_proxy.to_s)
        file_custom.sub!(/user_geo_proxy/, @user_geo_proxy)
        file_custom.sub!(/pwd_geo_proxy/, @pwd_geo_proxy)
        file_custom.sub!(/listening_port_proxy/, @listening_port_proxy.to_s) }
        File.write(file_name, file_custom)
      end
    end
  end
end
