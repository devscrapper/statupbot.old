require_relative 'geolocation/geolocation'
require_relative 'nationality/nationality'
require_relative '../../model/browser/webdriver/browser'
require_relative '../../model/browser/sahi.co.in/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require_relative '../../lib/error'
require 'pathname'

#require_relative 'customize_queries_connection'
#require_relative 'custom_gif_request/custom_gif_request'
#TODO reviser globalement la gestion des erreurs et des exceptions
module Visitors
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include Geolocations
  include Nationalities
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings


  class Visitor
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Geolocations
    include Nationalities
    include Browsers
    include Visits::Referrers
    include Visits::Advertisings

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------
    class VisitorError < Error
    end
    ARGUMENT_UNDEFINE = 600
    VISITOR_NOT_CREATE = 601 # à remonter en code retour de statupbot
    SEARCH_NOT_FOUND_LANDING_LINK = 602 # à remonter en code retour de statupbot
    VISITOR_NOT_BORN = 603 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_LANDING_PAGE = 604 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_REFERRAL_PAGE = 605 # à remonter en code retour de statupbot
    VISITOR_NOT_FOUND_LANDING_LINK = 606 # à remonter en code retour de statupbot
    VISITOR_NOT_CLICK_ON_LANDING = 607 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_SEARCH_PAGE = 608 # à remonter en code retour de statupbot
    VISITOR_NOT_INHUME = 609 # à remonter en code retour de statupbot
    NO_MORE_RESULT_PAGE = 610
    VISIT_NOT_COMPLETE = 611
    CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE = 612
    VISITOR_NOT_CLOSE = 613
    VISITOR_NOT_DIE = 614
    NONE_KEYWORDS_FIND_LANDING_LINK = 615
    VISITOR_NOT_OPEN = 616
    LOG_VISITOR_NOT_DELETE = 617

    #----------------------------------------------------------------------------------------------------------------
    # constants
    #----------------------------------------------------------------------------------------------------------------
    DIR_VISITORS = Pathname(File.join(File.dirname(__FILE__), '..', '..', 'visitors')).realpath
    #----------------------------------------------------------------------------------------------------------------
    # attributs
    #----------------------------------------------------------------------------------------------------------------
    attr_accessor :id,
                  :browser,
                  :home, #repertoire d'execution du visitor
                  :proxy, #sahi : utilise le proxy sahi
                  # webdriver : n'utilise pas le proxy
                  :geolocation # webdriver : utilise la geolocation car il n'y a pas de proxy,
    # sahi : n'utilise pas geolocation car pris en charge par le proxy sahi


    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    def self.build(visitor_details)
      #exist_pub_in_visit = true si il existe une pub dans la visit alors on utilise un browser de type webdriver
      #sinon un browser de type sahi
      @@logger.an_event.debug "BEGIN Visitor.build"
      @@logger.an_event.debug "visitor_details #{visitor_details}"
      raise VisitorError.new(ARGUMENT_UNDEFINE), "visitor_details undefine" if visitor_details.nil?

      begin
        # Pour le moment on ne travaille qu'avec SAHI
        return Visitor.new(visitor_details, :sahi)
      rescue Exception => e
        @@logger.an_event.debug "END Visitor.build"
        raise e
      end
      @@logger.an_event.debug "END Visitor.build"
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------
    # born
    #-----------------------------------------------------------------------------------------------------------------
    # input : none
    # output : none
    # exception :
    # StandardError :
    #
    #-----------------------------------------------------------------------------------------------------------------
    #  demarre le proxy sahi qui fait office de visitor
    #-----------------------------------------------------------------------------------------------------------------
    def born
      @@logger.an_event.debug "BEGIN Visitor.born"
      begin
        @proxy.start

        @@logger.an_event.info "visitor #{@id} born"

      rescue Error, Exception => e
        @@logger.an_event.error "visitor #{@id} not born : #{e.message}"
        raise VisitorError.new(VISITOR_NOT_BORN, e), "visitor #{@id} not born"
      ensure
        @@logger.an_event.debug "END Visitor.born"
      end
    end


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
    def initialize(visitor_details, browser_type)
      @@logger.an_event.debug "BEGIN Visitor.initialize"

      @@logger.an_event.debug "visitor detail #{visitor_details}"
      @@logger.an_event.debug "browser type #{browser_type}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "visitor_details undefine" if visitor_details.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "browser_type undefine" if browser_type.nil? or browser_type == ""

      @id = visitor_details[:id]

      if browser_type == :sahi
        @home = File.join(DIR_VISITORS, @id)

        begin
          #------------------------------------------------------------------------------------------------------------
          #
          # on fait du nettoyage pour eviter de perturber le proxy avec un paramètrage bancal
          # creation du repertoitre d'execution du visitor
          #
          #------------------------------------------------------------------------------------------------------------

          if File.exist?(@home)
            FileUtils.rm_r(@home, :force => true) if File.exist?(@home)
            @@logger.an_event.debug "clean config files visitor dir #{@home}"
          end
          FileUtils.mkdir_p(@home)

          @@logger.an_event.debug "visitor #{@id} create runtime directory #{@home}"

          #------------------------------------------------------------------------------------------------------------
          #
          #Configure SAHI PROXY
          #
          #------------------------------------------------------------------------------------------------------------

          @proxy = Browsers::SahiCoIn::Proxy.new(@home,
                                                 visitor_details[:browser][:listening_port_proxy],
                                                 visitor_details[:browser][:proxy_ip],
                                                 visitor_details[:browser][:proxy_port],
                                                 visitor_details[:browser][:proxy_user],
                                                 visitor_details[:browser][:proxy_pwd])

          @@logger.an_event.debug "visitor #{@id} configure sahi proxy on listening port = #{@proxy.listening_port_proxy}"

          #------------------------------------------------------------------------------------------------------------
          #
          # configure Browser
          #
          #------------------------------------------------------------------------------------------------------------
          @browser = Browsers::SahiCoIn::Browser.build(@home,
                                                       visitor_details[:browser])

          @@logger.an_event.debug "visitor #{@id} configure browser #{@browser.name} #{@browser.id}"

          @browser.deploy_properties(@home) if @browser.is_a?(Browsers::SahiCoIn::Opera)

          @@logger.an_event.debug "visitor #{@id} create"

          @@logger.an_event.info "visitor #{@id} create runtime directory, config his proxy Sahi, config his browser"
        rescue Error => e
          @@logger.an_event.error "visitor #{@id} not create : #{e.message}"
          raise VisitorError.new(VISITOR_NOT_CREATE, e), "visitor #{@id} not create"

        ensure
          @@logger.an_event.debug "END Visitor.initialize"
        end


      else
