require_relative '../user_agent'

module Browsers
  class Browser
    class BrowserException < StandardError
    end
    attr :browser_version,
         :operating_system,
         :operating_system_version,
         :flash_version,
         :logger

    attr_accessor :id,
                  :webdriver,
                  :visitor_id,
                  :screens_colors,
                  :screen_resolution,
                  :java_enabled



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
    def self.build(visit, visitor_id)
      case visit["browser"]
        when "Firefox"
          return Firefox.new(visit, visitor_id)
        when "Internet Explorer"
          return InternetExplorer.new(visit, visitor_id)
        when "Chrome"
          return Chrome.new(visit, visitor_id)
        else
          raise BrowserException, "browser <#{visit["browser"]}> unknown"
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(visit, visitor_id)
      @id = UUID.generate
      @visitor_id = visitor_id
      @browser_version = visit["browser_version"]
      @operating_system = visit["operating_system"]
      @operating_system_version = visit["operating_system_version"]
      @flash_version = visit["flash_version"]
      @java_enabled = visit["java_enabled"]
      @screens_colors = visit["screens_colors"]
      @screen_resolution =visit["screen_resolution"]
    end

    #----------------------------------------------------------------------------------------------------------------
    # close
    #----------------------------------------------------------------------------------------------------------------
    # close un webdriver
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def close()
      begin
        @webdriver.close
      rescue Exception => e
        raise BrowserException, e.message
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un browser
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display
      p "+----------------------------------------------"
      p "| BROWSER                                     |"
      p "+---------------------------------------------+"
      p "| browser version : #{@browser_version}"
      p "| operating system : #{@operating_system}"
      p "| operating system version : #{@operating_system_version}"
      p "| flash version : #{@flash_version}"
      p "| java enabled : #{@java_enabled}"
      p "| screen colors : #{@screens_colors}"
      p "| screen resolution : #{@screen_resolution}"
      @webdriver.display
      p "+----------------------------------------------"
      p "| BROWSER                                     |"
      p "+---------------------------------------------+"
    end

    #----------------------------------------------------------------------------------------------------------------
    # go
    #----------------------------------------------------------------------------------------------------------------
    # accède à une url
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def go(url)
      begin
        @webdriver.go(url)
      rescue Exception => e
        raise BrowserException, e.message
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # open
    #----------------------------------------------------------------------------------------------------------------
    # open un webdriver
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def open()
      begin
        @webdriver.open
      rescue Exception => e
        raise BrowserException, e.message
      end
    end

    def accept()
      "image/png, image/svg+xml, image/*;q=0.8, */*;q=0.5"
    end
    def user_agent()
      UserAgent::build(self)
    end

    def accept_encoding()
      "gzip, deflate"
    end

    def viewport_resolution()
      #TODO corriger afin de de na pas coller cette valeur au screen resolsution
      @screen_resolution
    end

    def to_s
      "browser type : #{self.class}\n" + \
      "id browser : #{@id}\n" + \
      "visitor id : #{@visitor_id}\n" + \
      "browser version : #{@browser_version}\n" + \
      "operating system : #{@operating_system}\n" + \
      "operating system version : #{@operating_system_version}\n" + \
      "flash version : #{@flash_version}\n" + \
      @webdriver.to_s + "\n" + \
      "screen colors : #{@screens_colors}\n" + \
      "screen resolution : #{@screen_resolution}\n" + \
      "java enabled : #{@java_enabled}"
    end
  end


end

require_relative "firefox"
require_relative "internet_explorer"
require_relative 'chrome'
require_relative 'safari'