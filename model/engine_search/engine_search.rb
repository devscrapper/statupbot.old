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
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    #+----------------------------------------+
    #| attr                 | Selenium | Sahi |
    #+----------------------------------------+
    #| :page_url            |    X     |   X  |
    #| :tag_search          |    X     |      |
    #| :id_search           |    X     |   X  |
    #| :label_search_button |          |   X  |
    #| :id_next             |          |   X  |
    #+----------------------------------------+
    attr_reader :page_url,
                :tag_search,
                :id_search,
                :label_search_button,
                :id_next,
                :id_link

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

    def landing_link(landing_url, driver)

         raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_url"}) if landing_url.nil?

         link = nil
         begin
           link = driver.link(landing_url)

         rescue Exception => e
           raise Error.new(ENGINE_NOT_FOUND_LANDING_LINK, :values => {:engine => self.class, :landing => landing_url}, :error => e)

         else

         ensure
           return link

         end
       end

    def next_page_link(driver)
      next_link = nil

      begin

        next_link = next_link_exists?(driver)

      rescue Exception => e
        raise Error.new(ENGINE_NOT_FOUND_NEXT_LINK, :values => {:engine => self.class}, :error => e)

      else

      ensure
        return next_link

      end
    end


    def search(keywords, driver)
      @@logger.an_event.debug "keywords #{keywords}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => keywords}) if keywords.nil? or keywords==""

        @@logger.an_event.debug "engine_search.id_search #{@id_search}"
        @@logger.an_event.debug "engine_search.label_search_button #{@label_search_button}"

        raise Error.new(TEXTBOX_SEARCH_NOT_FOUND, :values => {:textbox => @id_search}) unless input(driver).exists?
        raise Error.new(SUBMIT_SEARCH_NOT_FOUND, :values => {:submit => @label_search_button}) unless driver.submit(@label_search_button).exists?

        input(driver).value = !keywords.is_a?(String) ? keywords.to_s : keywords

        @@logger.an_event.debug "search engine #{self.class} enter keywords #{keywords} in search form"

        driver.submit(@label_search_button).click

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(SEARCH_FAILED, :values => {:engine => self.class}, :error => e)

      else
        @@logger.an_event.debug "search engine #{self.class} submit search"

      ensure
      end
    end

    private


  end
end

require_relative 'google'
require_relative 'bing'
require_relative 'yahoo'