#@geolocation = Geolocation.build() #TODO a revisiter avec la mise en oeuvre des web proxy d'internet
#                                   #TODO peut on partager les proxy entre visiteur de site different ?
#@browser = Browsers::Webdriver::Browser.build(visitor_details[:browser])
#@browser.profile = @geolocation.update_profile(@browser.profile)
      end

    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # demarre un proxy :
    # inputs

    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def browse(referrer)
      @@logger.an_event.debug "BEGIN Visitor.browse"
      @@logger.an_event.debug "referrer #{referrer.inspect}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer landing url undefine" if referrer.landing_url.nil?


      landing_page = nil

      case referrer
        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer DIRECT
        #
        #---------------------------------------------------------------------------------------------------------------
        when Direct
          begin
            landing_page = @browser.display_start_page(referrer.landing_url, @id)

            @@logger.an_event.info "visitor #{@id} browse landing page #{referrer.landing_url.to_s}"

          rescue Error, Exception => e
            @@logger.an_event.error "visitor #{@id} not browse landing url #{referrer.landing_url.to_s} : #{e.message}"
            raise VisitorError.new(VISITOR_NOT_BROWSE_LANDING_PAGE, e), "visitor #{@id} not browse landing page #{referrer.landing_url.to_s}"
          else
            return landing_page
          ensure
            @@logger.an_event.debug "END Visitor.browse"
          end


        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer REFERRAL
        #
        #---------------------------------------------------------------------------------------------------------------
        when Referral
          raise VisitorError.new(ARGUMENT_UNDEFINE), "referral page url undefine" if referrer.page_url.nil?
          referral_page = nil
          landing_link = nil
          begin

            referral_page = @browser.display_start_page(referrer.page_url, @id)

            @@logger.an_event.info "visitor #{@id} browse referral page #{referral_page.url.to_s}"

            referral_page.duration = referrer.duration
            read(referral_page)

          rescue Error, Exception => e
            @@logger.an_event.error "visitor #{@id} not browse referral url #{referrer.page_url.to_s} : #{e.message}"
            @@logger.an_event.debug "END Visitor.browse"
            raise VisitorError.new(VISITOR_NOT_BROWSE_REFERRAL_PAGE, e), "visitor #{@id} not browse referral url #{referrer.page_url.to_s}"
          end

          begin
            landing_link = referral_page.link_by_url(referrer.landing_url)

          rescue Error => e
            @@logger.an_event.error "visitor #{@id} not found landing link #{referrer.landing_url.to_s} in referral page #{referral_page.url.to_s} : #{e.message}"
            @@logger.an_event.debug "END Visitor.browse"
            raise VisitorError.new(VISITOR_NOT_FOUND_LANDING_LINK, e), "visitor #{@id} not found landing link #{referrer.landing_url.to_s} in referral page #{referral_page.url.to_s}"
          end

          @@logger.an_event.info "visitor #{@id} found landing link #{referrer.landing_url.to_s} in referral page #{referral_page.url.to_s}"

          begin
            landing_page = @browser.click_on(landing_link)
            @@logger.an_event.info "visitor #{@id} click on landing link #{landing_link.url.to_s}"

          rescue Error, Exception => e
            @@logger.an_event.error "visitor #{@id} not click on landing url #{landing_link.url.to_s} : #{e.message}"
            raise VisitorError.new(VISITOR_NOT_CLICK_ON_LANDING, e), "visitor #{@id} not click on landing url #{landing_link.url.to_s}"
          else
            return landing_page
          ensure
            @@logger.an_event.debug "END Visitor.browse"
          end

        #---------------------------------------------------------------------------------------------------------------
        #
        # Referrer SEARCH
        #
        #---------------------------------------------------------------------------------------------------------------
        when Search
          raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer landing url undefine" if referrer.keywords.nil?

          referrer.keywords = [referrer.keywords] if referrer.keywords.is_a?(String)
          begin
            @browser.display_start_page(referrer.engine_search.page_url, @id)

            @@logger.an_event.info "visitor #{@id} browse engine search page #{referrer.engine_search.page_url}"

          rescue Error, Exception => e
            @@logger.an_event.error "visitor #{@id} not browse engine search url #{referrer.engine_search.page_url.to_s} : #{e.message}"
            @@logger.an_event.debug "END Visitor.browse"
            raise VisitorError.new(VISITOR_NOT_BROWSE_SEARCH_PAGE, e), "visitor #{@id} not browse engine search url #{referrer.engine_search.page_url.to_s}"
          end


          begin
            landing_link = many_search(referrer)

            @@logger.an_event.info "visitor #{@id} found landing link #{landing_link.url.to_s} in results search pages"

          rescue Exception => e
            @@logger.an_event.error "visitor #{@id} not found landing link #{referrer.landing_url.to_s} in results search pages : #{e.message}"
            @@logger.an_event.debug "END Visitor.browse"
            raise VisitorError.new(VISITOR_NOT_FOUND_LANDING_LINK, e), "visitor #{@id} not found landing link #{referrer.landing_url.to_s} in results search pages"
          end

          begin
            landing_page = @browser.click_on(landing_link)

            @@logger.an_event.info "visitor #{@id} click on landing url #{landing_link.url.to_s}"

          rescue Error, Exception => e
            @@logger.an_event.error "visitor #{@id} not click on landing link #{landing_link.url.to_s} : #{e.message}"
            raise VisitorError.new(VISITOR_NOT_CLICK_ON_LANDING, e), "visitor #{@id} not click on landing link #{landing_link.url.to_s}"
          else
            return landing_page
          ensure
            @@logger.an_event.debug "END Visitor.browse"
          end
      end


    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # demarre un proxy :
    # inputs

    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------

    def close_browser
      @@logger.an_event.debug "BEGIN Visitor.close "
      begin
        @browser.quit
        @@logger.an_event.info "visitor #{@id} close his browser #{@browser.name}"
      rescue Error => e
        @@logger.an_event.error "visitor #{@id} not close his browser #{@browser.name} #{@browser.id} : #{e.message}"
        raise VisitorError.new(VISITOR_NOT_CLOSE, e), "visitor #{@id} not close his browser #{@browser.name} #{@browser.id}"
      ensure
        @@logger.an_event.debug "END Visitor.close"
      end
    end

