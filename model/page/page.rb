module Pages
  class Page
    class FunctionalError < StandardError
      PARAM_MALFORMED = "paramaters of page are malformed"
      AROUND_UNKNOWN = "around unknown"
      URL_NOT_FOUND = "url not found"
      NONE_LINK = "page has no link"
    end
    attr_accessor :duration
    attr_reader :url,
                :window_tab, # cette données n'est pas utilisée avec Sahi
                :links,
                :duration_search_link,
                :referrer,
                :title,
                :cookies


    def sleeping_time
      #on deduit le temps passé à chercher les liens dans la page
      #  (@duration - @duration_search_link <= 0) ? 0 : @duration - @duration_search_link
      @duration
    end

    def initialize(url, referrer, title, window_tab, links, cookies, duration_search_link=0)
      #duration est initialisé avec le temps passé à chercher les liens dans la page
      begin
        @url = url.is_a?(URI) ? url : URI.parse(url)
        @referrer = referrer
        @title = title
        @window_tab = window_tab
        @links= links
        @cookies = cookies
        @duration_search_link = duration_search_link.to_i
        @@logger.an_event.debug "page url #{@url}"
        @@logger.an_event.debug "page referrer #{@referrer}"
        @@logger.an_event.debug "page title #{@title}"
        @@logger.an_event.debug "page links #{@links}"
        @@logger.an_event.debug "page window_tab #{@window_tab}"
        @@logger.an_event.debug "page cookies #{@cookies}"
        @@logger.an_event.debug "page duration search link #{@duration_search_link}"
      rescue Exception => e
        raise FunctionalError::PARAM_MALFORMED
      end
    end

    def link(around=:inside_fqdn)
      raise FunctionalError::NONE_LINK if @links.size == 0
      case around
        when :inside_fqdn
          @links.select { |l| l.url.hostname == @url.hostname }.shuffle[0]
        when :inside_hostname
          ar = @url.hostname.split(".")
          host = "#{ar[ar.size-2]}.#{ar[ar.size-1]}"
          @links.select { |l|
            l.url.hostname.end_with?(host)
          }.shuffle[0]
        when :outside_hostname
          ar = @url.hostname.split(".")
          host = "#{ar[ar.size-2]}.#{ar[ar.size-1]}"
          @links.select { |l|
            !l.url.hostname.end_with?(host)
          }.shuffle[0]
        when :outside_fqdn
          @links.select { |l| l.url.hostname != @url.hostname }.shuffle[0]
        else
          @@logger.an_event.debug "around #{around} unknown"
          raise FunctionalError::AROUND_UNKNOWN
      end
    end


    #Retourne un link au hasard de la liste d’ url fournie ou url
    # url peut être :
    # soit un array d'url au format string
    # soit un array d'url au format URI => transformation dans al fonction en string
    # soit une url au format string
    # soit une url au format URI   => transformation dans al fonction en string
    #Pour rechercher landing_url dans referral_page : Referral_Page.link_by_url(landing_url)
    def link_by_url(url)
      @@logger.an_event.debug "url #{url.to_s}"
      urls = (url.is_a?(Array)) ? url.map { |u| (u.is_a?(URI)) ? u.to_s : u } : [(url.is_a?(URI)) ? url.to_s : url]
      @@logger.an_event.debug "urls #{urls}"
      @@logger.an_event.debug "count links of page #{@links.size}"
      res = @links.select { |l|
        @@logger.an_event.debug "l #{l.inspect}"
        @@logger.an_event.debug "include? #{urls.include?(l.url.to_s)}"
        urls.include?(l.url.to_s)
      }
      if res.size == 0
        @@logger.an_event.debug "url #{url.to_s} not found"
        raise FunctionalError::URL_NOT_FOUND
      end
      link = res.shuffle[0]
      @@logger.an_event.debug "chosen link #{link}"
      link
    end

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

    def to_s
      "url #{@url}, title #{@title}"
    end
  end
end
