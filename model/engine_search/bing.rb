require_relative '../../lib/error'
module EngineSearches
  class Bing < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------

    #TODO finir bing search
    def initialize
      @page_url = "http://www.bing.com/"
      @tag_search = :name
      @id_search = 'q'
      @id_next = "Suivant"
      @label_search_button = "go"
    end


    private
    def next_link_exists?(driver)
      driver.link(@id_next)
    end

    def input(driver)
      driver.searchbox(@id_search)
    end

  end
end