#----------------------------------------------------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------------------------------------------------
# demarre un proxy :
# inputs

# output
# StandardError
# StandardError
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------
    def die
      @@logger.an_event.debug "BEGIN Visitor.die"
      begin
        @proxy.stop
        @@logger.an_event.info "visitor #{@id} die"
      rescue Error => e
        @@logger.an_event.error "visitor #{@id} not die : #{e.message}"
        raise VisitorError.new(VISITOR_NOT_DIE, e), "visitor #{@id} not die"
      ensure
        @@logger.an_event.debug "END Visitor.die"
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # supprimer les fichier de log
    # inputs

    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def delete_log
      @@logger.an_event.debug "BEGIN Visitor.delete_log"

      begin
        dir = Pathname(File.join(File.dirname(__FILE__), "..", "log")).realpath
        files = File.join(dir, "visitor_bot_#{@id}.{*}")
        FileUtils.rm_r(Dir.glob(files), :force => true)

      rescue Exception => e

        @@logger.an_event.error "not delete log file visitor #{@id} : #{e.message}"
        raise VisitorError.new(LOG_VISITOR_NOT_DELETE), "not delete log file visitor #{@id}"

      ensure
        @@logger.an_event.debug "END Visitor.delete_log"
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # demarre un proxy :
    # inputs

    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def inhume()
      @@logger.an_event.debug "BEGIN Visitor.inhume"
      try_count = 0
      max_try_count = 3
      begin
        @proxy.delete_config
        FileUtils.rm_r(@home) if File.exist?(@home)
        @@logger.an_event.info "visitor #{@id} inhume"
      rescue Exception => e
        @@logger.an_event.debug "visitor #{@id} not inhume, try #{try_count}"
        sleep (1)
        try_count +=1
        retry if try_count < max_try_count
        @@logger.an_event.debug "visitor #{@id} not inhume : #{e.message}"
        raise VisitorError.new(VISITOR_NOT_INHUME, e), "visitor #{@id} not inhume"
      ensure
        @@logger.an_event.debug "END Visitor.inhume"
      end
    end

