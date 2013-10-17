module EngineSearches
  class Bing < EngineSearch
    class BingException < StandardError
    end

    URL = "http://www.bing.com/?cc=fr"

    def initialize
      @page_url = URL
      @tag_search = :name
      @id_search = 'q'
    end

    def exist_link?(results_page, landing_url)
      results_page.links.each { |l|
        return [true, l] if l.url == landing_url
      }
      return [false, nil]
    end

    def next_page_link(results_page, index_next_page)
      results_page.links.each { |link|
        return [true, link] if link.element.text.to_i == index_next_page
      }
      return [false, nil]
    end
  end
end
