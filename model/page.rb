require_relative 'communication'
require_relative '../lib/logging'
require_relative 'visitor_connection'
require_relative 'scheduler_connection'

class Page
  class PageException < StandardError;
  end

  attr :id,
       :url,
       :header,
       :properties_ga,
       :visit,
       :logger
  attr_reader :start_date_time
#  Start_date_time :  visit.start_time + delay
#  url : hostname + page_path

#----------------------------------------------------------------------------------------------------------------
# class methods
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# build
#----------------------------------------------------------------------------------------------------------------
# construit les pages à partir d'une visit de l'input flow
#----------------------------------------------------------------------------------------------------------------
# input :
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
#["pages", [{"id_uri"=>"19155", "delay_from_start"=>"10", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-cadaujac.htm", "title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}, {"id_uri"=>"19196", "delay_from_start"=>"15", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-le_pian_medoc_.htm", "title"=>"Centre d'\u00E9pilation laser LE PIAN M\u00C9DOC  centres de remise en forme LE PIAN M\u00C9DOC"}, {"id_uri"=>"19253", "delay_from_start"=>"39", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-yvrac.htm", "title"=>"Centre d'\u00E9pilation laser YVRAC centres de remise en forme YVRAC"}, {"id_uri"=>"115", "delay_from_start"=>"12", "hostname"=>"www.epilation-laser-definitive.info", "page_path"=>"/en/", "title"=>"Final Laser depilation"}]]  #----------------------------------------------------------------------------------------------------------------
  def self.build(visit_hash, start_date_time, visit_id)
    pages = []
    begin
      visit_hash["pages"].each { |page| pages << Page.new(page, start_date_time, visit_id) }
    rescue Exception => e
      raise PageException, e.message
    end
    pages
  end

#----------------------------------------------------------------------------------------------------------------
# plan
#----------------------------------------------------------------------------------------------------------------
# enregistre toutes les pages aupres du serveur scheduler
#----------------------------------------------------------------------------------------------------------------

  def self.plan(pages)
    last_date_time = pages[0].start_date_time
    begin
      pages.each { |page|
        Scheduler.plan(page)
        last_date_time = page.start_date_time if page.start_date_time > last_date_time
      }
    rescue Exception => e
      raise PageException, e.message
    end
    last_date_time
  end

  #----------------------------------------------------------------------------------------------------------------
  # send_properties_to_proxy
  #----------------------------------------------------------------------------------------------------------------
  # enregistre toutes les pages aupres du scheduler
  #----------------------------------------------------------------------------------------------------------------

  def self.send_properties_to_proxy(pages)
    pages.each { |page| page.send_properties_to_proxy() }
  end

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
  #----------------------------------------------------------------------------------------------------------------
  # {"id_uri"=>"19155",
  #"delay_from_start"=>"10",
  #"hostname"=>"centre-gironde.epilation-laser-definitive.info",
  #"page_path"=>"/ville-33-cadaujac.htm",
  #"title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}  cette variable ne sera pas utlisée car sera récupérer lors de l'exéution du scrip GA dans phantomjs
  def initialize(page, start_date_time, visit_id)
    @visit = visit_id
    @id = page["id_uri"]
    @start_date_time = start_date_time + page["delay_from_start"].to_i
    @url = "#{page["hostname"]}#{page["page_path"]}"

  end

#----------------------------------------------------------------------------------------------------------------
# browse
#----------------------------------------------------------------------------------------------------------------
# browse une page
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------

  def browse()
    @visit = Visit.get_visit(@visit)  # Remplace l'id visit par l'adresse de l'objet visit
    begin
      Visitors.browse_url(@visit.visitor, @url)
    rescue Exception => e
      raise PageException, e.message
    end
  end

#----------------------------------------------------------------------------------------------------------------
# display
#----------------------------------------------------------------------------------------------------------------
# affiche le contenu d'un referer
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------

  def display()
    p "id page : #{@id}"
    p "start_date_time : #{@start_date_time}"
    p "url : #{@url}"
    p "header : #{@header}"
    p "properties_ga : #{@properties_ga}"
    @visit.visitor.display
  end

#----------------------------------------------------------------------------------------------------------------
# send_properties_to_proxy
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------
  def send_properties_to_proxy()
    p "send properties of page #{@id} to proxy"
  end


  #----------------------------------------------------------------------------------------------------------------
  # plan
  #----------------------------------------------------------------------------------------------------------------
  # enregistre l'action de browsing de la page aupres du schelduler
  #----------------------------------------------------------------------------------------------------------------
  # input : scheduler
  #----------------------------------------------------------------------------------------------------------------
  def plan(scheduler)
    begin
      scheduler.at @start_date_time do
        browse
      end
    rescue Exception => e
      raise PageException, "page #{@id} is not planed : #{e.message}"
    end
  end

  #---------------------------------------------------------------------------------------------
  # private
  #---------------------------------------------------------------------------------------------
  private

end