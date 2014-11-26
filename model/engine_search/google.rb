require_relative '../../lib/error'
module EngineSearches
  class Google < EngineSearch

    include Errors
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    #TODO rework google search avec primitive sahi et css
    def initialize
      @page_url = "https://www.google.fr/"
      @id_search = 'q'
      @id_next = "Suivant"
      @label_search_button = "Recherche Google"
    end

    private
    def next_link_exists?(driver)
      driver.span(@id_next)
    end

    def input(driver)
      driver.textbox(@id_search)
    end
  end

end

