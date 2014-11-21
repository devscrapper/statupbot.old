require_relative '../../lib/error'
module EngineSearches
  class Yahoo < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    #+----------------------------------------+
    #| attr                 | Selenium | Sahi |
    #+----------------------------------------+
    #| :page_url            |    X     |   X  |
    #| :tag_search          |    X     |      |
    #| :id_search           |    X     |   X  |
    #| :id_search_button    |          |   X  |
    #| :name_search_button  |          |   X  |
    #| :label_search_button |          |   X  |
    #+----------------------------------------+
    attr_reader :page_url,
                :tag_search,
                :id_search,
                :id_search_button,
                :name_search_button,
                :label_search_button
    #TODO finir yahoo search
    def initialize
      @page_url = "http://www.google.fr/?nord=1"
      @page_url = "https://www.google.fr/"
      @tag_search = :name
      @id_search = 'q'
      @id_search_button ="gbqfba"
      @name_search_button = "btnK"
      @label_search_button = "Recherche Google"
    end

    def exist_link?(results_page, landing_url)

      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "results_page"}) if results_page.nil?
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_url"}) if landing_url.nil?

      results_page.links.each { |l|
        if l.url.to_s == landing_url.to_s
          return l

        elsif !l.url.query.nil?
          begin
            url = URI::decode_www_form(l.url.query).assoc("q")
            if !url.nil? and \
                              url[1] == landing_url.to_s

              return l
            end
          rescue Exception => e
            @@logger.an_event.warn e.message
            raise Error.new(ENGINE_NOT_FOUND_LANDING_LINK, :values => {:engine => self.class, :landing => landing_url} ,:error => e)
          end
        end
      }

      raise Error.new(ENGINE_NOT_FOUND_LANDING_LINK, :values => {:engine => self.class, :landing => landing_url})
    end

    def next_page_link(results_page, index_next_page)
      #https://www.google.fr/search?q=hkl&ei=6StyUonHOLGR7AbH1YCoBg&sqi=2&start=80&sa=N&biw=1508&bih=741


      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "results_page"}) if results_page.nil?
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "index_next_page"}) if index_next_page.nil?

      links = results_page.links.map { |link|
        if link.url.scheme == results_page.url.scheme and link.url.host == results_page.url.host and \
          link.url.path == "/search" and link.text == index_next_page.to_s
          link
        else
          nil
        end
      }.compact!

      raise Error.new(ENGINE_NOT_FOUND_NEXT_LINK, :values => {:engine => self.class, :next => index_next_page}) if links.empty?
      links[0]
    end
  end
end
