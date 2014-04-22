module Pages
  class Link
    class FunctionalException < StandardError

    end
    class TechnicalException < StandardError

    end
    attr_reader :url,
                :path_frame, # cette donnée n'est pas utilisée avec Sahi
                :element,
                :window_tab,
                :text # le texte du lien

    def initialize(url, element, window_tab, text, path_frame)
      @url = url
      @element= element
      @window_tab = window_tab
      @path_frame = path_frame
      @text = text
    end

    def click
      begin
        @element.click
      rescue Exception => e
      end
    end

    def exist?
      @element.displayed? and @element.enabled?
    end
  end
end