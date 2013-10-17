module Pages
  class Link

    attr_reader :url, :path_frame, :element, :window_tab

    def initialize(url, element, window_tab, path_frame)
      @url = url
      @element= element
      @window_tab = window_tab
      @path_frame = path_frame
    end

    def click
      @element.click
    end

    def exist?
      @element.displayed? and @element.enabled?
    end
  end
end