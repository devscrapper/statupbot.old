require_relative '../../lib/error'
module Pages
  class Link
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------
    class LinkError < Error

    end
    ARGUMENT_UNDEFINE = 400
    LINK_NOT_FIRE = 401
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :url,
                :path_frame, # cette donnée n'est pas utilisée avec Sahi
                :element,
                :window_tab,
                :text # le texte du lien
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # crée un proxy :
    # inputs
    # url,
    # referrer,
    # title,
    # window_tab,
    # links,
    # cookies,
    # duration_search_link=0
    # output
    # LinkError.new(ARGUMENT_UNDEFINE)
    # LinkError.new(ARGUMENT_UNDEFINE)
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def initialize(url, element, window_tab, text, path_frame=nil)
      @@logger.an_event.debug "url #{ url.to_s}"
      @@logger.an_event.debug "element #{element}"
      @@logger.an_event.debug "text #{text}"

      raise LinkError.new(ARGUMENT_UNDEFINE), "element undefine" if element.nil?
      raise LinkError.new(ARGUMENT_UNDEFINE), "url undefine" if url.nil?

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
        @@logger.an_event.debug "link #{@element}, #{@url}, #{@text} fire"
          #TODO tester si la page en retour est une page d'erreur sahi. Si c'est le cas retourner une exception LINK_NOT_CATCH_RESOURCE (synonyme de 404). on ne sait pas si c'est une erreur soit de proxy non joignable car tombé soit un param de proxy erroné soit une ressource absente.
      rescue Exception => e
        @@logger.an_event.fatal "link #{@element}, #{@url}, #{@text} not fire : #{e.message}"
        raise LinkError.new(LINK_NOT_FIRE), "link #{@element}, #{@url}, #{@text} not fire"
      ensure
        @@logger.an_event.debug "END Link.click"
      end
    end


    def exists?
      count_try = 1
      max_count_try = 10
      found = @element.exists?
      while count_try < max_count_try and !found
        @@logger.an_event.warn "link #{@url} not found, try #{count_try}"
        count_try += 1
        sleep 1
        found = @element.exists?
      end
      #@element.displayed? and @element.enabled?
      found
    end

    def to_s
      "url #{@url}, element #{@element}, window_tab #{@window_tab}, path_frame #{@path_frame}, text #{@text}"
    end
  end
end