require_relative '../../lib/error'
module EngineSearches
  class Yahoo < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------


    def initialize
      @fqdn = "https://fr.search.yahoo.com"
      @path = "/"
      @id_search = 'p'
      @type_search = "textbox"
      @label_search_button = "Rechercher"
    end

    def links(body)
      links = []
      body.css('h3.title > a.td-u').each { |link|
        begin
          uri = URI.parse(link.attributes["href"].value)
        rescue Exception => e
        else
          links << {:href => /\/RU=(?<href>.+)\/RK=/.match(URI.decode(uri.path))[:href], :text => link.text}
        end
      }
      links
    end

    def next(body)
      if body.css('a.next').empty?
        {}
      else
        {:href => body.css('a.next').first.attributes["href"].value, :text => body.css('a.next').first.text}
      end
    end


    def prev(body)
      if body.css('a.prev').empty?
        {}
      else
        {:href => body.css('a.prev').first.attributes["href"].value, :text => body.css('a.prev').first.text}
      end
    end


    private
    def input(driver)
      driver.textbox(@id_search)
    end
  end
end
