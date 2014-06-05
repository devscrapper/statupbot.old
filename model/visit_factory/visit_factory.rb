require_relative '../visitor_factory/public'
require 'rubygems' # if you use RubyGems
require 'eventmachine'
require 'rufus-scheduler'
require 'uuid'

module VisitFactory
  #--------------------------------------------------------------------------------------------------------------------
  # constant
  #--------------------------------------------------------------------------------------------------------------------
  TMP = Pathname(File.join(File.dirname(__FILE__), "..", "..", "tmp")).realpath
  #TODO meo ces données dans statupweb
  MIN_COUNT_PAGE_ADVERTISER = 10 # nombre de page min consultées chez l'advertiser : fourni par statupweb
  MAX_COUNT_PAGE_ADVERTISER = 15 # nombre de page max consultées chez l'advertiser : fourni par statupweb
  MIN_DURATION_PAGE_ADVERTISER = 60 # durée de lecture min d'une page max consultées chez l'advertiser : fourni par statupweb
  MAX_DURATION_PAGE_ADVERTISER = 120 # durée de lecture max d'une page max consultées chez l'advertiser : fourni par statupweb
  PERCENT_LOCAL_PAGE_ADVERTISER = 80 # pourcentage de page consultées localement à l'advertiser fournit par statupweb
  DURATION_REFERRAL = 20 # durée de lecture du referral : fourni par statupweb
  MIN_COUNT_PAGE_ORGANIC = 4 #nombre min de page de resultat du moteur de recherche consultées : fourni par statupweb
  MAX_COUNT_PAGE_ORGANIC = 6 #nombre min de page de resultat du moteur de recherche consultées : fourni par statupweb
  MIN_DURATION_PAGE_ORGANIC = 10 #durée de lecture min d'une page de resultat fourni par le moteur de recherche : fourni par statupweb
  MAX_DURATION_PAGE_ORGANIC = 30 #durée de lecture max d'une page de resultat fourni par le moteur de recherche : fourni par statupweb

  #--------------------------------------------------------------------------------------------------------------------
  # Global variables
  #--------------------------------------------------------------------------------------------------------------------
  @@scheduler = Rufus::Scheduler::start_new
  @@logger = nil

  #--------------------------------------------------------------------------------------------------------------------
  # Communication
  #--------------------------------------------------------------------------------------------------------------------
  class PlanVisitConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol


    def initialize(logger)
      @@logger = logger
    end

    def receive_object(data)
      @@logger.an_event.debug "BEGIN PlanVisitConnection.receive_object"

      close_connection

      begin
        label_website = data[:website_label]
        @@logger.an_event.debug "label website #{label_website}"

        input_visit_details = data[:visit_details]
        input_visit_details["label"] = label_website
        @@logger.an_event.debug "input visit details #{input_visit_details}"

        tmp_visit_yaml = convert_input_to_tmp_visit_details(input_visit_details)


        @@logger.an_event.debug "tmp visit yaml #{tmp_visit_yaml}"

        tmp_visit_yaml_filename = File.join(TMP, "#{label_website}-#{tmp_visit_yaml[:id_visit]}.yaml")
        File.open(tmp_visit_yaml_filename, "w:UTF-8").write(tmp_visit_yaml.to_yaml)

        @@logger.an_event.info "tmp visit details #{tmp_visit_yaml[:id_visit]} save to tmp dir (#{TMP}) for website #{label_website}"

        start_date_time = tmp_visit_yaml[:start_date_time]
        @@logger.an_event.debug "start_date_time #{start_date_time}"

        plan_visit(tmp_visit_yaml_filename, start_date_time)

        @@logger.an_event.info "visit #{tmp_visit_yaml[:id_visit]} of website #{label_website} plan at #{start_date_time}"
      rescue Exception => e

        @@logger.an_event.error "tmp visit details #{tmp_visit_yaml[:id_visit]} save to tmp dir : #{e.message}"
      else

      ensure

        @@logger.an_event.debug "END PlanVisitConnection.receive_object"

      end

    end

    # prend en entree un flux json qui décrit la visit
    # retour un flux yaml qui définit la visit au format attendu par visitor_bot
    def convert_input_to_tmp_visit_details(visit_json)
      @@logger.an_event.debug "BEGIN PlanVisitConnection.convert_input_to_tmp_visit_details"

      begin
        advertiser_durations_size = Random.rand(MIN_COUNT_PAGE_ADVERTISER..MAX_COUNT_PAGE_ADVERTISER) # calculé par engine_bot
        organic_durations_size = Random.rand(MIN_COUNT_PAGE_ORGANIC..MAX_COUNT_PAGE_ORGANIC) # calculé par engine_bot
        visit = {:id_visit => visit_json["id_visit"],
                 :start_date_time => Time.parse(visit_json["start_date_time"]),
                 :durations => visit_json["pages"].map { |page| page["delay_from_start"].to_i },
                 :website => {:label => visit_json["label"],
                              :many_hostname => :true,
                              :many_account_ga => :no},
                 :visitor => {:return_visitor => visit_json["return_visitor"]=="yes" ? :true : :false,
                              :id => UUID.generate,
                              :browser => {:name => visit_json["browser"],
                                           :version => visit_json["browser_version"],
                                           :operating_system => visit_json["operating_system"],
                                           :operating_system_version => visit_json["operating_system_version"],
                                           :flash_version => visit_json["flash_version"],
                                           :java_enabled => visit_json["java_enabled"],
                                           :screens_colors => visit_json["screens_colors"],
                                           :screen_resolution => visit_json["screen_resolution"]
                              }
                 },
                 :referrer => {:referral_path => visit_json["referral_path"],
                               :source => visit_json["source"],
                               :medium => visit_json["medium"],
                               :keyword => generate_keywords(visit_json["medium"], visit_json["keyword"], visit_json["pages"][0]["title"]) #genere un tableau de mot clé pour pallier à l'échec des recherches et mieux simuler le comportement
                 },
                 :landing => {:fqdn => visit_json["pages"][0]["hostname"],
                              :page_path => visit_json["pages"][0]["page_path"]
                 },
                 :advert => visit_json["pub"].nil? ? {:advertising => :none} : {:advertising => visit_json["pub"].to_sym,
                                                                                :advertiser => {:durations => Array.new(advertiser_durations_size).fill { Random.rand(MIN_DURATION_PAGE_ADVERTISER..MAX_DURATION_PAGE_ADVERTISER) }, #calculé par engine_bot
                                                                                                :arounds => Array.new(advertiser_durations_size).fill(:outside_fqdn).fill(:inside_fqdn, 0, (advertiser_durations_size * PERCENT_LOCAL_PAGE_ADVERTISER/100).round(0))} #calculé par engine_bot
                 }
        }

        case visit[:referrer][:medium]
          when "(none)"
          when "referral"
            visit[:referrer][:duration] = DURATION_REFERRAL
          when "organic"
            visit[:referrer][:durations] = Array.new(organic_durations_size).fill { Random.rand(MIN_DURATION_PAGE_ORGANIC..MAX_DURATION_PAGE_ORGANIC) }
        end

      rescue Exception => e

        @@logger.an_event.error "input visit details #{visit_json["id_visit"]} not convert to tmp visit details #{visit[:id_visit]} : #{e.message}"
        raise "input visit details #{visit_json["id_visit"]} not convert to tmp visit details}"

      else

        @@logger.an_event.debug "input visit details #{visit_json["id_visit"]} convert to tmp visit details #{visit[:id_visit]}"
        return visit

      ensure
        @@logger.an_event.debug "BEGIN PlanVisitConnection.convert_input_to_tmp_visit_details"
      end
    end

    def generate_keywords(medium, keywords, title)
      #TODO le comportement est basic, il devra etre enrichi pour mieux simuler un comportement naturel et mettre en dernier ressort les mots du title
      #TODO penser egalement à produire des search qui n'aboutissent jamais dans le engine bot en fonction dun poourcentage determiner par statupweb
      [keywords, title] if keywords != "(not set)" and medium == "organic"
    end

    def plan_visit(tmp_visit_yaml_filename, start_date_time)
      #TODO terminer la plan_visit sans forcer la date de declenchement
      @@logger.an_event.debug "BEGIN PlanVisitConnection.plan_visit"
      begin
        @@scheduler.at start_date_time do
          #TODO A SUPPRIMER puopr que sa marche
          VisitorFactory::assign_new_visitor(tmp_visit_yaml_filename, @@logger)
        end
      rescue Exception => e
        @@logger.an_event.error "not assign visit to a visitor : #{e.message}"
        raise "not assign a visit to a visitor"
      else

      ensure
        @@logger.an_event.debug "END PlanVisitConnection.plan_visit"
      end
    end
  end


end