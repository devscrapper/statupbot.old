require_relative 'geolocation/geolocation'
require_relative '../../model/browser/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require_relative 'nationality/nationality'

#require_relative 'customize_queries_connection'
#require_relative 'custom_gif_request/custom_gif_request'

module Visitors
  include Geolocations
  include Nationalities
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings

  class Visitor
    class VisitorException < StandardError
      BAD_VALUE_FOR_RETURN_VISITOR = "value unknown for :return_visitor in visitor_details"
      CANNOT_CONTINUE_VISIT = "visitor cannot continue visit"
      NOT_FOUND_LANDING_PAGE = "visitor not found landing page"
      CANNOT_CONTINUE_SURF = "visitor cannot surf"
      BAD_KEYWORDS = "keywords are bad"
    end

    DIR_VISITORS = File.dirname(__FILE__) + "/../../visitors"

    attr_accessor :id,
                  :browser,
                  :nationality,
                  :geolocation

#  include CustomGifRequest
#----------------------------------------------------------------------------------------------------------------
# class methods
#----------------------------------------------------------------------------------------------------------------
    def self.build(visitor_details)
      case visitor_details[:return_visitor]
        when :true
          #TODO demander à VisitorFacotry de retourner un visitor
          #TODO si pas de return visitor dispo alors retourne un nouveau visitor
          return Visitor.new(visitor_details)
        when :false
          return Visitor.new(visitor_details)
        else
          raise VisitorException::BAD_VALUE_FOR_RETURN_VISITOR
      end
    end

#----------------------------------------------------------------------------------------------------------------
# instance methods
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------------------------------------------------
# crée un visitor :
# - crée le visitor, le browser, la geolocation
#----------------------------------------------------------------------------------------------------------------
# input :
# une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
#["return_visitor", "true"]
#["browser", "Firefox"]
#["browser_version", "16.0"]
#["operating_system", "Windows"]
#["operating_system_version", "7"]
#["flash_version", "11.4 r402"]
#["java_enabled", "No"]
#["screens_colors", "24-bit"]
#["screen_resolution", "1366x768"]
#----------------------------------------------------------------------------------------------------------------
    def initialize(visitor_details)
      @id = UUID.generate
      @nationality = French.new() # par defaut
      @geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
                                  #TODO peut on partager les proxy entre visiteur de site different ?
      @browser = Browser.build(visitor_details[:browser], @nationality, @id)
      @browser.profile = @geolocation.update_profile(@browser.profile)
    end

    def browse(referrer)
      begin
        case referrer
          when Direct
            return @browser.display(referrer.landing_url)
          when Referral
            referral_page= @browser.display(referrer.page_url)
            referral_page.duration = referrer.duration
            read(referral_page)
            return @browser.click_on(referral_page.link_by_url(referrer.landing_url))
          when Search
            results_page = @browser.search(referrer.keywords, referrer.engine_search)
            landing_link_found = false
            landing_link = nil
            index_current_page = 1
            while index_current_page <= referrer.durations.size and \
                !landing_link_found
              results_page.duration = referrer.durations[index_current_page-1]
              read(results_page)
              landing_link_found, landing_link = referrer.engine_search.exist_link?(results_page, referrer.landing_url)
              if !landing_link_found
                index_current_page+=1
                next_page_link_found, next_page_link = referrer.engine_search.next_page_link(results_page, index_current_page)
                results_page = @browser.click_on(next_page_link) if next_page_link_found
                break unless next_page_link_found
              end
            end
            raise VisitorException::BAD_KEYWORDS unless landing_link_found
            return @browser.click_on(landing_link) if landing_link_found
        end
      rescue Exception => e
        #Browsers::BrowserException::SEARCH_FAILED,, SearchEngine::Not_found_link, SearchEngine::Not_found_next_link, SearchEngine::not_found_numcurrentpage
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{id} not found landing page #{referrer.landing_url}"
        raise VisitorException::NOT_FOUND_LANDING_PAGE
      end
    end


    def close_browser
      @browser.close
      #supprimer file contenant la customisation
      File.delete("#{DIR_VISITORS}/#{@id}.json")
    end

    def execute(visit)
      @@logger.an_event.debug visit.to_s
      begin
        landing_page = browse(visit.referrer)
        page = surf(visit.durations, landing_page, visit.around)
        if !visit.advertising.is_a?(NoAdvertising)
          advertiser = visit.advertising.advertiser
          advert_link = visit.advertising.advert_on(page)
          if advert_link.nil?
            @@logger.an_event.warn "advertising #{visit.advertising.class} not found on page #{page.url}"
          else
            advertiser_page = @browser.click_on(advert_link)
            page = surf(advertiser.durations, advertiser_page, advertiser.arounds)
          end
        end
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} cannot execute visit #{visit.id}"
        raise VisitorException::CANNOT_CONTINUE_VISIT
      end
    end

    def open_browser
      @browser.open
      # send customize queries to mitm
      File.open("#{DIR_VISITORS}/#{@id}.json", 'w') do |io|
        io.write @browser.custom_queries.to_json
      end
    end

    def read(page)
      @@logger.an_event.info "visitor #{@id} read page #{page.url} during #{page.duration}s"
      @browser.wait_on(page)
    end

    def surf(durations, page, around)
      # le surf sur le website prend en entrée un around => arounds est rempli avec cette valeur
      # le surf sur l'advertiser predn en entrée un array de around pré calculé par engine bot en fonction des paramètre saisis au moyen de statupweb
      begin
        arounds = (around.is_a?(Array)) ? around : Array.new(durations.size, around)
        durations.each_index { |i|
          page.duration = durations[i]
          read(page)
          link = page.link(arounds[i])
          page = @browser.click_on(link)

        }
        page
      rescue Exception => e
        @@logger.an_event.debug e
        @@logger.an_event.error "visitor #{@id} stop surf at page #{page.url}"
        raise VisitorException::CANNOT_CONTINUE_SURF
      end
    end
  end


end