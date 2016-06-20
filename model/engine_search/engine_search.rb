require_relative '../../lib/error'


module EngineSearches
  class EngineSearch
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    ARGUMENT_UNDEFINE = 900
    ENGINE_UNKNOWN = 901
    ENGINE_NOT_FOUND_LANDING_LINK = 902
    ENGINE_NOT_FOUND_NEXT_LINK = 903
    ENGINE_NOT_CREATE = 904
    TEXTBOX_SEARCH_NOT_FOUND = 905
    SUBMIT_SEARCH_NOT_FOUND = 906
    SEARCH_FAILED = 907
        #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    #+----------------------------------------+
    #| attr                 | Selenium | Sahi |
    #+----------------------------------------+
    #| :page_url            |    X     |   X  |
    #| :tag_search          |    X     |      |
    #| :id_search           |    X     |   X  |
    #| :label_button_search |          |   X  |
    #+----------------------------------------+
    attr_reader :fqdn_search,  #fqdn de la page du moteur ded recherche
                :path_search, #le path de la page du moteur de recherche
                :id_search, # id de de lobjet javascript qui contient les mot clé à saisir
                :type_search, #le type de lobjet javascript qui contient les mot clé à saisir
                :label_button_search, #label du bouton pour executer la recherche
                :id_captcha, #id de l'objet javascript qui contient le captcha à saisir
                :type_captcha, #le type de l'objet jaavscript qui contient le captcha à saisir
                :fqdn_captcha, # fqdn de l'url qui affiche le captcha du moteur de recherche
                :label_button_captcha, # label du bouton pour valider le captcha
                :id_image_captcha # id de l'objet javascript présentant l'image du captcha

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(engine)
      @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
      case engine
        when :google
          return Google.new
        when :bing
          return Bing.new
        when :yahoo
          return Yahoo.new
        else
          raise Error.new(ENGINE_UNKNOWN, :values => {:engine => engine})
      end
    rescue Exception => e
      @@logger.an_event.error e.message
      raise Error.new(ENGINE_NOT_CREATE, :values => {:engine => engine}, :error => e)

    else
      @@logger.an_event.debug "search engine #{engine} create"

    ensure

    end


    def page_url
      "#{@fqdn_search}#{@path_search}"
    end



    private


  end
end

require_relative 'google'
require_relative 'bing'
require_relative 'yahoo'