#-----------------------------------------------------------------------------------------------------------------
# many_search
#-----------------------------------------------------------------------------------------------------------------
# input : objet Referrer
# output : un objet Page
# exception :
# StandardError :
# si Referrer n'est pas defini
# si landing_link not found dans les pages de resultats de toutes les recherches
#-----------------------------------------------------------------------------------------------------------------
# permet de realiser plusieurs recherche avec à chaque fois une list de mot clé différent
# cette liste de mot clé sera calculé par scraperbot en fonction d'un paramètage de statupweb
# cela permetra par exemple de realisé des recherches qui échouent
#-----------------------------------------------------------------------------------------------------------------
    def many_search(referrer)
      @@logger.an_event.debug "BEGIN Visitor.many_search"
      #TODO meo plusieurs methodes pour saisir les mots clés et les choisir aléatoirement :
      #TODO afficher la page google.fr, comme c'est le cas actuellement
      #TODO dans la derniere page des resultats, saisir les nouveaux mot clés dans la zone idoine.
      @@logger.an_event.debug "keywords #{referrer.keywords}"
      @@logger.an_event.debug "engine_search #{referrer.engine_search}"
      @@logger.an_event.debug "durations #{referrer.durations}"
      @@logger.an_event.debug "landing_url #{referrer.landing_url}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer keywords undefine" if referrer.keywords.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer engine_search undefine" if referrer.engine_search.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer durations undefine" if referrer.durations.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "referrer landing_url undefine" if referrer.landing_url.nil?

      i = 0
      landing_link = nil
      begin
        landing_link = search(referrer.keywords[i],
                              referrer.engine_search,
                              referrer.durations.map { |d| d },
                              referrer.landing_url)
      rescue Error => e
        #erreur technique remonté par le browser lors de la recherche
        raise e
      rescue Exception => e
        i+=1
        if i < referrer.keywords.size
          retry
        else
          raise VisitorError.new(NONE_KEYWORDS_FIND_LANDING_LINK), "visitor  #{@id} not found landing link"
        end
      else
        return landing_link
      ensure
        @@logger.an_event.debug "END Visitor.many_search"
      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # demarre un proxy :
    # inputs

    # output
    # StandardError
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def open_browser
      @@logger.an_event.debug "BEGIN Visitor.open_browser"
      begin
        @browser.open
        @@logger.an_event.info "visitor #{@id} open his browser #{@browser.name}"
      rescue Error => e
        @@logger.an_event.error "visitor #{@id} not open his browser #{@browser.name} #{@browser.id} : #{e.message}"
        raise VisitorError.new(VISITOR_NOT_OPEN, e), "visitor #{@id} not open his browser #{@browser.name} #{@browser.id}"
      ensure
        @@logger.an_event.debug "END Visitor.open_browser"
      end
    end

