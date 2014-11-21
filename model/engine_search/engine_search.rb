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
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr :page_url,
         :tag_search, :id_search

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(engine)

      case engine
        when "google"
          return Google.new
        when "bing"
          return Bing.new
        when "yahoo"
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
  end
end

require_relative 'google'
require_relative 'bing'