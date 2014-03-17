require 'pathname'
module Browsers
  module SahiCoIn
    class Proxy
      class ProxyException < StandardError
        CUSTOMIZATION_FAILED = "customization Sahi proxy failed"
        NOT_STARTED = "Sahi proxy is not started"
        FAIL_TO_STOP ="Stop of Sahi proxy failed"
      end

      DIR_SAHI = Pathname(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co')).realpath
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

      #TODO automasiter ou parameter la localisation du runtime java
      BIN_JAVA_PATH = File.join('C:', 'Program Files', 'Java', 'jre6', 'bin', 'java')

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
        @log_properties = File.join(@user_home, 'config', 'log.properties')
        begin
          copy_config
          customize_properties
        rescue Exception => e
          @@logger.an_event.debug e
          delete_config
          raise ProxyException::CUSTOMIZATION_FAILED
        end
      end


      def copy_config
        # statupbot\lib\sahi.in.co\userdata\config to #id_visitor\proxy\userdata\config\userdata\config
        # statupbot\lib\sahi.in.co\config to #id_visitor\proxy\config
        # statupbot\lib\sahi.in.co\htdocs to #id_visitor\proxy\htdocs
        # statupbot\lib\sahi.in.co\tools to #id_visitor\proxy\tools
        FileUtils.mkdir_p(File.join(@user_home, 'config'))
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'config'), @user_home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'certgen'), @user_home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'userdata', 'logs'), @user_home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'certgen'), @home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'config'), @home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'htdocs'), @home)
        FileUtils.cp_r(File.join(DIR_SAHI, 'tools'), @home)
        @@logger.an_event.debug "copy config sahi #{DIR_SAHI} to #{@home}"
      end

      def customize_properties
        # id_visitor\proxy\config\sahi.properties   avec :
        # le port d'ecoute du proxy
        # #id_visitor\proxy\userdata\config\userdata\config\userdata.properties avec  :
        # ip:port@user:pwd du proxy de geolocation (ou NTLM)
        file_name = File.join(@home, 'config', 'sahi.properties')
        file_custom = File.read(file_name)
        file_custom.gsub!(/ip_geo_proxy/, @ip_geo_proxy) unless @ip_geo_proxy.nil?
        file_custom.gsub!(/port_geo_proxy/, @port_geo_proxy.to_s) unless @port_geo_proxy.nil?
        file_custom.gsub!(/user_geo_proxy/, @user_geo_proxy) unless @user_geo_proxy.nil?
        file_custom.gsub!(/pwd_geo_proxy/, @pwd_geo_proxy) unless @pwd_geo_proxy.nil?
        file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
        File.write(file_name, file_custom)
        @@logger.an_event.debug "customize properties in #{file_name} with #{file_custom}"
      end

      def delete_config
        begin
       #   FileUtils.rm_r(@home, :force => true) if File.exist?(@home)
          @@logger.an_event.debug "all customize files of proxy Sahi are deleted in #{@home}"
        rescue Exception => e
          @@logger.an_event.warn "all customize files of proxy Sahi are not completly deleted"
          @@logger.an_event.debug e
        end
      end

      def start
        begin
          #@pid = spawn("java -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" ") #lanceur proxy open source
          cmd = "java -Djava.util.logging.config.file=#{@log_properties} -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" "
          @@logger.an_event.debug "command execution proxy : #{cmd}"
          sahi_proxy_log_file = File.join(@user_home,'logs','sahi_proxy_log.txt')
          @@logger.an_event.debug  "sahi proxy log file #{sahi_proxy_log_file}"
          p "je dors 5s"
          sleep(5)
          p "c'est parti...."
          @pid = Process.spawn(cmd, [:out,:err]=>[sahi_proxy_log_file, "w"])
          @@logger.an_event.debug "Sahi proxy is started with pid #{@pid}"
        rescue Exception => e
          @@logger.an_event.error "Sahi proxy is not started"
          @@logger.an_event.debug e
          delete_config
          raise ProxyException::NOT_STARTED
        end
      end

      def stop
        begin
          Process.kill("KILL", @pid)
          Process.waitall
          delete_config
          @@logger.an_event.debug "Sahi proxy pid #{@pid} is stopped"
        rescue SignalException => e
          @@logger.an_event.error "Sahi proxy #{@pid} failed to stop"
          @@logger.an_event.debug e
          delete_config
          raise ProxyException::FAIL_TO_STOP
        end


      end
    end
  end
end
