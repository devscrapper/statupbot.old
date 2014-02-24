module Browsers
  module SahiCoIn
    class Proxy
      class ProxyException < StandardError
        PROXY_NOT_STARTED = "Sahi proxy is not started"
        PROXY_FAIL_TO_STOP ="Stop of Sahi proxy failed"
        PROXY_FAIL_TO_CLEAN_PROPERTIES = "proxy cannot clean file completly"
      end

      DIR_SAHI = File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co')
      #CLASSPATH PROXY OPEN SOURCE
      #CLASS_PATH = File.join(DIR_SAHI, 'lib', 'sahi.jar') + ';' +
      #    File.join(DIR_SAHI, 'extlib', 'rhino', 'js.jar') + ';' +
      #    File.join(DIR_SAHI, 'extlib', 'apc', 'commons-codec-1.3.jar')

      #CLASS PATH PROXY PRO
      CLASS_PATH = File.join(DIR_SAHI, 'lib', 'sahi.jar') + ';' +
          File.join(DIR_SAHI, 'extlib', 'rhino', 'js.jar') + ';' +
          File.join(DIR_SAHI, 'extlib', 'apc', 'commons-codec-1.3.jar' + ';' +
              File.join(DIR_SAHI, 'extlib', 'db', 'h2.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'license', 'truelicense.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'license', 'truexml.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'dom4j-1.6.1.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'excelpoi.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'poi-3.7-20101029.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'poi-ooxml-3.7-20101029.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'poi-ooxml-schemas-3.7-20101029.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'poi', 'xmlbeans-2.3.0.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'mail', 'mail.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'mail', 'activation.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'c3p0', 'c3p0-0.9.5-pre5.jar') + ';' +
              File.join(DIR_SAHI, 'extlib', 'c3p0', 'mchange-commons-java-0.2.6.2'))


      BIN_JAVA_PATH = File.join('C:','Program Files','Java', 'jre6', 'bin', 'java')

      attr :pid, #pid du process java -classpath %class_path% net.sf.sahi.Proxy "%home%" "%user_home%"
           :listening_port_proxy, #port d'écoute de Sahi_proxy
           :home, # répertoire de config de Sahi_proxy
           :user_home, # répertoire de config du visitor (user)
           :ip_geo_proxy,
           :port_geo_proxy,
           :user_geo_proxy,
           :pwd_geo_proxy,
           :visitor_dir

      def initialize(visitor_dir, listening_port_proxy, ip_geo_proxy, port_geo_proxy, user_geo_proxy, pwd_geo_proxy)
        @ip_geo_proxy = ip_geo_proxy
        @port_geo_proxy = port_geo_proxy
        @user_geo_proxy = user_geo_proxy
        @pwd_geo_proxy = pwd_geo_proxy
        @listening_port_proxy = listening_port_proxy
        @visitor_dir = visitor_dir
        @home = File.join(@visitor_dir, 'proxy')
        @user_home = File.join(@visitor_dir, 'proxy', 'userdata')
        copy_config
        customize_properties
      end

      def start
        begin

          #@pid = spawn("java -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" ") #lanceur proxy open source
          @pid = spawn("java -Djava.util.logging.config.file=#{@user_home}\config\log.properties -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" ")
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
          FileUtils.rm_r File.join(@visitor_dir, 'proxy'), :force => true
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
        FileUtils.mkdir_p(File.join(@visitor_dir, 'proxy', 'userdata', 'config'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'config'), File.join(@visitor_dir, 'proxy', 'userdata'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'certgen'), File.join(@visitor_dir, 'proxy', 'userdata'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'config'), File.join(@visitor_dir, 'proxy'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'htdocs'), File.join(@visitor_dir, 'proxy'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'tools'), File.join(@visitor_dir, 'proxy'))
      end

      def customize_properties
        # id_visitor\proxy\config\sahi.properties   avec :
        # le port d'ecoute du proxy
        # #id_visitor\proxy\userdata\config\userdata\config\userdata.properties avec  :
        # ip:port@user:pwd du proxy de geolocation (ou NTLM)
        file_name = File.join(@visitor_dir, 'proxy', 'config', 'sahi.properties')
        file_custom = File.read(file_name)
        file_custom.gsub!(/ip_geo_proxy/, @ip_geo_proxy) unless @ip_geo_proxy.nil?
        file_custom.gsub!(/port_geo_proxy/, @port_geo_proxy.to_s) unless @port_geo_proxy.nil?
        file_custom.gsub!(/user_geo_proxy/, @user_geo_proxy) unless @user_geo_proxy.nil?
        file_custom.gsub!(/pwd_geo_proxy/, @pwd_geo_proxy) unless @pwd_geo_proxy.nil?
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)
      end


    end
  end
end
