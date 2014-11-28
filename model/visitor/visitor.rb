require_relative '../../model/browser/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require_relative '../../lib/error'
require 'pathname'

module Visitors
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include Browsers
  include Visits::Referrers
  include Visits::Advertisings


  class Visitor
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors
    include Browsers
    include Visits::Referrers
    include Visits::Advertisings

    #----------------------------------------------------------------------------------------------------------------
    # Message exception
    #----------------------------------------------------------------------------------------------------------------

    ARGUMENT_UNDEFINE = 600
    VISITOR_NOT_CREATE = 601 # à remonter en code retour de statupbot
    SEARCH_NOT_FOUND_LANDING_LINK = 602 # à remonter en code retour de statupbot
    VISITOR_NOT_BORN = 603 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_LANDING_PAGE = 604 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_REFERRAL_REFERRER = 605 # à remonter en code retour de statupbot
    VISITOR_NOT_FOUND_LANDING_LINK = 606 # à remonter en code retour de statupbot
    VISITOR_NOT_BROWSE_SEARCH_REFERRER = 607 # à remonter en code retour de statupbot
    VISITOR_NOT_INHUME = 608 # à remonter en code retour de statupbot
    NO_MORE_RESULT_PAGE = 609
    VISIT_NOT_COMPLETE = 610
    CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE = 611
    VISITOR_NOT_CLOSE = 612
    VISITOR_NOT_DIE = 613
    NONE_KEYWORDS_FIND_LANDING_LINK = 614
    VISITOR_NOT_OPEN = 615
    LOG_VISITOR_NOT_DELETE = 616
    VISITOR_NOT_FOUND_ADVERT = 617
    VISITOR_NOT_CLICK_ON_ADVERT = 618
    VISITOR_NOT_BROWSE_DIRECT_REFERRER = 619
    VISITOR_NOT_FOUND_RESULTS_WITH_KEYWORD = 620
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
      begin
        @proxy.start

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_BORN, :error => e)

      else
        @@logger.an_event.info "visitor is born"

      ensure

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
    def initialize(visitor_details)
      @@logger.an_event.debug "visitor detail #{visitor_details}"


      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_details"}) if visitor_details.nil?

        @id = visitor_details[:id]


        @home = File.join(DIR_VISITORS, @id)


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

        @@logger.an_event.debug "visitor create runtime directory #{@home}"

        #------------------------------------------------------------------------------------------------------------
        #
        #Configure SAHI PROXY
        #
        #------------------------------------------------------------------------------------------------------------

        @proxy = Browsers::Proxy.new(@home,
                                     visitor_details[:browser][:listening_port_proxy],
                                     visitor_details[:browser][:proxy_ip],
                                     visitor_details[:browser][:proxy_port],
                                     visitor_details[:browser][:proxy_user],
                                     visitor_details[:browser][:proxy_pwd])


        #------------------------------------------------------------------------------------------------------------
        #
        # configure Browser
        #
        #------------------------------------------------------------------------------------------------------------
        @browser = Browsers::Browser.build(@home,
                                           visitor_details[:browser])

        @browser.deploy_properties(@home) if @browser.is_a?(Browsers::Opera)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CREATE, :error => e)

      else
        @@logger.an_event.info "visitor create runtime directory, config his proxy Sahi and config his browser"

      ensure

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
    def browse_landing_page(referrer)
      begin
        landing_page = nil

        case referrer
          #---------------------------------------------------------------------------------------------------------------
          #
          # Referrer DIRECT
          #
          #---------------------------------------------------------------------------------------------------------------
          when Direct
            landing_page = browse_direct(referrer)
          #---------------------------------------------------------------------------------------------------------------
          #
          # Referrer REFERRAL
          #
          #---------------------------------------------------------------------------------------------------------------
          when Referral
            landing_page = browse_referral(referrer)
          #---------------------------------------------------------------------------------------------------------------
          #
          # Referrer SEARCH
          #
          #---------------------------------------------------------------------------------------------------------------
          when Search
            landing_page = browse_search(referrer)
        end
      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_BROWSE_LANDING_PAGE, :error => e)
      else
        @@logger.an_event.debug "visitor browse landing page"
        return landing_page
      ensure

      end
    end


    def browse_direct(referrer)
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_url"}) if referrer.landing_url.nil?

        landing_page = @browser.display_start_page(referrer.landing_url, @id)

      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_BROWSE_DIRECT_REFERRER, :error => e)
      else
        return landing_page

      ensure

      end
    end

    def browse_referral(referrer)

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "page_url"}) if referrer.page_url.nil?
        referral_page = nil
        landing_link = nil
        referral_page = @browser.display_start_page(referrer.page_url, @id)

        @@logger.an_event.info "visitor browse referral page #{referral_page.url.to_s}"

        referral_page.duration = referrer.duration
        read(referral_page)

        landing_link = referral_page.link_by_url(referrer.landing_url)

        @@logger.an_event.info "visitor found landing link #{referrer.landing_url.to_s} in referral page #{referral_page.url.to_s}"

        landing_page = @browser.click_on(landing_link)

      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_BROWSE_REFERRAL_REFERRER, :error => e)
      else
        return landing_page
      ensure

      end

    end

    def browse_search(referrer)

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keywords"}) if referrer.keywords.nil?

        referrer.keywords = [referrer.keywords] if referrer.keywords.is_a?(String)

        @browser.display_start_page(referrer.engine_search.page_url, @id)

        @@logger.an_event.info "visitor browse engine search page #{referrer.engine_search.page_url}"

        landing_link = many_search(referrer)

        landing_page = @browser.click_on(landing_link)


      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_BROWSE_SEARCH_REFERRER, :error => e)

      else
        @@logger.an_event.info "visitor click on landing url #{landing_link.url.to_s}"
        return landing_page

      ensure

      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # select_click_on_advert
    #----------------------------------------------------------------------------------------------------------------
    #
    # inputs : objet page
    # output : objet page pointant sur l'advertiser
    # StandardError
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def click_on_advert(advert)
      @@logger.an_event.debug "advert #{advert}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "advert"}) if advert.nil?
        advertiser_page = @browser.click_on(advert)

      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CLICK_ON_ADVERT, :error => e)
      else
        @@logger.an_event.info "visitor click on advert url #{advert.url.to_s}"

        return advertiser_page
      ensure

      end

    end

    #----------------------------------------------------------------------------------------------------------------
    # close_browser
    #----------------------------------------------------------------------------------------------------------------
    # ferme le navigateur :
    # inputs : RAS
    # output : RAS
    # StandardError : VISITOR_NOT_CLOSE
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------

    def close_browser

      begin

        @browser.quit

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CLOSE, :error => e)

      else
        @@logger.an_event.info "visitor close browser"
      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # die
    #----------------------------------------------------------------------------------------------------------------
    # arrete le proxy :
    # inputs : RAS
    # output : RAS
    # StandardError : VISITOR_NOT_DIE
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def die
      begin

        @proxy.stop

      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} not die : #{e.message}"
        raise Error.new(VISITOR_NOT_DIE, e), "visitor #{@id} not die"
      else
        @@logger.an_event.info "visitor die"
      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # delete_log
    #----------------------------------------------------------------------------------------------------------------
    # supprimer les fichier de log
    # inputs : RAS
    # output : RAS
    # StandardError  : LOG_VISITOR_NOT_DELETE
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def delete_log

      begin

        dir = Pathname(File.join(File.dirname(__FILE__), "..", '..', "log")).realpath
        files = File.join(dir, "visitor_bot_#{@id}.{*}")
        FileUtils.rm_r(Dir.glob(files), :force => true)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(LOG_VISITOR_NOT_DELETE, :error => e)

      else
        @@logger.an_event.info "visitor delete log"

      ensure

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
    def inhume

      begin

        try_count = 0
        max_try_count = 3
        @proxy.delete_config
        FileUtils.rm_r(@home) if File.exist?(@home)

      rescue Exception => e
        @@logger.an_event.debug "visitor #{@id} not inhume, try #{try_count}"
        sleep (1)
        try_count +=1
        retry if try_count < max_try_count
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_INHUME, :error => e)
      else
        @@logger.an_event.info "visitor inhume"
      ensure

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
# cela permettra par exemple de realiser des recherches qui échouent
#-----------------------------------------------------------------------------------------------------------------
    def many_search(referrer)

      #TODO meo plusieurs methodes pour saisir les mots clés et les choisir aléatoirement :
      #TODO afficher la page google.fr, comme c'est le cas actuellement
      #TODO dans la derniere page des resultats, saisir les nouveaux mot clés dans la zone idoine.
      @@logger.an_event.debug "keywords #{referrer.keywords}"
      @@logger.an_event.debug "engine_search #{referrer.engine_search}"
      @@logger.an_event.debug "landing_url #{referrer.landing_url}"

      i = 0 # ne pas déplacer sinon on passe jamais au mot clé suivant
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keywords"}) if referrer.keywords.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "engine_search"}) if referrer.engine_search.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_url"}) if referrer.landing_url.nil?


        landing_link = search(referrer.keywords[i][:words],
                              referrer.engine_search,
                              referrer.keywords[i][:durations].map { |d| d },
                              referrer.landing_url)

      rescue Exception => e

        i+=1
        if i < referrer.keywords.size
          @@logger.an_event.warn e.message
          retry
        else
          @@logger.an_event.error e.message
          raise Error.new(NONE_KEYWORDS_FIND_LANDING_LINK, :error => e)
        end
      else
        return landing_link

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # open_browser
    #----------------------------------------------------------------------------------------------------------------
    # ouvre un browser :
    # inputs : none
    # output : none
    # StandardError
    # si le visiteur n'a pas pu lancer le navigateur.
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def open_browser
      begin

        @browser.open

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_OPEN, :error => e)

      else
        @@logger.an_event.info "visitor open his browser"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # read
    #----------------------------------------------------------------------------------------------------------------
    # lit le contenu d'une page affichée,
    # inputs : un objet page
    # output : none
    # StandartError
    # si aucune page n'est définie
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def read(page)

      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "page"}) if page.nil?

      @@logger.an_event.info "visitor read #{page.url.to_s} during #{page.sleeping_time}s"

      @browser.wait_on(page)

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
      @@logger.an_event.debug "keywords #{keywords}"
      @@logger.an_event.debug "engine search #{engine_search}"
      @@logger.an_event.debug "durations #{durations}"
      @@logger.an_event.debug "landing url #{landing_url}"


      #---------------------------------------------------------------------------------------------------------------
      #
      # search keyword in engine
      #
      #---------------------------------------------------------------------------------------------------------------
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "keywords"}) if keywords.nil? or keywords == ""
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "engine_search"}) if engine_search.nil?

        results_page = @browser.search(keywords, engine_search)

      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_FOUND_RESULTS_WITH_KEYWORD, :values => {:keywords => "keywords"}, :error => e)

      else
        @@logger.an_event.info "visitor browse first results page with keywords #{keywords}"
      end

      #---------------------------------------------------------------------------------------------------------------
      #
      # parcours les pages de resultats selon duration
      #
      #---------------------------------------------------------------------------------------------------------------
      i = 0 # ne pas déplacer
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "durations"}) if durations.nil? or durations.size == 0
      raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_url"}) if landing_url.nil?
      landing_link = nil

      begin

        results_page.duration = durations[i]
        read(results_page)

        l = engine_search.landing_link(landing_url, @browser.driver)

      rescue Exception => e
        i += 1
        if i < durations.size
          begin
            next_page_link = engine_search.next_page_link(@browser.driver)
          rescue Exception => e
            # le nombre de page de resultat est inférieur au nombre de pages attendues
            @@logger.an_event.warn e.message
            raise Error.new(NO_MORE_RESULT_PAGE, :values => {:keywords => keywords}, :error => e)
          else
            @@logger.an_event.info "visitor found next page"
          end

          begin
            results_page = @browser.click_on(next_page_link)

          rescue Exception => e
            #un erreur survient lors du click sur le lien de la page suivante.
            @browser.screenshot(@id, "ERROR")
            @@logger.an_event.error e.message
            raise Error.new(CANNOT_CLICK_ON_LINK_OF_NEXT_PAGE, :error => e)
          else
            @@logger.an_event.info "visitor click on next link"
          end
          retry # on recommence le begin
        else
          #toutes les pages ont été passées en revue et le landing link n'a pas été trouvé
          raise Error.new(SEARCH_NOT_FOUND_LANDING_LINK, :values => {:keywords => keywords})
        end

      else
        @@logger.an_event.info "visitor found landing link #{landing_url.to_s}"
        landing_link = l
      ensure
        landing_link
      end
    end

