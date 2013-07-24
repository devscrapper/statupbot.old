require_relative 'communication'
require_relative '../lib/logging'
require_relative 'visitor'
require_relative 'page'
require_relative 'visitor_factory_connection'
require_relative 'referer/referer'

class Visit
  class VisitException < StandardError;
  end
  EOFLINE = "\n"
  @@sem_visits_list = Mutex.new
  @@visits_list = {}
  attr :start_date_time,
       :pages
  attr_accessor :id,
                :visitor,
                :logger,
                :referer
  attr_reader :started # assure que la visit est démarré, cad que lon a un visitor et un browser avec un webdriver operationnel pour eviter de browser des referer ou page sans visit.


  # a remplacer par un test lors du open d'une page par le raise d'une exception si absence de webdriver. (17 juin 2013)
  #----------------------------------------------------------------------------------------------------------------
  # class methods
  #----------------------------------------------------------------------------------------------------------------
  #----------------------------------------------------------------------------------------------------------------
  # build
  #----------------------------------------------------------------------------------------------------------------
  # construit les visites à partir du input flow
  #----------------------------------------------------------------------------------------------------------------
  # input :
  # flow : published-visits_label_date_hour.json
  #----------------------------------------------------------------------------------------------------------------
  def self.build(visits_input_flow)
    visits = []
    begin
      visits_input_flow.foreach(EOFLINE) { |visit| visits << Visit.new(JSON.parse(visit)) }
    rescue Exception => e
      raise VisitException, "cannot build visits : #{e.message}"
    end
    visits
  end

  def self.get_visit(id)
    @@sem_visits_list.synchronize { @@visits_list[id] }
  end

  def self.visits()
    @@visits_list
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
  def initialize(visit)
#    @logger = Logging::Log.new(self, :staging => $staging, :debugging => $debug)
    begin
      @id = visit["id_visit"]

      #TODO a supprimer DEBUT
      #@start_date_time = Time.parse(visit["start_date_time"]) - 5 * 60
      @start_date_time = Time.now + 5
      #TODO a supprimer FIN
      @visitor = ReturnVisitor.new(visit) if visit["return_visitor"] == "true"
      @visitor = NewVisitor.new(visit) unless visit["return_visitor"] == "true"
      @pages = Page.build(visit, @start_date_time, @id)
      landing_page = Page.landing_page(@pages)
      @referer = Referers::Referer.build(visit, @start_date_time, @id, landing_page)
        #@referer = Referer.new(visit, @start_date_time, @id, landing_page)
    rescue Exception => e
      raise VisitException, "new visit #{visit["id_visit"]} failed, #{e.message}"
    end
  end

  def add_visit()
    @@sem_visits_list.synchronize { @@visits_list[@id] = self }
  end

  def del_visit()
    @@sem_visits_list.synchronize { @@visits_list[@id] = nil }
  end

  #----------------------------------------------------------------------------------------------------------------
  # display
  #----------------------------------------------------------------------------------------------------------------
  # affiche le contenu d'une visite
  #----------------------------------------------------------------------------------------------------------------
  # input :
  #----------------------------------------------------------------------------------------------------------------

  def display()
    p "id visit : #{@id}"
    p "start time : #{@start_date_time}"
    @visitor.display
    @referer.display
    @pages.each { |page| page.display }
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
      scheduler.at @start_date_time do
        start
      end

      Scheduler.plan(@referer)

      stop_date_time = Page.plan(@pages)

      scheduler.at stop_date_time + 5 * 60 do
        stop
      end
    rescue Exception => e
      raise VisitException, "visit #{@id} is not planed, #{e.message}"
    end

  end

#----------------------------------------------------------------------------------------------------------------
# start
#----------------------------------------------------------------------------------------------------------------
# démarre une visite :
# - assigne un visitor
# - ? send properties of referer to proxy ?
# - ? send properties of page to proxy ?
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------
  def start()
    begin
      add_visit()
      @visitor.assign_visitor(@referer)
    rescue Exception => e
      raise VisitException, "visit #{@id} is not started, #{e.message}"
    end
  end

#----------------------------------------------------------------------------------------------------------------
# stop
#----------------------------------------------------------------------------------------------------------------
# arrete une visite
# libere le visitor
# supprimer le referer, les pages
#----------------------------------------------------------------------------------------------------------------
# input :
#----------------------------------------------------------------------------------------------------------------
  def stop()
    begin
      del_visit()
      @visitor.unassign_visitor
    rescue Exception => e
      raise VisitException, "visit #{@id} is not stoped, #{e.message}"
    end
  end


#---------------------------------------------------------------------------------------------
# private
#---------------------------------------------------------------------------------------------
  private

end