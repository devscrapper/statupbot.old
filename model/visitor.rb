require 'uuid'
require_relative 'communication'
require_relative '../lib/logging'
require_relative 'flow'
require_relative 'geolocation/geolocation'
require_relative 'geolocation/direct'
require_relative 'geolocation/proxy'
require_relative 'geolocation/tor'
require_relative 'browser/browser'
require_relative 'browser/firefox'
require_relative 'browser/internet_explorer'
require_relative 'browser/chrome'
require_relative 'customize_queries_connection'
require_relative 'custom_gif_request/custom_gif_request'
require_relative 'nationality/nationality'
class Visitor
  class VisitorException < StandardError;
  end


  attr_accessor :id,
                :browser,
                :nationality,
                :geolocation

  include CustomGifRequest
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
  def initialize(visit)
    @id = UUID.generate
    @nationality = Nationalities::French.new() # par defaut
    @browser = Browsers::Browser.build(visit, @id)
    @geolocation = Geolocations::Geolocation.build(visit)
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

  #----------------------------------------------------------------------------------------------------------------
  # assign_visitor
  #----------------------------------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------------------------------
  # input :
  #----------------------------------------------------------------------------------------------------------------
  def assign_visitor(visitor, referer)
    @id = visitor.id if visitor.is_a?(ReturnVisitor)
    @browser = visitor.browser
    begin
      c = CustomGifRequest.new(self, referer)
    rescue Exception => e
      raise VisitorException, "CustomGifRequest is not created for visitor #{@id} : #{e.message}"
    end
    begin
      CustomizeQueries.add_custom_gif(c)
    rescue Exception => e
      raise VisitorException, "CustomGifRequest for visitor #{@id} did not send to customize queries server: #{e.message}"
    end
  end

  #----------------------------------------------------------------------------------------------------------------
  # unassign_visitor
  #----------------------------------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------------------------------
  # input :
  #----------------------------------------------------------------------------------------------------------------

  def unassign_visitor()
    begin
      VisitorFactory.unassign_visitor(self)
    rescue Exception => e
      raise VisitorException, "unassign of visitor #{@id} failed : #{e.message}"
    end
  end

  def accept_language()
    @nationality.accept_language
  end

  def utmcs()
    @nationality.utmcs
  end

  def utmul()
    @nationality.utmul_for_browser(@browser)
  end

  #---------------------------------------------------------------------------------------------
  # private
  #---------------------------------------------------------------------------------------------
  private

end

class NewVisitor < Visitor
  class NewVisitorException < StandardError;
  end

  def assign_visitor(referer)
    begin
      VisitorFactory.assign_new_visitor(self).pop { |visitor| super(visitor, referer) }
    rescue Exception => e
      raise NewVisitorException, "assign of visitor #{@id} failed : #{e.message}"
    end
  end
end

class ReturnVisitor < Visitor
  class ReturnVisitorException < StandardError;
  end

  def assign_visitor(referer)
    begin
      VisitorFactory.assign_return_visitor(self).pop { |visitor| super(visitor, referer) }
    rescue Exception => e
      raise ReturnVisitorException, "assign of visitor #{@id} failed : #{e.message}"
    end
  end
end