module EngineSearches
  class Google < EngineSearch
    class GoogleException < StandardError
    end



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
      results_page.links.each { |l|
        if l.url.to_s == landing_url.to_s
          return [true, l]
        elsif !l.url.query.nil?
          begin
            url = URI::decode_www_form(l.url.query).assoc("q")
            return [true, l] if !url.nil? and \
                              url[1] == landing_url.to_s
          rescue Exception => e
          end
        end
      }
      return [false, nil]
    end

    def next_page_link(results_page, index_next_page)
      #https://www.google.fr/search?q=hkl&ei=6StyUonHOLGR7AbH1YCoBg&sqi=2&start=80&sa=N&biw=1508&bih=741
      results_page.links.each { |link|
        # permet de s'assurer que on selectionne une url de recherche de google de la meme provenance .fr
        return [true, link] if link.url.scheme == results_page.url.scheme and \
                              link.url.host == results_page.url.host and \
                              link.element.text.to_i == index_next_page
      }
      return [false, nil]
    end
  end
end
