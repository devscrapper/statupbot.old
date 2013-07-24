module Referers
  class Referer
    class RefererException < StandardError;
    end
   #----------------------------------------------------------------------------------------------------------
   # Source : chaque site référent a une origine ou source. Les sources possibles sont les suivantes :
   #    "Google" (nom d'un moteur de recherche),
   #    "facebook.com" (nom d'un site référent),
   #    "spring_newsletter" (nom de l'une de vos newsletters) et
   #    "directe" (visites réalisées par des internautes ayant saisi votre URL directement dans leur navigateur ou ayant ajouté votre site à leurs favoris).
   #----------------------------------------------------------------------------------------------------------
   # Support : chaque site référent est également associé à un support. Les supports possibles sont les suivants :
   #      "naturel" (recherche gratuite),
   #      "cpc" (coût par clic, donc les liens commerciaux),
   #      "site référent" (site référent),
   #      "e-mail" (nom d'un support personnalisé créé par vos soins),
   #      "aucun" (le support correspondant aux visites directes).
   #----------------------------------------------------------------------------------------------------------
   # Mot clé : les mots clés que recherchent les visiteurs sont généralement enregistrés dans le cas des sites référents de moteur de recherche.
   #  Il en est ainsi pour les recherches naturelles comme les liens commerciaux.
   #  Sachez, toutefois, qu'en cas d'utilisation d'une recherche SSL (par exemple,
   #  si l'utilisateur s'est connecté à un compte Google ou en cas d'utilisation de la barre de recherche Firefox), le mot clé prend la valeur (non fournie).
   #----------------------------------------------------------------------------------------------------------
   # Campagne désigne la campagne AdWords référente ou une campagne personnalisée dont vous êtes l'auteur.
    #----------------------------------------------------------------------------------------------------------
   # Contenu identifie un lien spécifique ou un élément de contenu au sein d'une campagne personnalisée.
   #   Par exemple, si vous disposez de deux liens d'incitation à l'action au sein d'un même e-mail,
   #   vous pouvez utiliser différentes valeurs de contenu pour les différencier, de façon à pouvoir identifier la version la plus efficace.
   #   Vous pouvez tirer parti des campagnes personnalisées pour inclure des balises dans les liens.
   # Vous pourrez ainsi utiliser vos propres valeurs personnalisées pour les paramètres "Campagne", "Support", "Source" et "Mot clé".
    #----------------------------------------------------------------------------------------------------------
    #             Referal         Campaign    Source                Medium      Keyword
    # NoReferer  (not set)        (not set)   (direct)              (none)      (not set)
    # Search     (not set)        (not set)    google*              organic     {key words}
    # Referral   {referal path}   (not set)   {referral hostname}   referral    (not set)
    #------------------------------------------------------------------------------------------------------------
    #             UTMCCT            UTMCCN    UTMCSR                UTMCMD      UTMCTR
    #------------------------------------------------------------------------------------------------------------
    #  * dans un premier temps on ne realise des recherches que par le portail google.
    # Pour cela la sélection est réalisé lors de la recuperation des données de GA
    #TODO: sélectionner la source google pour le medium organic => impact scraperbot/model/scraping/googleanalytics.rb
    #------------------------------------------------------------------------------------------------------------
    attr_reader :utmccn, # campaign
                :utmcsr, # source
                :utmcmd, # medium
                :utmctr, # keyword
                :utmcct  #referral
    :landing_page
    attr :logger

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
    def self.build(visit_hash, start_date_time, visit_id, landing_page)
      case visit_hash["medium"]
        when "(none)"
          return NoReferer.new(landing_page)
        when "organic"
          #TODO pas de search pour le moment rempalcer par un Noreferer
         # return NoReferer.new(landing_page)
          return Search.new(visit_hash["medium"], visit_hash["source"], visit_hash["keyword"], start_date_time, visit_id, landing_page)
        when "referral"
          return Referral.new(visit_hash["medium"], visit_hash["source"], visit_hash["referral_path"], start_date_time, visit_id, landing_page)
        else
          raise RefererException, "medium #{@medium} is unknonwn"
      end

    end

    def initialize(landing_page, utmcmd, utmcsr, utmcct, utmctr, utmccn="(not set")
      @landing_page = landing_page
      @utmcmd = utmcmd
      @utmcsr = utmcsr
      @utmcct = utmcct
      @utmctr = utmctr
      @utmccn = utmccn
    end

    def display()
      p self.to_s
    end

    def to_s()
      "utmcmd : #{@utmcmd}\n" + \
      "utmcsr : #{@utmcsr}\n" + \
      "utmcct : #{@utmcct}\n" + \
      "utmctr : #{@utmctr}\n" + \
      "utmccn : #{@utmccn}"
    end
  end
end

require_relative 'no_referer'
require_relative 'referral'
require_relative 'search'