module VisitorFactory
  module Publicities
    class Adsense < Publicity
      #-----------------------------------------------------------------------------------------------------
      # Adsense permet de localiser les lien publicitaires portée par les Pubs Adsense et de cliquer sur la pub
      # Remarque : les pub Adsense sont localisée au sein de frame.
      #-----------------------------------------------------------------------------------------------------
      class AdsenseException < StandardError

      end
      attr :path_frame

      def self.build(driver, path_crt_frame=[], crt_frame=nil)
        path_crt_frame << crt_frame unless crt_frame.nil?

        Adsense.go_to_frame(driver, path_crt_frame)
        adverts = (driver.find_elements(:class, "rhtitle").size > 0) ? [Adsense.new(driver, Array.new(path_crt_frame))] : []

        driver.find_elements(:tag_name, "iframe").each { |frame|
          adverts += Adsense.build(driver, path_crt_frame, frame)

          path_crt_frame.pop
          Adsense.go_to_frame(driver, path_crt_frame)
        }
        adverts

      end

      def self.go_to_frame(driver, path_crt_frame)
        begin
          driver.switch_to.default_content
          path_crt_frame.each { |frame| driver.switch_to.frame(frame) }
        rescue Exception => e
          raise AdsenseException, e.message
        end
      end

      def initialize(driver, path_frame)
        @path_frame = path_frame
        super(driver)
      end


      def click
        begin
          sleep(5)

          @driver.switch_to.default_content
          @path_frame.each { |frame| p frame[:id]; @driver.switch_to.frame(frame) }
          l = @driver.find_element(:class, ["rhtitle", "rhurl", "rhbutton"].shuffle[0])
          l.click
        rescue Exception => e
          raise AdsenseException, "none adense found"
        end
        Advertiser.new(@driver)
      end

      def log
        begin
          Adsense.go_to_frame(@driver, @path_frame)
          @driver.find_elements(:tag_name, "a").each { |link| @@logger.an_event.debug "publicity adsense : #{link.text}, #{link[:class]}, #{link[:href]}" }
        rescue Exception => e
          raise AdsenseException, e.message
        end
      end


    end
  end
end