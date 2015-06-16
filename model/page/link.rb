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
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :uri, #URI object
                :uri_escape, #URI object
                :window_tab
    attr_accessor :text # le texte du lien
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
    def initialize(url, window_tab, text)
      @@logger ||= Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

      @@logger.an_event.debug "url #{ url.to_s}"
      @@logger.an_event.debug "text #{text}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "url"}) if url.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "text"}) if text.nil? or text == ""

        @uri_escape = URI.parse(URI.escape(url))
        @uri = URI.parse(url)
        @window_tab = window_tab
        @text = text

      rescue Exception => e
        @@logger.an_event.debug e.message
        raise Error.new(LINK_NOT_CREATE, :values => {:link => url})
      else
        @@logger.an_event.debug self.to_s

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

    def url
      @uri.to_s
    end

    def url_escape
      @uri_escape.to_s
    end

    def to_s
      "uri_escape #{@uri_escape} | " +
          "uri #{@uri} | " +
          "text #{@text} | " +
          "window tab #{@window_tab}"

    end
  end
end