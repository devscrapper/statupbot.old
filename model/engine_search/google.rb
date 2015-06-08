require_relative '../../lib/error'
module EngineSearches
  class Google < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------

    def initialize
      @fqdn = "https://www.google.fr"
      @path = "/"
      @id_search = 'q'
      @type_search = "textbox"
      @label_search_button = "Recherche Google"
    end

    def links(body)
      links = []
      body.css('h3.r > a').each { |l|
        links << {:href => l["href"], :text => l.text}
      }
      links
    end

    def next(body)
      if body.css('a#pnnext.pn').empty?
        {}
      else
        {:href => "#{@fqdn}#{body.css('a#pnnext.pn')[0]["href"]}", :text => body.css('a#pnnext.pn > span').text}
      end
    end



    def prev(body)
      if body.css('a#pnprev.pn').empty?
        {}
      else
        {:href => "#{@fqdn}#{body.css('a#pnprev.pn')[0]["href"]}", :text => body.css('a#pnprev.pn > span').text}
      end
    end

    private


    def input(driver)
      driver.textbox(@id_search)
    end
  end

end

