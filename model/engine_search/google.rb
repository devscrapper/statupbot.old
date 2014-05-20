module EngineSearches
  class Google < EngineSearch

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
      @@logger.an_event.debug "BEGIN Google.exist_link?"
      raise EngineSearchError.new(ARGUMENT_UNDEFINE), "results_page undefine" if results_page.nil?
      raise EngineSearchError.new(ARGUMENT_UNDEFINE), "landing_url undefine" if landing_url.nil?

      results_page.links.each { |l|
        if l.url.to_s == landing_url.to_s
          @@logger.an_event.debug "END Google.exist_link?"
          return l
        elsif !l.url.query.nil?
          begin
            url = URI::decode_www_form(l.url.query).assoc("q")
            if !url.nil? and \
                              url[1] == landing_url.to_s
              @@logger.an_event.debug "END Google.exist_link?"
              return l
            end
          rescue Exception => e
            @@logger.an_event.warn "engine search not found landing link : #{e.message}"
            @@logger.an_event.debug "END Google.exist_link?"
            raise EngineSearchError.new(ENGINE_NOT_FOUND_LANDING_LINK, e), "engine search #{self.class} not found landing link"
          end
        end
      }
      @@logger.an_event.debug "END Google.exist_link?"
      raise EngineSearchError.new(ENGINE_NOT_FOUND_LANDING_LINK), "engine search #{self.class} not found landing link"
    end

    def next_page_link(results_page, index_next_page)
      #https://www.google.fr/search?q=hkl&ei=6StyUonHOLGR7AbH1YCoBg&sqi=2&start=80&sa=N&biw=1508&bih=741
      @@logger.an_event.debug "BEGIN Google.next_page_link"
      raise EngineSearchError.new(ARGUMENT_UNDEFINE), "results_page undefine" if results_page.nil?
      raise EngineSearchError.new(ARGUMENT_UNDEFINE), "index next page undefine" if index_next_page.nil?

      links = results_page.links.map { |link|
        if link.url.scheme == results_page.url.scheme and link.url.host == results_page.url.host and \
          link.url.path == "/search" and link.text == index_next_page.to_s
          link
        else
          nil
        end
      }.compact!

      raise EngineSearchError.new(ENGINE_NOT_FOUND_NEXT_LINK), "engine search #{self.class} not found next link" if links.empty?
      @@logger.an_event.debug "END Google.next_page_link"
      links[0]
    end
  end
end
