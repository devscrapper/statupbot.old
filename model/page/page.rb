module Pages
  class Page
    class PageException < StandardError
      PARAM_MALFORMED = "paramaters of page are malformed"
      AROUND_UNKNOWN = "around unknown"
      URL_NOT_FOUND = "url not found"
      NONE_LINK = "page has no link"
    end
    attr_accessor :duration
    attr_reader :url,
                :window_tab, # cette données n'est pas utilisée avec Sahi
                :links,
                :duration_search_link


    def sleeping_time
      #on deduit le temps passé à chercher les liens dans la page
    #  (@duration - @duration_search_link <= 0) ? 0 : @duration - @duration_search_link
      @duration
    end

    def initialize(url, window_tab, links, duration_search_link=0)
      #duration est initialisé avec le temps passé à chercher les liens dans la page
      begin
        @url = url.is_a?(URI) ? url : URI.parse(url)
        @window_tab = window_tab
        @links= links
        @duration_search_link = duration_search_link.to_i
      rescue Exception => e
        raise PageException::PARAM_MALFORMED
      end
    end

    def link(around=:inside_fqdn)
      raise PageException::NONE_LINK if @links.size == 0
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
          raise PageException::AROUND_UNKNOWN
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
      urls = (url.is_a?(Array)) ? url.map { |u| (u.is_a?(URI)) ? u.to_s : u } : [(url.is_a?(URI)) ? url.to_s : url]
      res = @links.select { |l| urls.include?(l.url.to_s) }
      raise PageException::URL_NOT_FOUND if res.size == 0
      res.shuffle[0]
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
  end
end
