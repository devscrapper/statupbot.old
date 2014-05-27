
module Browsers
  module SahiCoIn
    class Driver < Sahi::Browser
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      include Errors

      #----------------------------------------------------------------------------------------------------------------
      # message exception
      #----------------------------------------------------------------------------------------------------------------
      class DriverError < Error

      end
      ARGUMENT_UNDEFINE = 200 # à remonter en code retour de statupbot
      DRIVER_NOT_CREATE = 201 # à remonter en code retour de statupbot
      SAHI_PROXY_NOT_FOUND = 202 # à remonter en code retour de statupbot
      BROWSER_TYPE_NOT_EXIST = 203 # à remonter en code retour de statupbot
      OPEN_DRIVER_FAILED = 204 # à remonter en code retour de statupbot
      CLOSE_DRIVER_TIMEOUT = 205 # à remonter en code retour de statupbot
      CLOSE_DRIVER_FAILED = 206 # à remonter en code retour de statupbot
      CATCH_PROPERTIES_PAGE_FAILED = 207 # à remonter en code retour de statupbot
      DRIVER_SEARCH_FAILED = 208 # à remonter en code retour de statupbot
      BROWSER_TYPE_FILE_NOT_FOUND = 209 # à remonter en code retour de statupbot
      DRIVER_NOT_ACCESS_URL = 210
      TEXTBOX_SEARCH_NOT_FOUND = 211
      SUBMIT_SEARCH_NOT_FOUND = 212

      #SET_TITLE_FAILED = "title not set"

      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # constant
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # attribut
      #----------------------------------------------------------------------------------------------------------------

      attr_reader :browser_type

      #----------------------------------------------------------------------------------------------------------------
      # class methods
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------

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
          @@logger.an_event.error "driver #{@browser_type} close timeout : #{e.message}"
          raise DriverError.new(CLOSE_DRIVER_TIMEOUT), "driver #{@browser_type} close timeout"
        rescue Exception => e
          @@logger.an_event.error "driver #{@browser_type} cannot close : #{e.message}"
          raise DriverError.new(CLOSE_DRIVER_FAILED), "driver #{@browser_type} cannot close"
        ensure
          @@logger.an_event.debug "END Driver.close"
        end
      end

      #-----------------------------------------------------------------------------------------------------------------
      # get_details_current_page
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
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.get_details_current_page contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def get_details_current_page
        @@logger.an_event.debug "END Driver.get_details_current_page"
        details = nil
        begin
          raise DriverError.new(DRIVER_NOT_ACCESS_URL), "driver not access url" if div("error_connect").exists?

          details = JSON.parse(fetch("_sahi.current_page_details()"))
          @@logger.an_event.debug "details current page #{details}"
          #TODO à supprimer si aucun ecart n'est constaté entre count_links et details["links"]
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
          #TODO à supprimer
          @@logger.an_event.debug "driver catch details current page"
        rescue Exception => e
          @@logger.an_event.fatal "driver cannot catch details current page : #{e.message}"
          raise DriverError.new(CATCH_PROPERTIES_PAGE_FAILED, e), "driver cannot catch details current page"
        else
          @@logger.an_event.debug "details #{details.nil? ? "empty" : details}"
          return details
        ensure
          @@logger.an_event.debug "END Driver.get_details_current_page"
        end
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


        raise DriverError.new(ARGUMENT_UNDEFINE), "browser_type undefine" if browser_type.nil? or browser_type == ""
        raise DriverError.new(ARGUMENT_UNDEFINE), "listening_port undefine" if listening_port_sahi.nil? or listening_port_sahi.nil? == ""

        @proxy_host = "localhost" #browser_type est utilisé à la place.
        @proxy_port = listening_port_sahi #est utilisé par check_proxy(), pour le reste browser_type est utilisé
        @popup_name = nil
        @domain_name = nil
        @sahisid = nil
        @print_steps = false
        @browser_type = browser_type.gsub(" ", "_")

        #-----------------------------------------------------------------------------------------------------------------
        #  check si browser type est defini dans les fichiers *.xml
        #-----------------------------------------------------------------------------------------------------------------
        require 'os'
        browser_type_file = ""
        if OS.windows?
          browser_type_file = "win32.xml" if ENV["ProgramFiles(x86)"].nil?
          browser_type_file = "win64.xml" unless ENV["ProgramFiles(x86)"].nil?
        end
        browser_type_file = "mac.xml" if OS.mac?
        browser_type_file = "linux" if OS.linux?

        begin
          require 'rexml/document'
          include REXML

          exist = false
          path_name = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'sahi.in.co', 'config', "browser_types", browser_type_file)).realpath
          if File.exist?(path_name)
            browser_type_file = File.new(path_name)
            exist ||= REXML::XPath.match(REXML::Document.new(browser_type_file), "browserTypes/browserType/name").map { |e| e.to_a[0] }.include?(@browser_type)
            @@logger.an_event.debug "browser type #{@browser_type} exist ? #{exist}"
          else
            raise DriverError.new(BROWSER_TYPE_FILE_NOT_FOUND), "browser type file #{path_name} not exist"
          end

          raise DriverError.new(BROWSER_TYPE_NOT_EXIST), "browser type #{@browser_type} not exist" unless exist
          @@logger.an_event.debug "driver #{@browser_type} create"
        rescue Exception => e
          @@logger.an_event.fatal "driver #{@browser_type} not create : #{e.message}"
          raise DriverError.new(DRIVER_NOT_CREATE, e), "driver #{@browser_type} not create"
        ensure
          @@logger.an_event.debug "END Driver.initialize"
        end

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
            @@logger.an_event.fatal "driver #{@browser_type} not connect to proxy : #{e.message}"
            raise DriverError.new(SAHI_PROXY_NOT_FOUND), "driver #{@browser_type} not connect proxy"
          end
        end

        @@logger.an_event.debug "driver #{@browser_type} connect to proxy"

        begin
          @sahisid = Time.now.to_f
          start_url = "http://sahi.example.com/_s_/dyn/Driver_initialized"
          param = {"browserType" => @browser_type, "startUrl" => start_url}
          @@logger.an_event.debug "param #{param}"
          exec_command("launchPreconfiguredBrowser", param)
          i = 0
          while (i < 500 and !is_ready?)
            i+=1
           # break if
            sleep(0.1)
          end

          @@logger.an_event.debug "driver #{@browser_type} open" if is_ready?
          raise "driver #{@browser_type} not ready" unless is_ready?

        rescue Exception => e
          @@logger.an_event.fatal "driver #{@browser_type} not open : #{e.message}"
          raise DriverError.new(OPEN_DRIVER_FAILED), "driver #{@browser_type} not open"
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
      #def set_title(title)
      #  @@logger.an_event.debug "BEGIN Driver.set_title"
      #  @@logger.an_event.debug "title : #{title}"
      #  raise StandardError, PARAM_NOT_DEFINE if title.nil?
      #  title_update = ""
      #  begin
      #    title_update = fetch("_sahi.set_title(\"#{title}\")")
      #    @@logger.an_event.debug "title update : #{title_update}, title : #{title}"
      #  rescue Exception => e
      #    @@logger.an_event.debug e.message
      #    @@logger.an_event.fatal "driver not set title #{title}"
      #    raise StandardError, SET_TITLE_FAILED
      #  ensure
      #    @@logger.an_event.debug "END Driver.set_title"
      #    title_update
      #  end
      #end

      #-----------------------------------------------------------------------------------------------------------------
      # search
      #-----------------------------------------------------------------------------------------------------------------
      # input : les mots cle que on veut rechercher, l'objet moteur de recherche
      # output : RAS
      # exception :
      # StandardError :
      #     - une erreur est survenue lors de l'exécution de la fonction Sahi.prototype.set_title contenu
      #     dans le fichier lib/sahi.in.co/htdocs/spr/extensions.js
      # StandardError :
      #     - title n'est pas défini ou absent
      #-----------------------------------------------------------------------------------------------------------------
      #
      #-----------------------------------------------------------------------------------------------------------------
      def search(keywords, engine_search)
        @@logger.an_event.debug "BEGIN Driver.search"
        @@logger.an_event.debug "keywords #{keywords}"
        @@logger.an_event.debug "engine_search #{engine_search.class}"

        raise DriverError.new(ARGUMENT_UNDEFINE), "keywords undefine" if keywords.nil? or keywords==""
        raise DriverError.new(ARGUMENT_UNDEFINE), "engine_search undefine" if engine_search.nil?

        raise TEXTBOX_SEARCH_NOT_FOUND unless textbox(engine_search.id_search).exists?
        raise SUBMIT_SEARCH_NOT_FOUND unless submit(engine_search.label_search_button).exists?

        begin
          textbox(engine_search.id_search).value = !keywords.is_a?(String) ? keywords.to_s : keywords
          @@logger.an_event.debug "driver #{@browser_type} enter keywords #{keywords} in search form #{engine_search.class}"

          submit(engine_search.label_search_button).click
          @@logger.an_event.debug "driver #{@browser_type} submit search form #{engine_search.class}"
        rescue Exception => e
          @@logger.an_event.error "driver #{@browser_type} cannot submit search form #{engine_search.class}  : #{e.message}"
          raise DriverError.new(DRIVER_SEARCH_FAILED), "driver #{@browser_type} cannot submit search form #{engine_search.class}"
        ensure
          @@logger.an_event.debug "END Driver.search"
        end

      end
    end
  end
end