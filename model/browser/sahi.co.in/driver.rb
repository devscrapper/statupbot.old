module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      #----------------------------------------------------------------------------------------------------------------
      # message exception
      #----------------------------------------------------------------------------------------------------------------
      CATCH_PROPERTIES_PAGE_FAILED = "properties page not catch"
      BROWSER_TYPE_NOT_EXIST = "browser type not exist"
      CREATE_DRIVER_FAILED = "driver not create"
      SAHI_PROXY_NOT_FOUND = "driver not found proxy"
      OPEN_DRIVER_FAILED = "driver not open"
      CLOSE_DRIVER_TIMEOUT = "driver close timeout"
      SET_TITLE_FAILED = "title not set"
      CLOSE_DRIVER_FAILED = "driver not close"
      CANNOT_SEARCH = "driver cannot search"
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # constant
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # attribut
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # class methods
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------

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
      #   StandardError : prb d'accès technique aux fichiers.
      #-----------------------------------------------------------------------------------------------------------------
      # ATTENTION : controle que le browser type est présent dans au moins fichier, pas dans celui utilisé pour l'OS COURANT
      #-----------------------------------------------------------------------------------------------------------------
      def browser_type_exist?
        @@logger.an_event.debug "BEGIN Driver.browser_type_exist?"
        exist = false
        require 'rexml/document'
        include REXML
        #TODO utiliser os.rb pour determiner le fichier browser_type.xml
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
          @@logger.an_event.debug "browser_type #{@browser_type} found in win32/64, mac, linux files" if exist
          @@logger.an_event.error "browser_type #{@browser_type} not found in win32/64, mac, linux files" unless exist
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.fatal "access to browser type files failed"
          raise e
        ensure
          @@logger.an_event.debug "END Driver.browser_type_exist?"
        end
        exist
      end

      #-----------------------------------------------------------------------------------------------------------------
      # close
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # StandardError :
      #     - sahi ne peut arreter le navigateur car plusieurs occurences du navigateur s'exécute
      #     - tout autre erreur
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def close
        @@logger.an_event.debug "BEGIN Driver.close"
        begin
          exec_command("kill");
          @@logger.an_event.debug "driver #{@browser_type} close"
        rescue Timeout::Error => e
          @@logger.an_event.debug e.message
          @@logger.an_event.error "driver #{@browser_type} close timeout"
          raise StandardError, CLOSE_DRIVER_TIMEOUT
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.error "driver #{@browser_type} cannot close"
          raise StandardError, CLOSE_DRIVER_FAILED
        ensure
          @@logger.an_event.debug "END Driver.close"
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
      # StandardError :
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.current_page_details contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def current_page_details
        @@logger.an_event.debug "END Driver.current_page_details"
        details = nil
        begin
          details = JSON.parse(fetch("_sahi.current_page_details()"))
          @@logger.an_event.debug "details current page #{details}"

          count_links = details["links"].size
          @@logger.an_event.debug "details count links #{count_links} before cleaning"
          details["links"].map! { |link|
            if ["", "_top", "_self", "_parent"].include?(link["target"])
              link["element"] = link(link["href"])
              link
            else
              nil
            end
          }.compact
          @@logger.an_event.debug "details count links #{details["links"].size} after cleaning"
          @@logger.an_event.warn "some (#{count_links - details["links"].size}) links were cleaned" if  count_links - details["links"].size > 0
          @@logger.an_event.debug "driver catch current page details"
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.FATAL "driver cannot catch current page details"
          raise StandardError, CATCH_PROPERTIES_PAGE_FAILED
        ensure
          @@logger.an_event.debug "details #{details}"
          @@logger.an_event.debug "END Driver.current_page_details"

        end
        details
      end


      #-----------------------------------------------------------------------------------------------------------------
      # initialize
      #-----------------------------------------------------------------------------------------------------------------
      # input :
      #    id_browser_type : type du browser qu'il faut créer, présent dans les fichiers  lib/sahi.in.co/config/browser_type/win32/64, mac, linux.xml
      #    listening_port_sahi : le port d'écoute du proxy Sahi
      # output : un objet browser
      # exception :
      # StandardError :
      #     - id_browser n'est pas défini ou absent
      #     - listening_port_sahi n'est pas défini ou absent
      #     - id_browser est absent des fichiers lib/sahi.in.co/config/browser_type/win32/64, mac, linux.xml
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def initialize(browser_type, listening_port_sahi)
        @@logger.an_event.debug "BEGIN Driver.initialize"

        @@logger.an_event.debug "browser_type #{browser_type}"
        @@logger.an_event.debug "listening_port_sahi #{listening_port_sahi}"

        raise StandardError, PARAM_NOT_DEFINE if listening_port_sahi.nil? or browser_type.nil?


        @proxy_host = "localhost" #browser_type est utilisé à la place.
        @proxy_port = listening_port_sahi #est utilisé par check_proxy(), pour le reste browser_type est utilisé
        @popup_name = nil
        @domain_name = nil
        @sahisid = nil
        @print_steps = false
        @browser_type = browser_type.gsub(" ", "_")
        begin
          exist = browser_type_exist?
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.error "cannot create driver for browser type #{@browser_type}"
          raise StandardError, CREATE_DRIVER_FAILED
        ensure
          @@logger.an_event.debug "END Driver.initialize"
        end

        raise StandardError, BROWSER_TYPE_NOT_EXIST unless exist
      end


      #-----------------------------------------------------------------------------------------------------------------
      # open
      #-----------------------------------------------------------------------------------------------------------------
      # input : none
      # output : none
      # exception :
      # StandardError :
      #     - une erreur est survenue lors de demande de lancement du browser auprès de Sahi.
      # StandardError :
      #     - browser_type n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def open
        @@logger.an_event.debug "BEGIN Driver.open"

        try_count = 0
        max_try_count = 3
        begin
          check_proxy
        rescue Exception => e
          try_count+=1
          @@logger.an_event.debug "#{e.message}, try #{try_count}"
          sleep(1)
          retry if try_count < max_try_count
          if try_count >= max_try_count
            @@logger.an_event.debug e.message
            @@logger.an_event.fatal "driver #{@browser_type} not found proxy"
            raise StandardError, SAHI_PROXY_NOT_FOUND
          end
        end

        @@logger.an_event.debug "proxy found
