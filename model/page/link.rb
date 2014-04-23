module Pages
  class Link

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

    def to_s
      "url #{@url}, element #{@element}, window_tab #{@window_tab}, path_frame #{@path_frame}, text #{@text}"
    end
  end
end