require_relative '../../lib/error'

module Pages

  class Page
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------
    class PageError < Error

    end
    ARGUMENT_UNDEFINE = 500
    PAGE_NOT_CREATE = 501
    PAGE_AROUND_UNKNOWN = 502
    URL_NOT_FOUND = 503
    PAGE_NONE_LINK = 504
    PAGE_NONE_LINK_BY_AROUND = 505
    PAGE_NONE_LINK_BY_URL = 506
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_accessor :duration
    attr_reader :url,
                :window_tab, # cette données n'est pas utilisée avec Sahi
                :links,
                :duration_search_link,
                :referrer,
                :title,
                :cookies,
                :advert

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
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #        #duration est initialisé avec le temps passé à chercher les liens dans la page
    #----------------------------------------------------------------------------------------------------------------

    def initialize(url, referrer, title, window_tab, links, cookies, duration_search_link=0)
      @@logger.an_event.debug "BEGIN Page.initialize"

      @@logger.an_event.debug "url #{url}"
      @@logger.an_event.debug "referrer #{referrer}"
      @@logger.an_event.debug "title #{title}"
      @@logger.an_event.debug "links #{links.to_s}"
      @@logger.an_event.debug "window_tab #{window_tab}"
      @@logger.an_event.debug "cookies #{cookies}"
      @@logger.an_event.debug "duration search link #{duration_search_link}"

      raise PageError.new(ARGUMENT_UNDEFINE), "url undefine" if url.nil? or url == ""
      raise PageError.new(ARGUMENT_UNDEFINE), "referrer undefine" if referrer.nil?
      raise PageError.new(ARGUMENT_UNDEFINE), "title undefine" if title.nil?
      raise PageError.new(ARGUMENT_UNDEFINE), "links undefine" if links.nil?

      begin
        @url = url.is_a?(URI) ? url : URI.parse(url)
        @referrer = referrer
        @title = title
        @window_tab = window_tab
        @links= links.map { |link| Pages::Link.new(URI.parse(link["href"]), link["element"], title, link["text"]) }
        @cookies = cookies
        @duration_search_link = duration_search_link.to_i
      rescue Exception => e
        @@logger.an_event.error "page #{@url.to_s} not create : #{e.message}"
        raise PageError.new(PAGE_NOT_CREATE), "page #{@url.to_s} not created"
      ensure
        @@logger.an_event.debug "END Page.initialize"
      end
    end

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
    # link
    #----------------------------------------------------------------------------------------------------------------
    # fournit les links qui satisfonf :around
    # inputs
    # around
    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def link_by_around(around=:inside_fqdn)
      @@logger.an_event.debug "BEGIN Page.link"
      @@logger.an_event.debug "around #{around}"

      raise PageError.new(PAGE_NONE_LINK), "page #{@url.to_s} no link" if @links.size == 0


      link = nil
      case around
        when :inside_fqdn
          link = @links.select { |l| l.url.hostname == @url.hostname }.shuffle[0]
        when :inside_hostname
          ar = @url.hostname.split(".")
          host = "#{ar[ar.size-2]}.#{ar[ar.size-1]}"
          link = @links.select { |l|
            l.url.hostname.end_with?(host)
          }.shuffle[0]
        when :outside_hostname
          ar = @url.hostname.split(".")
          host = "#{ar[ar.size-2]}.#{ar[ar.size-1]}"
          link = @links.select { |l|
            !l.url.hostname.end_with?(host)
          }.shuffle[0]
        when :outside_fqdn
          link = @links.select { |l| l.url.hostname != @url.hostname }.shuffle[0]
        else
          @@logger.an_event.warn "around #{around} unknown"
          @@logger.an_event.debug "END Page.link"
          raise PageError.new(PAGE_AROUND_UNKNOWN), "around #{around} unknown"
      end
      raise PageError.new(PAGE_NONE_LINK_BY_AROUND) if link.nil?
      @@logger.an_event.debug "chosen link #{link.to_s}"
      @@logger.an_event.debug "END Page.link"
      link
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
      @@logger.an_event.debug "BEGIN Page.link_by_url"
      @@logger.an_event.debug "url #{url.to_s}"

      raise PageError.new(ARGUMENT_UNDEFINE), "url undefine" if url.nil?

      urls = (url.is_a?(Array)) ? url.map { |u| (u.is_a?(URI)) ? u.to_s : u } : [(url.is_a?(URI)) ? url.to_s : url]
      @@logger.an_event.debug "urls #{urls}"
      @@logger.an_event.debug "count links of page #{@links.size}"

      res = @links.select { |l|
        @@logger.an_event.debug "link #{l.url.to_s}"
        @@logger.an_event.debug "include? #{urls.include?(l.url.to_s)}"
        urls.include?(l.url.to_s)
      }

      link = res.shuffle[0]
      raise PageError.new(PAGE_NONE_LINK_BY_URL), "none link #{url.to_s} found by url" if link.nil?
      @@logger.an_event.debug "chosen link #{link.to_s}"
      @@logger.an_event.debug "END Page.link_by_url"
      link
    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # crée un proxy :
    # inputs
    # visitor_dir,
    # listening_port_proxy,
    # ip_geo_proxy,   (option)
    # port_geo_proxy, (option)
    # user_geo_proxy, (option)
    # pwd_geo_proxy   (option)
    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def link_by_hostname(hostname)
      #retourne nil pas aucun lien a un hostname dans la liste passée en paramètre
      hostnames = (hostname.is_a?(Array)) ? hostname : [hostname]
      @links.select { |l|
        hostname = l.url.hostname
        !hostnames.select { |host|
          !hostname.match(host).nil?
        }.compact.empty?
      }.shuffle[0]
    end

    def link_by_tagname(tag, id)

    end

    def sleeping_time
      #on deduit le temps passé à chercher les liens dans la page
      #  (@duration - @duration_search_link <= 0) ? 0 : @duration - @duration_search_link
      @duration
    end

    def to_s
      "url #{@url}, title #{@title}"
    end
  end
end
