module VisitorFactory
  module Publicities
    class Adsense < Publicity
      #-----------------------------------------------------------------------------------------------------
      # Adsense permet de localiser les lien publicitaires portée par les Pubs Adsense et de cliquer sur la pub
      # Remarque : les pub Adsense sont localisée au sein de frame.
      # pour localiser les adsens, on rechercher les balise <a> dont le href contient : [/doubleclick.net/, /googleadservices.com/]
      #-----------------------------------------------------------------------------------------------------
      class AdsenseException < StandardError

      end
      attr :path_frame,
           :link

      def self.build(driver)
        begin
          all_publicities = Publicity.publicities(driver, [/doubleclick.net/, /googleadservices.com/])
          adsense = all_publicities.shuffle[0]
          return Adsense.new(driver, adsense[0], adsense[1])
        rescue Exception => e
          @@logger.an_event.debug e
          raise AdsenseException, e.message
        end
      end

      def initialize(driver, path_frame, link)
        @path_frame = path_frame
        @link = link

        super(driver)
      end

      def click
        go_to_frame
        @@logger.an_event.debug "selected publicity : "
        @@logger.an_event.debug "tag name #{@link.tag_name}"
        @@logger.an_event.debug "text #{@link.text}"
        @@logger.an_event.debug "href #{@link[:href]}"
        stop = false
        while !stop
          begin
             # @driver.action.move_to(@link)
              @@logger.an_event.debug "move to link #{@link.text}"
              @link.click
              @@logger.an_event.debug "click on link #{@link.text}"
            stop = true
          rescue TimeoutError => e
            stop = false
            @@logger.an_event.debug "Time out on click link #{@link.text}"
          rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
            @@logger.an_event.debug "error on click link #{@link.text}, #{@link.tag_name} #{@link.text} #{@link[:href]}=> #{e.message}"
            raise AdsenseException, "#{@link.tag_name} #{@link.text} #{@link[:href]}=> #{e.message}"
          rescue Exception => e
            raise AdsenseException, e.message
          end
        end
        Advertiser.new(@driver)
      end


      def go_to_frame
        begin
          @driver.switch_to.default_content
          @path_frame.each { |frame| @driver.switch_to.frame(frame) }
        rescue Exception => e
          raise AdsenseException, e.message
        end
      end


    end
  end
end