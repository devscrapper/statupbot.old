require 'pathname'
module Browsers
  module SahiCoIn
    class Proxy

      DIR_SAHI = Pathname(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co')).realpath
      DIR_SAHI_TOOLS = Pathname(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co', 'tools')).realpath
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


      #BIN_JAVA_PATH = "\"C:/Program Files (x86)/Java/jre6/bin/java\""

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
        @@logger.an_event.debug "begin initialize proxy"
        raise FunctionalError, "listening port proxy sahi is not define" if listening_port_proxy.nil?
        raise FunctionalError, "visitor runtime directory is not define" if visitor_dir.nil?
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
          # on precise le path de localisation de pslist et de pskill avant de copier vers userdata car c'est
          # les path sont identiques pour tous les userdata
          # DIR_SAHI\config\os.properties   avec :
          # le path de pslist
          # le path de pskill
          file_name = File.join(DIR_SAHI, 'config', 'os.properties')
          file_custom = File.read(file_name)
          file_custom.gsub!(/path_pslist/, File.join(DIR_SAHI_TOOLS, 'pslist.exe'))
          file_custom.gsub!(/path_pskill/,  File.join(DIR_SAHI_TOOLS, 'pskill.exe'))
          File.write(file_name, file_custom)
          @@logger.an_event.debug "customize path of pskill and pslist in #{file_name} with #{file_custom}"

          # on fait du nettoyage pour eviter de perturber le proxy avec un paramètrage bancal
          if File.exist?(@home)
            FileUtils.rm_r(@home, :force => true) if File.exist?(@home)
            @@logger.an_event.debug "clean config files proxy sahi for visitor dir #{@visitor_dir}"
          end

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
          @@logger.an_event.debug "copy config files proxy sahi #{DIR_SAHI} to #{@home}"

          # id_visitor\proxy\config\sahi.properties   avec :
          # le port d'ecoute du proxy
          # ip:port@user:pwd du proxy de geolocation (ou NTLM) pour http & https ou pas
          file_name = File.join(@home, 'config', 'sahi.properties')
          file_custom = File.read(file_name)
          file_custom.gsub!(/is_proxy_enable/, "false") if @ip_geo_proxy.nil?
          file_custom.gsub!(/ip_geo_proxy/, "") if @ip_geo_proxy.nil?
          file_custom.gsub!(/port_geo_proxy/, "".to_s) if @port_geo_proxy.nil?
          file_custom.gsub!(/is_auth_enable/, "false") if @user_geo_proxy.nil?
          file_custom.gsub!(/user_geo_proxy/, "") if @user_geo_proxy.nil?
          file_custom.gsub!(/pwd_geo_proxy/, "") if @pwd_geo_proxy.nil?
          file_custom.gsub!(/is_proxy_enable/, "true") unless @ip_geo_proxy.nil?
          file_custom.gsub!(/ip_geo_proxy/, @ip_geo_proxy) unless @ip_geo_proxy.nil?
          file_custom.gsub!(/port_geo_proxy/, @port_geo_proxy.to_s) unless @port_geo_proxy.nil?
          file_custom.gsub!(/is_auth_enable/, "true") unless @user_geo_proxy.nil?
          file_custom.gsub!(/user_geo_proxy/, @user_geo_proxy) unless @user_geo_proxy.nil?
          file_custom.gsub!(/pwd_geo_proxy/, @pwd_geo_proxy) unless @pwd_geo_proxy.nil?
          file_custom.gsub!(/listening_port_proxy/, @listening_port_proxy.to_s)
          #TODO valider l'externalisation du paramètre $java_key_tool_path sous wista xp w8 en raison des \\
          file_custom.gsub!(/java_key_tool_path/, $java_key_tool_path)

          File.write(file_name, file_custom)
          @@logger.an_event.debug "customize properties in #{file_name} with #{file_custom}"

        rescue Exception => e
          @@logger.an_event.error e.message
          raise TechnicalError, "config files proxy Sahi are not initialized"
        ensure
          @@logger.an_event.debug "proxy #{self.inspect}"
          @@logger.an_event.debug "end initialize proxy"
        end
      end


      def delete_config
        @@logger.an_event.debug "begin delete_config"
        try_count = 0
        max_try_count = 10
        begin
          FileUtils.rm_r(@home) if File.exist?(@home)
          @@logger.an_event.debug "config files proxy Sahi are deleted in #{@home}"
        rescue Exception => e
          @@logger.an_event.debug "config files proxy Sahi are not completly deleted, try #{try_count}"
          sleep (1)
          try_count += 1
          retry if try_count < max_try_count
          @@logger.an_event.debug e.message
          raise TechnicalError, "config files proxy Sahi are not completly deleted"
        ensure
          @@logger.an_event.debug "end delete_config"
        end
      end

      def start
        @@logger.an_event.debug "begin start proxy"
        begin
          #@pid = spawn("java -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" ") #lanceur proxy open source
          #cmd = "#{BIN_JAVA_PATH} -Djava.util.logging.config.file=#{@log_properties} -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" "
          cmd = "#{$java_runtime_path} -Djava.util.logging.config.file=#{@log_properties} -classpath #{CLASS_PATH} net.sf.sahi.Proxy \"#{@home}\" \"#{@user_home}\" "
          @@logger.an_event.debug "command execution proxy Sahi : #{cmd}"

          sahi_proxy_log_file = File.join(@user_home, 'logs', 'sahi_proxy_log.txt')
          @@logger.an_event.debug "file path log file proxy Sahi #{sahi_proxy_log_file}"

          @pid = Process.spawn(cmd, [:out, :err] => [sahi_proxy_log_file, "w"])
          @@logger.an_event.debug "proxy Sahi is started with pid #{@pid}"
        rescue Exception => e
          @@logger.an_event.error e.message
          raise TechnicalError, "proxy Sahi is not started"
        ensure
          # on ne delete pas les fichier s de config pour aider au debugging
          @@logger.an_event.debug "end start proxy"
        end
      end

      def stop
        @@logger.an_event.debug "begin stop proxy"
        begin
          Process.kill("KILL", @pid)
          Process.waitall
          @@logger.an_event.debug "proxy Sahi #{@pid} is stopped"
        rescue SignalException => e
          @@logger.an_event.error e.message
          raise TechnicalError, "proxy Sahi #{@pid} is not stopped"
        ensure
          # on ne delete pas les fichier s de config pour aider au debugging
          @@logger.an_event.debug "end stop proxy"
        end


      end
    end
  end
end