#----------------------------------------------------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------------------------------------------------
# demarre un proxy :
# inputs

# output
# StandardError
# StandardError
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------
    def read(page)
      @@logger.an_event.debug "BEGIN Visitor.read"
      @@logger.an_event.debug "page #{page.to_s}"
      raise VisitorError.new(ARGUMENT_UNDEFINE), "page undefine" if page.nil?
      @@logger.an_event.info "visitor #{@id} read #{page.url.to_s} during #{page.sleeping_time}s"
      @browser.wait_on(page)
      @@logger.an_event.debug "END Visitor.read"
    end

    #-----------------------------------------------------------------------------------------------------------------
    # search
    #-----------------------------------------------------------------------------------------------------------------
    # input :
    # keywords : les mots de la recherche
    # engine_search : le moteur utilisé pou la recherche
    # durations : le temps d'attente pas page de résultat de la recherche, fixe egalement le nombre de page de la recherche
    # landing_url : l'url recherchée dans chaque page de résultat
    # output : un objet Page
    # exception :
    # StandardError :
    # si keywords n'est pas defini
    # si engine_search n'est pas défini
    # di durations n'est pas défini
    # si landing url n'est pas defini
    # si landing_link not found dans les pages de resultats de la recherche avce ces mots clés
    #-----------------------------------------------------------------------------------------------------------------
    #
    #-----------------------------------------------------------------------------------------------------------------
    def search(keywords, engine_search, durations, landing_url)
      @@logger.an_event.debug "BEGIN Visitor.search"

      @@logger.an_event.debug "keywords #{keywords}"
      @@logger.an_event.debug "engine search #{engine_search}"
      @@logger.an_event.debug "durations #{durations}"
      @@logger.an_event.debug "landing url #{landing_url}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "keywords undefine" if keywords.nil? or keywords == ""
      raise VisitorError.new(ARGUMENT_UNDEFINE), "engine search undefine" if engine_search.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "durations undefine" if durations.nil? or durations.size == 0
      raise VisitorError.new(ARGUMENT_UNDEFINE), "landing url undefine" if landing_url.nil?
      #---------------------------------------------------------------------------------------------------------------
      #
      # search keyword in engine
      #
      #---------------------------------------------------------------------------------------------------------------
      begin
        results_page = @browser.search(keywords, engine_search)

        @@logger.an_event.info "visitor #{@id} browse first results page with keywords #{keywords} on #{engine_search.class}"

      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} not browse first results page with keywords #{keywords} on #{engine_search.class} : #{e.message}"
        @@logger.an_event.debug "END Visitor.search"
        raise e
      end
      #---------------------------------------------------------------------------------------------------------------
      #
      # parcours les pages de resultats selon duration
      #
      #---------------------------------------------------------------------------------------------------------------
      i = 0
      landing_link = nil
      begin
        results_page.duration = durations[i]
        read(results_page)
        landing_link = engine_search.exist_link?(results_page, landing_url)
      rescue Exception => e
        i += 1
        if i < durations.size
          begin
            next_page_link = engine_search.next_page_link(results_page, i + 1)
          rescue Exception => e
            # le nombre de page de resultat est inférieur au nombre de pages attendues
            @@logger.an_event.warn "there no more results page : #{e.message}"
            @@logger.an_event.debug "END Visitor.search"
            raise VisitorError.new(NO_MORE_RESULT_PAGE), "there no more results page"
          end

          begin
            results_page = @browser.click_on(next_page_link)
            @@logger.an_event.info "visitor #{@id} click on next link #{next_page_link.url.to_s}"
          rescue Error => e
            #un erreur survient lors du click sur le lien de la page suivante.
            @@logger.an_event.error "visitor #{@id} not click on next link #{next_page_link.url.to_s}"
            @@logger.an_event.debug "END Visitor.search"
            raise VisitorError.new(CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE, e), "visitor #{@id} not click on next link #{next_page_link.url.to_s}"
          end
          retry # on recommence le begin
        else
          #toutes les pages ont été passées en revue et le landing link n'a pas été trouvé
          @@logger.an_event.debug "END Visitor.search"
          raise VisitorError.new(SEARCH_NOT_FOUND_LANDING_LINK), "visitor #{@id} not found landing link"
        end
      else
        return landing_link
      ensure
        @@logger.an_event.debug "END Visitor.search"
      end
    end

