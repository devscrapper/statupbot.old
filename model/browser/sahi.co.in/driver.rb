module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      class DriverSahiException < StandardError
        INSTANCE_FF_ALREADY_RUNNING = "an instance of firefox is already running"
        DRIVER_NOT_STARTED = "driver sahi cannot start #{@browser_type}"
        DRIVER_NOT_CLOSE = "driver sahi cannot stop #{@browser_type}"
        DRIVER_NOT_NAVIGATE = "driver cannot navigate to "
        DRIVER_NOT_SET_TITLE = "driver not set title"
      end

      attr_reader :pids # pid browser

      def browser_type
        @browser_type
      end

      def initialize(browser_type, listening_port_sahi)
        #TODO controler que le browset_type existe dans le fichier browser_type dans lib/sahicoin/config/browser_type.xml
        @proxy_host = "localhost" #browser_type est utilisé à la place.
        @proxy_port = listening_port_sahi #est utilisé par check_proxy(), pour le reste browser_type est utilisé
        @browser_type = browser_type
        @popup_name = nil
        @domain_name = nil
        @sahisid = nil
        @print_steps = false
      end

      # closes the browser
      def close
        begin
          exec_command("kill");
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.warn "driver #{@browser_type} is not close"
          raise DriverSahiException::DRIVER_NOT_CLOSE
        end
      end

      def get_pid(browser_id)
        f = IO.popen("tasklist /FO CSV /NH /V /FI \"WINDOWTITLE eq #{browser_id}*\"")
        f.readlines("\n").each { |l|
          CSV.parse(l) do |row|
            @pids = @pids.nil? ? [row[1]] : @pids + row[1]
          end
        }
        @@logger.an_event.error "driver #{@browser_type} pid not found #{@pids}" if @pids.nil?
        @@logger.an_event.info "driver #{@browser_type} pid #{@pids} is opened" unless @pids.nil?
      end

      def kill
        raise DriverSahiException::DRIVER_NOT_CLOSE if @pids.nil?
        begin
          @pids.each { |pid|
            f = IO.popen("TASKKILL /PID #{pid} /T /F")
            @@logger.an_event.info f.read
            @@logger.an_event.info "browser #{@browser_type} pid #{pid} is killed"
          }
        rescue Exception => e
          @@logger.an_event.debug e
          @@logger.an_event.error "driver  #{@browser_type} cannot be killed"
          raise DriverSahiException::DRIVER_NOT_CLOSE
        end
      end

      #opens the browser
      def open(browser_id)
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
          @@logger.an_event.debug "open preconfigure browser #{@browser_type}"
        rescue RuntimeError => e
          @@logger.an_event.debug e
          @@logger.an_event.error e.message
          raise DriverSahiException::DRIVER_NOT_STARTED
        end
        set_title(browser_id)
        get_pid(browser_id)
      end

      #def open_start_page(window_parameters)
      #  # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
      #  # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
      #  # pour IE
      #  # fetch("_sahi.open_start_page(\"https://sahi.example.com/_s_/dyn/Driver_initialized\",\"#{window_parameters}\")")
      #  # pour CHrome & FF
      #  fetch("_sahi.open_start_page(\"https://localhost\",\"#{window_parameters}\")")
      ## pour IE
      # # @popup_name = "defaultSahiPopup"    etait utiliser quand on ouvrait une nouvelle window pour lzncer https://localhost, supprimer pour r"duire le nombre de fentre à l'ecran car les ressources du PC explose"
      #  # pour Chrome Firefox
      #  @popup_name = "defaultSahiPopup"
      #  @@logger.an_event.info "open start page with parameters : #{window_parameters}"
      #end

      #recupere le referrer de la page affichée dans le navigateur
      def referrer
        fetch("_sahi.referrer()")
      end

      #recupere l'url de la page affichée dans le navigateur
      def current_url
        fetch("_sahi.current_url()")
      end

      def navigate_to(url, force_reload=false)
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
          @@logger.an_event.debug e
          @@logger.an_event.error e.message
          raise DriverSahiException::DRIVER_NOT_NAVIGATE

        end
      end

      def set_title(title)
        res = fetch("_sahi.set_title(\"#{title}\")")
        raise DriverSahiException::DRIVER_NOT_SET_TITLE unless res.empty?
      end

    end
  end
end