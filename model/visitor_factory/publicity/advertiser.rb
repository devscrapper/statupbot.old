module VisitorFactory
  module Publicities
    class Advertiser
      #-----------------------------------------------------------------------------------------------------
      # Advertiser permet de surfer sur le site de l'annonceur qui a exposé sa publicité, sur laquelle on a cliqué à
      # partir du site géré par StatupBot
      #-----------------------------------------------------------------------------------------------------
      class AdvertiserException < StandardError

      end
      attr :driver

      def initialize(driver)
        @driver = driver
      end

      def click_on(link)
        @@logger.an_event.debug "select link on advertiser : in frame #{link[0]} #{link[1].text} #{link[1][:href]}"
        begin
          go_to_frame(link[0])
          link[1].click
        rescue Exception => e
          raise AdvertiserException, e.message
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
      def links(path_crt_frame=[], crt_frame=nil)
        path_crt_frame << crt_frame unless crt_frame.nil?

        go_to_frame(path_crt_frame)

        lnks = @driver.find_elements(:tag_name, "a")
        links = (lnks.size > 0) ? lnks.map { |link| [Array.new(path_crt_frame), link] } : []

        @driver.find_elements(:tag_name, "iframe").each { |frame|
          links += links_in_frames(path_crt_frame, frame)

          path_crt_frame.pop
          go_to_frame(path_crt_frame)
        }
        links

      end

      def select_link
        begin
          all_links = links
          all_links.each { |link| @@logger.an_event.debug "link on advertiser : in frame #{link[0]} #{link[1].text} #{link[1][:href]}" }
          all_links.shuffle[0]
        rescue Exception => e
          raise AdvertiserException, e.message
        end
      end
    end
  end
end
