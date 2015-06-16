require_relative '../../lib/os'
require_relative '../../lib/error'
require 'rexml/document'
require 'sahi'


#----------------------------------------------------------------------------------------------------------------
# enrichissment, surcharge pour personnaliser ou corriger le gem Sahi standard
#----------------------------------------------------------------------------------------------------------------

module Sahi
  class Browser
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
    DRIVER_NOT_CATCH_LINKS = 213

    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil
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

    def back
      fetch("_sahi.go_back()")
    end

    def body
      fetch("window.document.body.innerHTML")
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

    def current_url
      fetch("window.location.href")
    end


    def display_start_page (url, window_parameters)
      fetch("_sahi.display_start_page(\"#{url}\", \"#{window_parameters}\")")
    end

    # evaluates a javascript expression on the browser and fetches its value
    def fetch(expression)
      key = "___lastValue___" + Time.now.getutc.to_s;
      #remplacement de cette ligne
      # execute_step("_sahi.setServerVarPlain('"+key+"', " + expression + ")")
      # par celle ci depuis la version 6.0.1 de SAHI
      execute_step("_sahi.setServerVarForFetchPlain('"+key+"', " + expression + ")")
      return check_nil(exec_command("getVariable", {"key" => key}))
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
      @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
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

    def links
      fetch("_sahi.links()")
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


  end
  class ElementStub
    # returns count of elements similar to this element
    def count_similar
      # return Integer(@browser.fetch("_sahi._count(\"_#{@type}\", #{concat_identifiers(@identifiers).join(", ")})"))
      @browser.fetch("_sahi._count(\"_#{@type}\", #{concat_identifiers(@identifiers).join(", ")})").to_i
    end


    def setAttribute(attr=nil, value="")
      if attr
        if attr.include? "."
          return @browser.fetch("#{self.to_s()}.#{attr}")
        else
          return @browser.fetch("_sahi.setAttribute(#{self.to_s()}, #{Utils.quoted(attr)}, #{Utils.quoted(value)})")
        end
      else
        return @browser.fetch("#{self.to_s()}")
      end
    end
  end
end
