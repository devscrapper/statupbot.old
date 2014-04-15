module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser

      def browser_type
        @browser_type
      end

      #-----------------------------------------------------------------------------------------------------------------
      # browser_type_exist?
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output :
      #   true : le browser type existe dans au moins un des fichiers lib/sahi.in.co/config/browser_type/win32/64, mac, linux.xml
      # exception :
      #   TechnicalError : prb d'accès technique aux fichiers.
      #-----------------------------------------------------------------------------------------------------------------
      # ATTENTION : controle que le browser type est présent dans au moins fichier, pas dans celui utilisé pour l'OS COURANT
      #-----------------------------------------------------------------------------------------------------------------
      def browser_type_exist?
        exist = false
        require 'rexml/document'
        include REXML
        begin
          ["win32.xml", "win64.xml", "mac.xml", "linux.xml"].each { |file_name|
            path_name = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co', 'config', "browser_types", file_name)).realpath
            if File.exist?(path_name)
              browser_type_file = File.new(path_name)
              exist ||= REXML::XPath.match(REXML::Document.new(browser_type_file), "browserTypes/browserType/name").map { |e| e.to_a[0] }.include?(@browser_type)
            else
              @@logger.an_event.warn "config file #{file_name} not exist"
            end

          }
        rescue Exception => e
          @@logger.an_event.fatal e.message
          raise TechnicalError, "access to browser type files failed"
        ensure

        end
        raise FunctionalError, "browser_type #{@browser_type} not found in win32/64, mac, linux files" unless exist
      end

      #-----------------------------------------------------------------------------------------------------------------
      # close
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # TechnicalError :
      #     - sahi ne peut arreter le navigateur car plusieurs occurences du navigateur s'exécute
      #     - tout autre erreur
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------

      def close
        @@logger.an_event.debug "begin close driver"
        begin
          exec_command("kill");
        rescue Timeout::Error => e
          @@logger.an_event.debug "driver #{@browser_type} cannot close : #{e.message}"
          raise TechnicalError, "sahi cannot close browser #{@browser_type}, time out"
        rescue Exception => e
          @@logger.an_event.error "driver #{@browser_type} cannot close : #{e.message}"
          raise TechnicalError, "sahi cannot close browser #{@browser_type}"
        ensure
          @@logger.an_event.debug "end close driver"
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # current_page_details
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : les informations contenu dans la page :
      #   - liste des liens
      #   - url de la page courante
      #   - referrer de la page courante
      #   - title de la page
      #   - cookies de la page
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.current_page_details contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def current_page_details
        @@logger.an_event.debug "begin current_page_details"
        begin
          JSON.parse(fetch("_sahi.current_page_details()"))
        rescue Exception => e
          @@logger.an_event.fatal e
          raise TechnicalError, "driver cannot get current page details"
        ensure
          @@logger.an_event.debug "begin current_page_details"
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # get_pids
      #-----------------------------------------------------------------------------------------------------------------
      # input : id_browser  : id du browser
      # output : les pids associés du process qui exécute l'id_browser
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de l'exécution de la fonction windows tasklist
      # FunctionalError :
      #     - id_browser n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      #TODO prendre en compte l'UTF8
      #TODO ne fonctionne que sur un os en francais
      def tasklist(id_browser)
        @@logger.an_event.debug "begin tasklist"
        @@logger.an_event.debug "tasklist /FO CSV /NH /V /FI \"WINDOWTITLE eq #{id_browser}*\""
        f = nil
        begin
          pids = nil
          f = IO.popen("tasklist /FO CSV /NH /V /FI \"WINDOWTITLE eq #{id_browser}*\"")
          f.readlines("\n").each { |l|
            @@logger.an_event.debug "row : #{l}"
            pid = CSV.parse_line(l)[1]
            raise if pid.nil? # c'est synonyme qu'en retour du tasklist, on a obtenu : "Information : aucune tâche en service ne correspond aux critères spécifiés."
            pids = pids.nil? ? [pid] : pids + [pid]
          }
        rescue Exception => e
          pids = nil
        ensure
          begin
            #sert à tuer tasklist si il est tj en vie
            Process.kill("KILL", f.pid)
          rescue
          end
        end
        pids
      end

      def get_pids(id_browser)
        @@logger.an_event.debug "begin get_pids"
        raise FunctionalError, "id_browser is not define" if id_browser.nil? or id_browser == ""

        pids=nil
        try_count = 0
        try_count_max = 3
        begin
          @@logger.an_event.debug "try_count_max #{try_count_max}, try_count #{try_count}, pids #{pids}"
          while try_count < try_count_max and pids.nil?
            pids = tasklist(id_browser)
            try_count += 1
            @@logger.an_event.debug "try_count_max #{try_count_max}, try_count #{try_count}, pids #{pids}"
          end
          raise TechnicalError, "max try join " if try_count == try_count_max and pids.nil?
        rescue Exception => e
          @@logger.an_event.debug e.message
          pids = nil
          raise TechnicalError, "driver cannot get pids of browser #{id_browser}}"
        ensure

        end
        @@logger.an_event.debug "end get_pids"
        pids
      end

      #-----------------------------------------------------------------------------------------------------------------
      # get_initialize
      #-----------------------------------------------------------------------------------------------------------------
      # input :
      #    id_browser_type : type du browser qu'il faut créer, présent dans les fichiers  lib/sahi.in.co/config/browser_type/win32/64, mac, linux.xml
      #    listening_port_sahi : le port d'écoute du proxy Sahi
      # output : un objet browser
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de l'exécution de la fonction windows tasklist
      # FunctionalError :
      #     - id_browser n'est pas défini ou absent
      #     - listening_port_sahi n'est pas défini ou absent
      #     - id_browser est absent des fichiers lib/sahi.in.co/config/browser_type/win32/64, mac, linux.xml
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def initialize(browser_type, listening_port_sahi)
        @@logger.an_event.debug "begin initialize driver"
        raise FunctionalError, "listening port sahi proxy is not defined" if listening_port_sahi.nil?
        raise FunctionalError, "browser type is not defined" if browser_type.nil?


        @proxy_host = "localhost" #browser_type est utilisé à la place.
        @proxy_port = listening_port_sahi #est utilisé par check_proxy(), pour le reste browser_type est utilisé
        @popup_name = nil
        @domain_name = nil
        @sahisid = nil
        @print_steps = false
        @browser_type = browser_type.gsub(" ", "_")
        begin
          browser_type_exist?
        rescue FunctionalError, TechnicalError => e
          @@logger.an_event.error e.message
          raise FunctionalError, "browser type of driver not exist in config sahi files"
        ensure
          @@logger.an_event.debug "driver #{self.inspect}"
          @@logger.an_event.debug "end initialize driver"
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # kill
      #-----------------------------------------------------------------------------------------------------------------
      # input :
      #    pids : la liste des pids associés au browser
      # output : none
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de l'exécution de la fonction windows taskkill
      # FunctionalError :
      #     - pids n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def kill(pids)
        @@logger.an_event.debug "begin kill browser"
        raise FunctionalError, "driver has no pid" if pids.nil? or pids==[nil]
        begin
          pids.each { |pid|
            #TODO faire la version linux
            cmd = "TASKKILL /PID #{pid} /T /F" #  force le kill de tous les sous process
            res = IO.popen(cmd).read #TODO prendre en compte l'UTF8

            @@logger.an_event.debug "kill command : #{cmd}"
            @@logger.an_event.debug "result : #{res}"
            raise "driver not kill" if res.include?("Erreur")
            begin
              #sert à tuer taskkill si il est tj en vie
              Process.kill("KILL", res.pid)
            rescue
            end
                                               #TODO identifier si le kill a fonctionné et remonté une erreur
            @@logger.an_event.debug "driver #{@browser_type} pid #{pid} is killed"
          }
        rescue Exception => e
          @@logger.an_event.fatal e
          raise TechnicalError, "driver  #{@browser_type} cannot be killed"
        ensure
          @@logger.an_event.debug "end kill browser"
        end
      end


      def navigate_to(url, force_reload=false)
        @@logger.an_event.debug "begin navigate_to"
        raise FunctionalError, "url is not define" if url.nil?
        begin
          super(url, true)
          if !/Sahi - [0-9]{3} Error/.match(title).nil?
            # une error http serveur captée par Sahi est remontée dans le titre de la window.
            # les erreurs http client(404 par exemple) ne sont pas captées par Sahi.
            # Dans la cas du 404, cette erreur est personnalisable donc impossible d'avoir un comportement
            # standardisé sur lequel s'appuyer dessus pour identifier qu'une ressource n'a pas été trouvée
            # remarque : la ressoure devrait être théoriquement présente car issue d'un parse de la page précédente.
            # Si cela arrivait alors cela serait synonyme de broken link => action sur le site.
            case title[/[0-9]{3}/]
              when "504", "524", "598", "599"
                raise TimeoutError, "error http : #{title[/[0-9]{3}/]}"
              else
                raise Exception, "error http : #{title[/[0-9]{3}/]}"
            end
          end
        rescue Exception => e
          @@logger.an_event.fatal e
          raise TechnicalError, "driver cannot navigate to #{url}"
        ensure
          @@logger.an_event.debug "begin navigate_to"
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # open
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de demande de lancement du browser auprès de Sahi.
      # FunctionalError :
      #     - browser_type n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def open
        @@logger.an_event.debug "begin open driver"
        raise FunctionalError, "browser type is not define" if @browser_type.nil?

        try_count = 0
        max_try_count = 3
        begin
          check_proxy
        rescue Exception => e
          try_count+=1
          @@logger.an_event.debug "#{e.message}, try #{try_count}"
          sleep(1)
          retry if try_count < max_try_count
          raise TechnicalError, e.message if try_count >= max_try_count
        end

        begin
          @sahisid = Time.now.to_f
          start_url = "http://sahi.example.com/_s_/dyn/Driver_initialized"
          exec_command("launchPreconfiguredBrowser", {"browserType" => @browser_type, "startUrl" => start_url})
          i = 0
          while (i < 500)
            i+=1
            break if is_ready?
            sleep(0.1)
          end
          @@logger.an_event.debug "open browser #{@browser_type}"

        rescue RuntimeError => e
          @@logger.an_event.fatal e.message
          raise TechnicalError, "driver #{@browser_type} cannot start"
        ensure
          @@logger.an_event.debug "end open driver"
        end
      end

      def open_old
        @@logger.an_event.debug "begin open driver"
        raise FunctionalError, "browser type is not define" if @browser_type.nil?
        begin
          check_proxy
          @sahisid = Time.now.to_f
          start_url = "http://sahi.example.com/_s_/dyn/Driver_initialized"
          exec_command("launchPreconfiguredBrowser", {"browserType" => @browser_type, "startUrl" => start_url})
          i = 0
          while (i < 500)
            i+=1
            break if is_ready?
            sleep(0.1)
          end
          @@logger.an_event.debug "open browser #{@browser_type}"

        rescue RuntimeError => e
          @@logger.an_event.fatal e.message
          raise TechnicalError, "driver #{@browser_type} cannot start"
        ensure
          @@logger.an_event.debug "end open driver"
        end
      end

      #recupere le referrer de la page affichée dans le navigateur
      #def referrer
      #  fetch("_sahi.referrer()")
      #end

      #-----------------------------------------------------------------------------------------------------------------
      # set_title
      #-----------------------------------------------------------------------------------------------------------------
      # input : title de la fenetre du browser
      # output : title de la fenetre mis a jour
      # exception :
      # TechnicalError :
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.set_title contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      # FunctionalError :
      #     - title n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def set_title(title)
        @@logger.an_event.debug "begin set_title"
        raise FunctionalError, "title is not define" if title.nil?
        title_update = ""
        begin
          title_update = fetch("_sahi.set_title(\"#{title}\")")
          @@logger.an_event.debug "title update : #{title_update}, title : #{title}"
        rescue Exception => e
          @@logger.an_event.fatal e.message
          raise TechnicalError, "driver not set title #{title}"
        ensure
          @@logger.an_event.debug "end set_title"
          title_update
        end
      end


    end
  end
end