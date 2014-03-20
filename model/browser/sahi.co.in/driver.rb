module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      class DriverSahiException < StandardError

        DRIVER_NOT_STARTED = "driver sahi cannot start #{@browser_type}"
        DRIVER_NOT_CLOSE = "driver sahi cannot stop #{@browser_type}"
        DRIVER_NOT_NAVIGATE = "driver cannot navigate to "
        DRIVER_NOT_SET_TITLE = "driver not set title"
        DRIVER_NOT_KILL = "driver not kill"
        CANNOT_GET_DETAILS_PAGE = "cannot get details page"
      end

      # attr_reader :pids # pid browser

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
          @@logger.an_event.warn "driver #{@browser_type} is not close"
          @@logger.an_event.debug e
          raise DriverSahiException::DRIVER_NOT_CLOSE
        end
      end


      def kill(pids)
        raise DriverSahiException::DRIVER_NOT_CLOSE if pids.nil?
        begin
          pids.each { |pid|
            #TODO faire la version linux
            cmd = "TASKKILL /PID #{pid} /T" # /F")  force le kill de tous les sous process
            res = IO.popen(cmd).read #TODO prendre en compte l'UTF8

            @@logger.an_event.debug "kill command : #{cmd}"
            @@logger.an_event.debug "result : #{res}"
            raise DRIVER_NOT_KILL if res.include?("Erreur")
                                            #TODO identifier si le kill a fonctionné et remonté une erreur
            @@logger.an_event.info "driver #{@browser_type} pid #{pid} is killed"
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
        begin
          set_title(browser_id)
        rescue Exception => e
          @@logger.an_event.error "id browser not found in title" unless t.include?(browser_id)
        end

      end

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

      def current_page_details
        begin
          JSON.parse(fetch("_sahi.current_page_details()"))
        rescue Exception => e
          @@logger.an_event.error e.message
          @@logger.an_event.debug e
          raise DriverSahiException::CANNOT_GET_DETAILS_PAGE
        end
      end

      def set_title(title)
        title_update = ""
        i = 0
        while title_update != title and i < 5
          title_update = fetch("_sahi.set_title(\"#{title}\")")
          @@logger.an_event.info "title update : #{title_update}, title : #{title}"
          i+= 1
        end
        @@logger.an_event.error "title update != title " if  title_update != title
        raise DriverSahiException::DRIVER_NOT_SET_TITLE if  title_update != title
      end

    end
  end
end