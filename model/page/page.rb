require_relative '../../lib/error'

module Pages
  #----------------------------------------------------------------------------------------------------------------
  # action                    | id | produce Page
  #----------------------------------------------------------------------------------------------------------------
  # go_to_start_landing	      | a	 | Website
  # go_to_start_engine_search	| b	 | SearchEngine
  # go_back_engine_search	    | c	 | SearchEngine
  # go_to_landing	            | d	 | Website
  # go_to_referral	          | e	 | UnManage
  # go_to_search_engine 	    | f	 | SearchEngine
  # sb_search 	              | 0	 | Results
  # sb_final_search 	        | 1	 | Results
  # cl_on_next 	              | A	 | Results
  # cl_on_previous 	          | B	 | Results
  # cl_on_result 	            | C	 | UnManage
  # cl_on_landing 	          | D	 | Website
  # cl_on_link_on_website 	  | E	 | Website
  # cl_on_advert	            | F	 | UnManage
  # cl_on_link_on_unknown	    | G	 | UnManage
  # cl_on_link_on_advertiser	| H	 | UnManage
  #----------------------------------------------------------------------------------------------------------------
  class Page
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------

    ARGUMENT_UNDEFINE = 500
    PAGE_NOT_CREATE = 501
    PAGE_AROUND_UNKNOWN = 502
    URL_NOT_FOUND = 503
    PAGE_NONE_LINK = 504
    PAGE_NONE_LINK_BY_AROUND = 505
    PAGE_NONE_LINK_BY_URL = 506
    PAGE_NONE_INSIDE_LINKS = 507
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
    #TODO faire le point sur les attributs nécessaire par type de page.
    attr_reader :duration,
                :duration_search_link,
                :uri,
                :title

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # advert=
    #----------------------------------------------------------------------------------------------------------------
    # affecte un link advert à la page courante
    # input :
    # objet Sahi
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def advert=(link)
      # le text du link est valorisée soit avec le text soit title d'un lien
      @advert = link.nil? ? link : Pages::Link.new("advert", link[0], "advert", link[1].empty? ? "advert" : link[1])
    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # crée un proxy :
    # inputs
    # uri,
    # referrer,
    # title,
    # window_tab,
    # links,
    # cookies,
    # duration_search_link=0
    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #        #duration est initialisé avec le temps passé à chercher les liens dans la page
    #----------------------------------------------------------------------------------------------------------------

    def initialize(href, title, duration, duration_search_link=0)
      @@logger ||= Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

      @@logger.an_event.debug "href #{href}"
      @@logger.an_event.debug "title #{title}"
      @@logger.an_event.debug "duration search link #{duration_search_link}"
      @@logger.an_event.debug "duration #{duration}"


      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "href"}) if href.nil? or href == ""
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "title"}) if title.nil?
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "duration"}) if duration.nil?

      begin
        @uri = URI.parse(href)
        @title = title
        @duration = duration.to_i
        @duration_search_link = duration_search_link.to_i
      rescue Exception => e
        @@logger.an_event.info e
      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # link_by_url
    #----------------------------------------------------------------------------------------------------------------
    # #Retourne un link au hasard de la liste d’ url fournie ou url:
    # inputs
    #url
    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #      #Retourne un link au hasard de la liste d’ url fournie ou url
    # url peut être :
    # soit un array d'url au format string
    # soit un array d'url au format URI => transformation dans al fonction en string
    # soit une url au format string
    # soit une url au format URI   => transformation dans al fonction en string
    #Pour rechercher landing_url dans referral_page : Referral_Page.link_by_url(landing_url)
    #----------------------------------------------------------------------------------------------------------------

    def link_by_url(url)

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "url"}) if url.nil?

        urls = (url.is_a?(Array)) ? url.map { |u| (u.is_a?(URI)) ? u.to_s : u } : [(url.is_a?(URI)) ? url.to_s : url]
        @@logger.an_event.debug "urls #{urls}"
        @@logger.an_event.debug "count links of page #{@links.size}"

        res = @links.select { |l|
          @@logger.an_event.debug "link #{l.url.to_s}"
          @@logger.an_event.debug "include? #{urls.include?(l.url.to_s)}"
          urls.include?(l.url.to_s)
        }

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(PAGE_NONE_LINK_BY_URL, :values => {:url => url.to_s}, :error => e)

      else
        if res == []
          raise Error.new(PAGE_NONE_LINK_BY_URL, :values => {:url => url.to_s})

        else
          return res.shuffle[0]

        end

      ensure

      end

    end

    #----------------------------------------------------------------------------------------------------------------
    # sleeping_time
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------

    def sleeping_time
      #on deduit le temps passé à chercher les liens dans la page
      #  (@duration - @duration_search_link <= 0) ? 0 : @duration - @duration_search_link
      @duration
    end

    #----------------------------------------------------------------------------------------------------------------
    # to_s
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------

    def to_s
      "uri : #{@uri}\n" +
          "url : #{url}\n" +
          "title : #{@title}\n" +
          "duration : #{@duration}\n" +
          "duration_search_link : #{@duration_search_link}\n"
    end

    def url
      @uri.to_s
    end
  end
end


require_relative 'engine_search'
require_relative 'results'
require_relative 'unmanage'
require_relative 'website'