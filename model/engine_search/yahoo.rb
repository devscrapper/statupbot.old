require_relative '../../lib/error'
module EngineSearches
  class Yahoo < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------

    #TODO finir yahoo search
    def initialize
      @page_url = "https://fr.yahoo.com/"
      @id_search = 'p'
      @label_search_button = "Recherche Web"
      @id_next = "Suivante"

    end

    private
    def next_link_exists?(driver)
      driver.link(@id_next)
    end

    def input(driver)
      driver.textbox(@id_search)
    end
  end
end
