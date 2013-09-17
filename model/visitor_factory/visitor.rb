require_relative 'geolocation/geolocation'
require_relative 'geolocation/direct'
require_relative 'geolocation/proxy'
require_relative 'browser/browser'

#require_relative 'customize_queries_connection'
#require_relative 'custom_gif_request/custom_gif_request'
require_relative 'nationality/nationality'
module VisitorFactory
  class Visitor
    class VisitorException < StandardError;
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
      @id = visitor_details[:id]
      @nationality = French.new() # par defaut
      @geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
      @browser = Browser.build(visitor_details, self)
    end

    def send_customisation_to_mitm
      File.open("#{DIR_VISITORS}/#{@id}.json", 'w') do |io| io.write @browser.custom_queries.to_json end
    end

    def del_customisation
      File.delete("#{@id}.json")
    end
    def to_s
      "id : #{@id}\n" + \
    @browser.to_s + "\n" + \
    @geolocation.to_s
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un visitor
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display()
      p "+----------------------------------------------"
      p "| VISITOR                                     |"
      p "+---------------------------------------------+"
      p "| id visitor : #{@id}"
      @browser.display
      @geolocation.display
      p "+----------------------------------------------"
      p "| VISITOR                                     |"
      p "+---------------------------------------------+"
    end




  end


end