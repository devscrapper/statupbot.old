require_relative 'communication'
require_relative '../lib/logging'
require_relative 'page'
class Referer < Page
  class RefererException < StandardError;
  end

  attr :referral_path,
       :source,
       :medium,
       :keyword,
       :logger

  #----------------------------------------------------------------------------------------------------------------
  # class methods
  #----------------------------------------------------------------------------------------------------------------

  #----------------------------------------------------------------------------------------------------------------
  # instance methods
  #----------------------------------------------------------------------------------------------------------------
  #----------------------------------------------------------------------------------------------------------------
  # initialize
  #----------------------------------------------------------------------------------------------------------------
  # crée une visite :
  # - crée le visitor, le referer, les pages
  #----------------------------------------------------------------------------------------------------------------
  # input :
  # une visite qui est une ligne du flow : published-visits_label_date_hour.json
  # {"id_visit":"1321","start_date_time":"2013-04-21 00:13:00 +0200","account_ga":"pppppppppppppp","return_visitor":"true","browser":"Internet Explorer","browser_version":"8.0","operating_system":"Windows","operating_system_version":"XP","flash_version":"11.6 r602","java_enabled":"Yes","screens_colors":"32-bit","screen_resolution":"1024x768","referral_path":"(not set)","source":"google","medium":"organic","keyword":"(not provided)","pages":[{"id_uri":"856","delay_from_start":"33","hostname":"centre-aude.epilation-laser-definitive.info","page_path":"/ville-11-castelnaudary.htm","title":"Centre d'épilation laser CASTELNAUDARY centres de remise en forme CASTELNAUDARY"}]}
  #----------------------------------------------------------------------------------------------------------------
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
  def initialize(visit_hash, start_date_time, visit_id)
    @referral_path = visit_hash["referral_path"]
    @source = visit_hash["source"]
    @medium = visit_hash["medium"]
    @keyword = visit_hash["keyword"]
    page = {"id_uri" => "0",
            "delay_from_start" => "0",
            "hostname" => hostname,
            "page_path" => page_path}
    super(page, start_date_time, visit_id)
  end

  #----------------------------------------------------------------------------------------------------------------
  # display
  #----------------------------------------------------------------------------------------------------------------
  # affiche le contenu d'un referer
  #----------------------------------------------------------------------------------------------------------------
  # input :
  #----------------------------------------------------------------------------------------------------------------

  def display()
    p "referral path : #{@referral_path}"
    p "source : #{@source}"
    p "medium : #{@medium}"
    p "keyword : #{@keyword}"
    super.display
  end


  #----------------------------------------------------------------------------------------------------------------
  # plan
  #----------------------------------------------------------------------------------------------------------------
  # enregistre la visite aupres du schelduler
  # planifie le referer et les pages
  #----------------------------------------------------------------------------------------------------------------
  # input :
  #----------------------------------------------------------------------------------------------------------------
  def plan(scheduler)
    begin
      #TODO enregistre le referer auprès du scheduler
      scheduler.at @start_date_time do
        browse
      end
    rescue Exception => e
      raise RefererException, e.message
    end
 end
    #---------------------------------------------------------------------------------------------
    # private
    #---------------------------------------------------------------------------------------------
    private
    #----------------------------------------------------------------------------------------------------------------
    # hostname
    #----------------------------------------------------------------------------------------------------------------
    # calcule le hostname en fonction de medium, source, referral_path
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def hostname
      "www.google.fr"
    end

    #----------------------------------------------------------------------------------------------------------------
    # page_path
    #----------------------------------------------------------------------------------------------------------------
    # calcule le hostname en fonction de medium, source, referral_path
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def page_path()
      "/"
    end
  end