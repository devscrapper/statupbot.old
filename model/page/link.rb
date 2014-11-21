require 'uri'
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
    ARGUMENT_UNDEFINE = 400
    LINK_NOT_FIRE = 401
    LINK_NOT_EXIST = 402
    LINK_NOT_CREATE = 403
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

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "element"}) if element.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "url"}) if url.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "text"}) if text.nil? or text == ""

        @url = URI.parse(URI.escape(url))
        @element= element
        @window_tab = window_tab
        @path_frame = path_frame
        @text = text
      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(LINK_NOT_CREATE, :values => {:link => url})
      else
        @@logger.an_event.debug "link #{@element}, #{@url}, #{@text} create"
      ensure

      end
    end

    def click
      begin

        @element.click

      rescue Exception => e
        @@logger.an_event.fatal e.message
        raise Error.new(LINK_NOT_FIRE, :values => {:link => @text}, :error => e)

      else
        @@logger.an_event.debug "link #{@element}, #{@url}, #{@text} fire"

      ensure


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
        #TODO controler qu'il ne faut pas utiliser @element.displayed? and @element.enabled?
        found = @element.exists?
      end
      #@element.displayed? and @element.enabled?
      raise Error.new(LINK_NOT_EXIST, :values => {:link => @text}) unless found
    end

    def to_s
      "url #{@url}, element #{@element}, window_tab #{@window_tab}, path_frame #{@path_frame}, text #{@text}"
    end
  end
end