"
        begin
          @sahisid = Time.now.to_f
          start_url = "http://sahi.example.com/_s_/dyn/Driver_initialized"
          param = {"browserType" => @browser_type, "startUrl" => start_url}
          @@logger.an_event.debug "param #{param}"
          exec_command("launchPreconfiguredBrowser", param)
          i = 0
          while (i < 500)
            i+=1
            break if is_ready?
            sleep(0.1)
          end
          @@logger.an_event.debug "open driver #{@browser_type}"

        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.fatal "driver #{@browser_type} not start"
          raise StandardError, OPEN_DRIVER_FAILED
        ensure
          @@logger.an_event.debug "END Driver.open"
        end
      end


      #-----------------------------------------------------------------------------------------------------------------
      # set_title
      #-----------------------------------------------------------------------------------------------------------------
      # input : title de la fenetre du browser
      # output : title de la fenetre mis a jour
      # exception :
      # StandardError :
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.set_title contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      # StandardError :
      #     - title n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def set_title(title)
        @@logger.an_event.debug "BEGIN Driver.set_title"
        @@logger.an_event.debug "title : #{title}"
        raise StandardError, PARAM_NOT_DEFINE if title.nil?
        title_update = ""
        begin
          title_update = fetch("_sahi.set_title(\"#{title}\")")
          @@logger.an_event.debug "title update : #{title_update}, title : #{title}"
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.fatal "driver not set title #{title}"
          raise StandardError, SET_TITLE_FAILED
        ensure
          @@logger.an_event.debug "END Driver.set_title"
          title_update
        end
      end

      def search(keywords, engine_search)
        begin
          textbox(engine_search.id_search).value = keywords
          @@logger.an_event.debug "driver enter keywords #{keywords} in search forma #{engine_search.class}"

          submit(engine_search.label_search_button).click
          @@logger.an_event.debug "driver submit search form #{engine_search.class}"
        rescue Exception => e
          @@logger.an_event.debug e.message
          @@logger.an_event.error "driver cannot submit search form #{engine_search.class}"
          @@logger.an_event.debug "END Driver.search"
          raise StandardError, CANNOT_SEARCH
        end

      end
    end
  end
end