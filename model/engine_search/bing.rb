require_relative '../../lib/error'
module EngineSearches
  class Bing < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------


    def initialize
      @fqdn = "http://www.bing.com"
      @path = "/"
      @id_search = 'q'
      @type_search = "searchbox"
      @label_search_button = "go"
    end
    def adverts(body)
       []
    end
    def links(body)
      links = []
      body.css('li.b_algo > h2 > a').each { |l|
        links << {:href => l["href"], :text => l.text}
      }
      links
    end

    def next(body)
      if body.css('a.sb_pagN').empty?
        {}
      else
        {:href => "#{@fqdn}#{body.css('a.sb_pagN').first["href"]}", :text => body.css('a.sb_pagN').text}
      end
    end


    def prev(body)
      if body.css('a.sb_pagP').empty?
        {}
      else
        {:href => body.css('a.sb_pagP').first["href"], :text => body.css('a.sb_pagP').first.text}
      end
    end
    private
    def input(driver)
      driver.searchbox(@id_search)
    end

  end
end
