module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      class DriverSahiException < StandardError
         DRIVER_NOT_STARTED = "driver sahi cannot start"
         INSTANCE_FF_ALREADY_RUNNING = "an instance of firefox is already running"
      end

      def browser_type
        @browser_type
      end
      def initialize(browser_type)
        @proxy_host = "localhost" #browser_type est utilisé à la place.
        @proxy_port = 9999        #browser_type est utilisé à la place.
        @browser_type = browser_type
        @popup_name = nil
        @domain_name = nil
        @sahisid = nil
        @print_steps = false
      end

      #opens the browser
      def open
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
        rescue RuntimeError => e
          @@logger.an_event.error e.message
          raise  DriverSahiException::DRIVER_NOT_STARTED
        end
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
          if @browser_type == "firefox" and
              e.message == "error:Playback session not started. Verify that proxy is set on the browser."
             raise INSTANCE_FF_ALREADY_RUNNING
          end
          raise e

        end
      end


    end
  end
end