#-----------------------------------------------------------------------------------------------------------------
# surf
#-----------------------------------------------------------------------------------------------------------------
# input :
# durations : un tableau de durée de lecture de chaucne des pages
# page : la page de départ
# around : un tableau de périmètre de sélection des link pour chaque page
# output : un objet Page : la derniere
# exception :
# StandardError :
#-----------------------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------------

    def surf(durations, page, around)
      # le surf sur le website prend en entrée un around => arounds est rempli avec cette valeur
      # le surf sur l'advertiser predn en entrée un array de around pré calculé par engine bot en fonction des paramètre saisis au moyen de statupweb
      @@logger.an_event.debug "durations #{durations.inspect}"
      @@logger.an_event.debug "page #{page.to_s}"
      @@logger.an_event.debug "arounds #{around.inspect}"

      raise VisitorError.new(ARGUMENT_UNDEFINE), "durations undefine" if durations.nil? or durations.size == 0
      raise VisitorError.new(ARGUMENT_UNDEFINE), "page undefine" if  page.nil?
      raise VisitorError.new(ARGUMENT_UNDEFINE), "around undefine" if around.nil? or around.size == 0

      link = nil
      begin
        arounds = (around.is_a?(Array)) ? around : Array.new(durations.size, around)
        durations.each_index { |i|
          page.duration = durations[i]
          read(page)
          if i < durations.size - 1
            link = page.link_by_around(arounds[i])
            page = @browser.click_on(link)
            @@logger.an_event.info "visitor #{@id} click on link #{link.url.to_s}"
          end # on ne clique pas quand on est sur la denriere page
        }
        page
      rescue Error, Exception => e
        @@logger.an_event.error "visitor #{@id} not click on link #{link.url.to_s} : #{e.message}"
        raise VisitorError.new(VISIT_NOT_COMPLETE, e), "visitor #{@id} not click on link #{link.url.to_s}"
      end
    end

  end


end