#-----------------------------------------------------------------------------------------------------------------
# surf
#-----------------------------------------------------------------------------------------------------------------
# input :
# durations : un tableau de durée de lecture de chaucne des pages
# page : la page de départ
# around : un tableau de périmètre de sélection des link pour chaque page
# advertising : la régie publicitaire de la visit (option)
# output : un objet Page : la derniere
# exception :
# StandardError :
#-----------------------------------------------------------------------------------------------------------------
# le surf sur l'advertiser a un advertising == nil
#-----------------------------------------------------------------------------------------------------------------

    def surf(durations, page, around, advertising = nil)


      @@logger.an_event.debug "durations #{durations.inspect}"
      @@logger.an_event.debug "page #{page.to_s}"
      @@logger.an_event.debug "arounds #{around.inspect}"
      @@logger.an_event.debug "advertising #{advertising}"


      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "durations"}) if durations.nil? or durations.size == 0
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "page"}) if  page.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "around"}) if around.nil? or around.size == 0

        link = nil
        # le surf sur le website prend en entrée un around => arounds est rempli avec cette valeur
        # le surf sur l'advertiser prend en entrée un array de around pré calculé par engine bot en fonction des paramètre saisis au moyen de statupweb
        arounds = (around.is_a?(Array)) ? around : Array.new(durations.size, around)

        durations.each_index { |i|
          page.duration = durations[i]
          read(page)
          if i < durations.size - 1
            link = page.link_by_around(arounds[i])

            page = @browser.click_on(link)

            @@logger.an_event.info "visitor click on link #{link.url.to_s}"

          end # on ne clique pas quand on est sur la derniere page
        }

        # quand on surf sur le site :
        # si on est sur l'avant derniere page de la visit et qu'une publicité est planifiée par la visit alors
        # il faut rechercher dans la dernière page affichée, les liens des publicités exposés par la régie publicité
        # quand on surf sur l'advertiser :
        # on ne recherche pas de publicité.
        page.advert = advertising.advert { |domain, link_identifier| @browser.find_links(domain, link_identifier) } unless advertising.nil?

      rescue Exception => e
        @browser.screenshot(@id, "ERROR")
        @@logger.an_event.error e.message
        raise Error.new(VISIT_NOT_COMPLETE, :error => e)
      else
        @@logger.an_event.info "visitor stop surfing"
        return page
      ensure
      end
    end

    #-----------------------------------------------------------------------------------------------------------------
    # take_screenshot
    #-----------------------------------------------------------------------------------------------------------------
    # input : none
    # output : none
    # exception : none
    #-----------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------
    def take_screenshot
      @browser.screenshot(@id)
    end
  end


end