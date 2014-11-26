require_relative '../../lib/os'
require_relative '../../lib/error'
require 'rexml/document'

module Browsers
  class Driver < Sahi::Browser
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include REXML
    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------
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
      #TODO etudier la suppression de cette méthode au profit de celle fournie par Sahi ...

      begin
        exec_command("kill");

      rescue Timeout::Error => e
        @@logger.an_event.error e.message
        raise Error.new(CLOSE_DRIVER_TIMEOUT, :values => {:browser_type => "page"}, :error => e)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(CLOSE_DRIVER_FAILED, :values => {:browser_type => "page"}, :error => e)

      else
        @@logger.an_event.debug "driver #{@browser_type} close"

      ensure

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
    # with_links = true  |false : si true alors on recupere les links. est utilisé pour le surf sur le website et le
    # surf sur advertiser. le slinks ne sont pas recuperés pour le search
    # RAF  : doit on recuperer les liks pour le start_page, le referer ?
    #-----------------------------------------------------------------------------------------------------------------
    def get_details_current_page(url, with_links = true)

      details = nil
      count = 3
      i = 0
      begin
        results = fetch("_sahi.current_page_details(#{with_links})")
        @@logger.an_event.debug "results current page <#{results}>"
        raise "_sahi.current_page_details() not return details page #{url}" if results == "" or results.nil?

        details = JSON.parse(results)
        @@logger.an_event.debug "details current page #{details}"



        details["links"].map! { |link|
            link["element"] = link(link["href"])
            link
        } if with_links


        @@logger.an_event.debug "driver catch details current page"

      rescue Exception => e
        if i < count
          @@logger.an_event.warn e.message
          i += 1
          retry
        else
          @@logger.an_event.fatal e.message
          raise Error.new(CATCH_PROPERTIES_PAGE_FAILED, :values => {:url => url}, :error => e)
        end

      else
        @@logger.an_event.debug "details #{details.nil? ? "empty" : details}"
        return details

      ensure

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
      @@logger.an_event.debug "browser_type #{browser_type}"
      @@logger.an_event.debug "listening_port_sahi #{listening_port_sahi}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => browser_type}) if browser_type.nil? or browser_type == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => listening_port_sahi}) if listening_port_sahi.nil? or listening_port_sahi.nil? == ""

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
        browser_type_file = ""
        if OS.windows?
          browser_type_file = "win32.xml" if ENV["ProgramFiles(x86)"].nil?
          browser_type_file = "win64.xml" unless ENV["ProgramFiles(x86)"].nil?
        end
        browser_type_file = "mac.xml" if OS.mac?
        browser_type_file = "linux" if OS.linux?

        exist = false
        path_name = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sahi.in.co', 'config', "browser_types", browser_type_file)).realpath
        if File.exist?(path_name)
          browser_type_file = File.new(path_name)
          exist ||= REXML::XPath.match(REXML::Document.new(browser_type_file), "browserTypes/browserType/name").map { |e| e.to_a[0] }.include?(@browser_type)
          @@logger.an_event.debug "browser type #{@browser_type} exist ? #{exist}"
        else
          raise Error.new(BROWSER_TYPE_FILE_NOT_FOUND)
        end

        raise Error.new(BROWSER_TYPE_NOT_EXIST, :values => {:browser_type => @browser_type}) unless exist


      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(DRIVER_NOT_CREATE, :error => e)

      else
        @@logger.an_event.debug "driver #{@browser_type} create"
      ensure

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
      try_count = 0
      max_try_count = 3
      begin
        check_proxy
      rescue Exception => e
        try_count+=1
        @@logger.an_event.debug "#{e.message}, try #{try_count}"
        sleep(3)
        retry if try_count < max_try_count
        if try_count >= max_try_count
          @@logger.an_event.fatal e.message
          raise Error.new(SAHI_PROXY_NOT_FOUND, :error => e)
        end
      end

      @@logger.an_event.debug "driver #{@browser_type} find proxy sahi"

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

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(OPEN_DRIVER_FAILED, :error => e)

      else
        @@logger.an_event.debug "driver #{@browser_type} open" if is_ready?
        raise Error.new(OPEN_DRIVER_FAILED) unless is_ready?

      ensure

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
      @@logger.an_event.debug "keywords #{keywords}"
      @@logger.an_event.debug "engine_search #{engine_search.class}"


      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => keywords}) if keywords.nil? or keywords==""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => engine_search}) if engine_search.nil?

        @@logger.an_event.debug "engine_search.id_search #{engine_search.id_search}"
        @@logger.an_event.debug "engine_search.label_search_button #{engine_search.label_search_button}"

        raise Error.new(TEXTBOX_SEARCH_NOT_FOUND) unless engine_search.input(self).exists?
        raise Error.new(SUBMIT_SEARCH_NOT_FOUND) unless engine_search.submit(self).exists?

        engine_search.input(self).value  = !keywords.is_a?(String) ? keywords.to_s : keywords

        @@logger.an_event.debug "driver #{@browser_type} enter keywords #{keywords} in search form #{engine_search.class}"

        engine_search.submit(self).click


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(DRIVER_SEARCH_FAILED)
      else
        @@logger.an_event.debug "driver #{@browser_type} submit search form #{engine_search.class}"
      ensure

      end

    end
  end
end
