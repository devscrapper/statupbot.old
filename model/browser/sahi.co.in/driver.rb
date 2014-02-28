module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      class DriverSahiException < StandardError
        DRIVER_NOT_STARTED = "driver sahi cannot start"
        INSTANCE_FF_ALREADY_RUNNING = "an instance of firefox is already running"
        BROWSER_NOT_STARTED = "browser #{@browser_type} cannot start"
      end

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
        exec_command("kill");
      end

      #opens the browser
      def open
        begin
          check_proxy
          @sahisid = Time.now.to_f
          #utilise https pour ne pas passer de referrer
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
          raise DriverSahiException::BROWSER_NOT_STARTED
        end
      end

      def open_start_page(window_parameters)
        # pour maitriser le referer on passe par un site local en https qui permet de ne pas affecter le referer
        # incontournable sinon Google analityc enregistre la page de lancement de Sahi initializer
        fetch("_sahi.open_start_page(\"https://localhost/\",\"#{window_parameters}\")")
       # @popup_name = "defaultSahiPopup"    etait utiliser quand on ouvrait une nouvelle window pour lzncer https://localhost, supprimer pour r"duire le nombre de fentre à l'ecran car les ressources du PC explose"
        @@logger.an_event.info "open start page with parameters : #{window_parameters}"
      end

      #recupere l'url de la page affichée dans le navigateur
      def current_url
        url = fetch("_sahi.current_url()")
        @@logger.an_event.debug "current url #{url}"
        url
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
          @@logger.an_event.debug "origin informations : #{fetch("_sahi.info()")}"
        rescue Exception => e
          @@logger.an_event.error e.message
          raise e

        end
      end


    end
  end
end