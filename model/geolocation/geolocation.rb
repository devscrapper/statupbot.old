module Geolocations
  class Geolocation
    class GeolocationException < StandardError

    end
    attr :country,
         :language

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # build
    #----------------------------------------------------------------------------------------------------------------
    # crée un geolocation :
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
    #["id_visit", "162"]
    #["start_date_time", "2013-04-21 00:09:00 +0200"]
    #["account_ga", "pppppppppppppp"]       => non repris car fourni par lexecution de la page dans phantomjs
    #["return_visitor", "true"]
    #["browser", "Firefox"]
    #["browser_version", "16.0"]
    #["operating_system", "Windows"]
    #["operating_system_version", "7"]
    #["flash_version", "11.4 r402"]
    #["java_enabled", "No"]
    #["screens_colors", "24-bit"]
    #["screen_resolution", "1366x768"]
    #["referral_path", "(not set)"]
    #["source", "(direct)"]
    #["medium", "(none)"]
    #["keyword", "(not set)"]
    #["pages", [{"id_uri"=>"19155", "delay_from_start"=>"10", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-cadaujac.htm", "title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}, {"id_uri"=>"19196", "delay_from_start"=>"15", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-le_pian_medoc_.htm", "title"=>"Centre d'\u00E9pilation laser LE PIAN M\u00C9DOC  centres de remise en forme LE PIAN M\u00C9DOC"}, {"id_uri"=>"19253", "delay_from_start"=>"39", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-yvrac.htm", "title"=>"Centre d'\u00E9pilation laser YVRAC centres de remise en forme YVRAC"}, {"id_uri"=>"115", "delay_from_start"=>"12", "hostname"=>"www.epilation-laser-definitive.info", "page_path"=>"/en/", "title"=>"Final Laser depilation"}]]
    #----------------------------------------------------------------------------------------------------------------
    def self.build(visit)
      # return by default : direct
      return Direct.new() if visit["return_visitor"] == "true" #pour tester
      return Proxy.new()  if visit["return_visitor"] == "false" #pour tester
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(country, language)
      @country = country
      @language = language
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un geolocation
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display()
      p "+----------------------------------------------"
      p "| GEOLOCATION                                     |"
      p "+---------------------------------------------+"
      p "| country : #{@country}"
      p "| language : #{@language}"
      p "+----------------------------------------------"
      p "| GEOLOCATION                                     |"
      p "+---------------------------------------------+"
    end

    def to_s()
      "country : #{@country}, language : #{language}"
    end

  end
end
