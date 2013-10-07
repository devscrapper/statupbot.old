module VisitorFactory
  module Publicities
    class Advertiser
      #-----------------------------------------------------------------------------------------------------
      # Advertiser permet de surfer sur le site de l'annonceur qui a exposé sa publicité, sur laquelle on a cliqué à
      # partir du site géré par StatupBot
      #-----------------------------------------------------------------------------------------------------
      #TODO definir et meo une stratégie de surf qui reste en local de l'annonceur et sort du site de l'annonceur ; définir un comportement par defaut parametrable par StatupWeb

      class AdvertiserException < StandardError

      end
      attr :driver

      def initialize(driver)
        @driver = driver
      end

      def click_on(link)
        raise AdvertiserException, "none  link found on #{driver.current_url}" if link.nil?
        go_to_frame(link[0])
        tag_name = link[1].tag_name
        text = link[1].text
        href = link[1][:href]
        displayed = link[2]
        @@logger.an_event.debug "selected link on advertiser"
        @@logger.an_event.debug "tag name #{tag_name}"
        @@logger.an_event.debug "text #{text}"
        @@logger.an_event.debug "displayed? #{displayed}"
        @@logger.an_event.debug "href #{href}"
        stop = false
        while !stop
          begin
            if displayed
              @driver.action.move_to(@link)
              #TODO controler le contenu des header http (referer)
              link[1].click
            else
              #TODO controler le contenu des header http (referer)
              @driver.get href # en principe on devrait pardre le referer avec le get
            end
            stop = true
          rescue TimeoutError => e
            stop = false
          rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
            raise AdvertiserException, "#{tag_name} #{text} #{href}=> #{e.message}"
          rescue Exception => e
            raise AdvertiserException, e.message
          end
        end
      end


      def go_to_frame(path_crt_frame)
        begin
          @driver.switch_to.default_content

          path_crt_frame.each { |frame| @driver.switch_to.frame(frame) }
        rescue Exception => e
          raise AdvertiserException, e.message
        end
      end


# retournes tous les links :
# ceux compris dans les frame
# ceux dans le document principal
# soit ceux local au nom de domaine du site :local
# soit ceux qui ne sont pas seuelement dans le domaine du site :not_local (# ceux des regies publicitaires egalement)
# que des liens http
# la page courante ne fait pas partie de la liste
      def links(around=:local, path_crt_frame=[], crt_frame=nil)
        #TODO faire la liste de toutes les balises html qui referencent un lien http (a, map,...)
        path_crt_frame << crt_frame unless crt_frame.nil?

        start_url = (around == :local) ? "#{URI.parse(@driver.current_url).scheme}://#{URI.parse(@driver.current_url).host}" : "http://"
        go_to_frame(path_crt_frame)

        html_tag_a = @driver.find_elements(:tag_name, "a")
        html_tag_a.select! { |l| !l[:href].nil? and \
                                l[:href] != @driver.current_url and \
                                l[:href].start_with?(start_url) and \
                                !l[:href].end_with?("pdf") and \
                                !l[:href].end_with?("gif") and \
                                l.enabled?
        }
        html_tag_a.uniq! { |p| p[:href] }
        lnks = (html_tag_a.size > 0) ? html_tag_a.map { |link| [Array.new(path_crt_frame), link, link.displayed?] } : []

        @driver.find_elements(:tag_name, "iframe").each { |frame|
          lnks += links(around, path_crt_frame, frame)

          path_crt_frame.pop
          go_to_frame(path_crt_frame)
        }
        lnks
      end

      def link(around=:local)
        #:local : conserver que les liens qui referencent le site
        #:not_local : conserver aussi les liens sortants du site
        begin
          all_links = links(around)
          all_links.each { |link| @@logger.an_event.debug "link on advertiser : in frame #{link[0]} #{link[1].text} #{link[1][:href]}" }
          all_links.shuffle[0]
        rescue Exception => e
          @@logger.an_event.debug e
          raise e.message
        end
      end
    end
  end
end
