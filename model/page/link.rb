module Pages
  class Link
    CANNOT_CLICK_ON_LINK = "cannot click on link"

    attr_reader :url,
                :path_frame, # cette donnée n'est pas utilisée avec Sahi
                :element,
                :window_tab,
                :text # le texte du lien

    def initialize(url, element, window_tab, text, path_frame)
      @@logger.an_event.debug "url #{ url.to_s}"
      @@logger.an_event.debug "element #{element}"
      @@logger.an_event.debug "text #{text}"
      raise TechnicalError, PARAM_NOT_DEFINE if element.nil?
      @url = url
      @element= element
      @window_tab = window_tab
      @path_frame = path_frame
      @text = text
    end

    def click
      @@logger.an_event.debug "BEGIN Link.click"
      begin
        @element.click
        @@logger.an_event.debug "click on link #{@element}, #{@url}, #{@text}"
      rescue Exception => e
        @@logger.an_event.debug e.message
        @@logger.an_event.error "cannot click on link #{@element}, #{@url}, #{@text}"
        raise TechnicalError, CANNOT_CLICK_ON_LINK
      ensure
        @@logger.an_event.debug "END Link.click"
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