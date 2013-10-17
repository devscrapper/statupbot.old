module EngineSearches
  class Google < EngineSearch
    class GoogleException < StandardError
    end

    URL = "http://www.google.fr"

    def initialize
      @page_url = URL
      @tag_search = :name
      @id_search = 'q'
    end

    def exist_link?(results_page, landing_url)
      results_page.links.each { |l|
        if !l.url.query.nil?
          url = URI::decode_www_form(l.url.query).assoc("q")
          if !url.nil?
            return [true, l] if url[1] == landing_url.to_s
          end
        end
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
