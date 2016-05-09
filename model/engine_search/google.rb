require_relative '../../lib/error'
module EngineSearches
  class Google < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------

    def initialize       #https://www.google.fr/webhp?gws_rd=ssl&ei=ihspV9mfFYm5abK7oZAH&emsg=NCSR&noj=1
      @fqdn = "https://www.google.fr"
      @path = "/" #webhp?gws_rd=ssl&emsg=NCSR&noj=1"
      @id_search = 'q'
      @type_search = "textbox"
      @label_search_button = "Recherche Google"
    end

    def adverts(body)
      adverts = []
      body.css('ol > li.ads-ad > h3 > a:nth-child(2)').each { |l|
        adverts << {:href => l["href"], :text => l.text}
      }
      adverts
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

