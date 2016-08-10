# encoding: utf-8
require_relative '../page/page'
require_relative '../browser/browser'
require_relative '../visit/referrer/referrer'
require_relative '../visit/advertising/advertising'
require_relative '../../lib/monitoring'
require_relative '../../lib/error'
require 'pathname'

module Visitors

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
    VISITOR_NOT_CREATE = 601
    VISITOR_NOT_BORN = 602
    VISITOR_NOT_INHUME = 603
    VISITOR_NOT_FULL_EXECUTE_VISIT = 604
    VISITOR_NOT_CLOSE = 605
    VISITOR_NOT_DIE = 606
    VISITOR_NOT_OPEN = 607
    LOG_VISITOR_NOT_DELETE = 608
    VISITOR_NOT_CLICK_ON_ADVERT = 609
    VISITOR_NOT_CLICK_ON_LINK = 610
    VISITOR_NOT_CLICK_ON_LINK_ON_WEBSITE = 611
    VISITOR_NOT_CLICK_ON_LINK_ON_ADVERTISER = 612
    VISITOR_NOT_CLICK_ON_LINK_ON_UNKNOWN = 613
    VISITOR_NOT_START_LANDING = 614
    VISITOR_NOT_START_ENGINE_SEARCH = 615
    VISITOR_NOT_GO_BACK = 616
    VISITOR_NOT_CLICK_ON_RESULT = 617
    VISITOR_NOT_SUBMIT_FINAL_SEARCH = 618
    VISITOR_NOT_CLICK_ON_LANDING = 619
    VISITOR_NOT_GO_TO_LANDING = 620
    VISITOR_NOT_GO_TO_ENGINE_SEARCH = 621
    VISITOR_NOT_GO_TO_REFERRAL = 622
    VISITOR_NOT_CLICK_ON_NEXT= 623
    VISITOR_NOT_CLICK_ON_PREV = 624
    VISITOR_NOT_SUBMIT_SEARCH = 625
    VISITOR_NOT_KNOWN_ACTION = 626
    VISITOR_NOT_READ_PAGE = 627
    VISITOR_NOT_CHOOSE_LINK = 628
    VISITOR_NOT_CHOOSE_ADVERT = 629
    VISITOR_NOT_FOUND_LANDING = 630
    VISITOR_NOT_CLICK_ON_REFERRAL = 631
    VISITOR_SEE_CAPTCHA = 632
    VISITOR_NOT_SUBMIT_CAPTCHA = 633
    #----------------------------------------------------------------------------------------------------------------
    # constants
    #----------------------------------------------------------------------------------------------------------------
    DIR_VISITORS = Pathname(File.join(File.dirname(__FILE__), '..', '..', 'visitors')).realpath

    COMMANDS = {"a" => "go_to_start_landing",
                "b" => "go_to_start_engine_search",
                "c" => "go_back",
                "d" => "go_to_landing",
                "e" => "go_to_referral",
                "f" => "go_to_search_engine",
                "A" => "cl_on_next",
                "B" => "cl_on_prev",
                "C" => "cl_on_link_on_result",
                "D" => "cl_on_landing",
                "E" => "cl_on_link_on_website",
                "F" => "cl_on_advert",
                "G" => "cl_on_link_on_unknown",
                "H" => "cl_on_link_on_advertiser",
                "I" => "cl_on_referral",
                "0" => "sb_search",
                "2" => "sb_search",
                "1" => "sb_final_search",
                "3" => "sb_captcha"}

    MAX_COUNT_SUBMITING_CAPTCHA = 3 # nombre max de submission de captcha
    #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    @@logger = nil

    #----------------------------------------------------------------------------------------------------------------
    # attributs
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :id, #id du visitor
                :browser, #browser utilisé par le visitor
                :visit, #la visit à exécuter
                :current_page, #page encours de visualisation par le visitor
                :home, #repertoire d'execution du visitor
                :proxy, #sahi : utilise le proxy sahi
                :failed_links, #liste links sur lesquels le visior a cliquer et une eexception a été elvée
                :history # liste des pages vues par le visitor lors du surf

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
        @@logger.an_event.info "visitor #{@id} is born"

      ensure

      end
    end


    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    # - crée le visitor, le browser, la geolocation
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def initialize(visitor_details)
      @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)
      @@logger.an_event.debug "visitor detail #{visitor_details}"

      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visitor_details"}) if visitor_details.nil?
        @history = []
        @failed_links = []

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

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CREATE, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} create runtime directory, config proxy Sahi and browser"

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
        @@logger.an_event.error "visitor #{@id} close browser : #{e.message}"
        raise Error.new(VISITOR_NOT_CLOSE, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} close browser"
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
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_DIE, :error => e)
      else
        @@logger.an_event.info "visitor #{@id} die"
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
        @@logger.an_event.info "visitor #{@id} delete log"

      ensure

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # execute
    #----------------------------------------------------------------------------------------------------------------
    # execute une visite
    # inputs : object visit
    # output : RAS
    # StandardError  : ???
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def execute (visit)
      #TODO tenter d'utiliser un Object ElementStub de Sahi pour les actions click
      #TODO tenter d'utiliser un Object Uri pour les actions go_to
      begin
        @visit = visit

        script = @visit.script


        count_actions = 0

        for action in script
          @@logger.an_event.debug "script #{script}"

          for h in @history
            @@logger.an_event.debug "history : #{h[0]} #{h[1]}"
          end

          begin

            raise Error.new(VISITOR_NOT_KNOWN_ACTION, :values => {:action => action}) if COMMANDS[action].nil?
            eval(COMMANDS[action])

          rescue Errors::Error => e

            case e.code

              when VISITOR_NOT_CLICK_ON_REFERRAL
                # le click sur le link du referral dans la page de results a échoué
                # force l'accès au referral par un accès direct
                act = "e"
                script.insert(count_actions + 1, act)
                @@logger.an_event.info "visitor #{@id} make action <#{COMMANDS[act]}> instead of  <#{COMMANDS[action]}>"
                count_actions +=1
                Monitoring.page_browse(@visit.id, script)

              when VISITOR_NOT_READ_PAGE
                # ajout dans le script d'action pour revenir à la page précédent pour refaire l'action qui a planté.
                # ceci s'arretera quand il n'y aura plus de lien sur lesquel clickés ; lien choisi dans les 3 actions
                script.insert(count_actions + 1, ["c", action]).flatten!
                @@logger.an_event.info "visitor #{@id} go back to make action #{COMMANDS[action]} again"
                count_actions +=1
                Monitoring.page_browse(@visit.id, script)

              when VISITOR_NOT_CLICK_ON_RESULT,
                  VISITOR_NOT_CLICK_ON_LINK_ON_ADVERTISER,
                  VISITOR_NOT_CLICK_ON_LINK_ON_UNKNOWN,
                  VISITOR_NOT_CLICK_ON_LINK_ON_WEBSITE
                # ajout dand le script d'une action pour choisir un autres results  ou un autre lien
                #  ceci s'arretera quand il n'y aura plus de lien sur lesquels clickés
                script.insert(count_actions + 1, action)
                @@logger.an_event.info "visitor #{@id} make action <#{COMMANDS[action]}> again"
                count_actions +=1
                Monitoring.page_browse(@visit.id, script)

              when VISITOR_SEE_CAPTCHA
                #ajout dans le script d'un action pour gérer une page affichant un capcha du MDR
                # pour eviter une boucle infini, on limite le nombre de submit captcha à 3, pour cela on compte le
                # nombre d'action '3' présentes dans le script. Si > MAX_COUNT_SUBMITING_CAPTCHA alors VISITOR_NOT_SUBMIT_CAPTCHA
                act = "3"
                if script.count("3") < MAX_COUNT_SUBMITING_CAPTCHA
                  script.insert(count_actions + 1, [act, action]).flatten!
                  @@logger.an_event.info "visitor #{@id} make action <#{COMMANDS[act]}> before <#{COMMANDS[action]}> again"
                  count_actions +=1
                  Monitoring.page_browse(@visit.id, script)

                else
                  @@logger.an_event.error "visitor #{@id} submited too many captchas"
                  raise Error.new(VISITOR_NOT_FULL_EXECUTE_VISIT, :error => e)

                end

              else
                @@logger.an_event.error "visitor #{@id} make action  <#{COMMANDS[action]}> : #{e.message}"
                raise Error.new(VISITOR_NOT_FULL_EXECUTE_VISIT, :error => e)
            end


          rescue Exception => e
            take_screenshot(count_actions, action)
            @@logger.an_event.error "visitor #{@id} make action <#{COMMANDS[action]}> : #{e.message}"
            raise Error.new(VISITOR_NOT_FULL_EXECUTE_VISIT, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} executed action <#{COMMANDS[action]}>."
            Monitoring.page_browse(@visit.id, script)
            take_screenshot(count_actions, action)
            count_actions +=1

          ensure
            @@logger.an_event.info "visitor #{@id} executed #{count_actions}/#{script.size}(#{(count_actions * 100 /script.size).round(0)}%) actions."
          end

        end


      rescue Exception => e
        take_screenshot(count_actions, action)
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_FULL_EXECUTE_VISIT, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} execute visit."

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
        @@logger.an_event.info "visitor #{@id} inhume"
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
        @@logger.an_event.info "visitor #{@id} open his browser"

      ensure

      end
    end

    private
    #-----------------------------------------------------------------------------------------------------------------
    # take_screenshot
    #-----------------------------------------------------------------------------------------------------------------
    # input : none
    # output : none
    # exception : none
    #-----------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------
    def take_screenshot(index, action)
      @browser.take_screenshot(Flow.new(@home, index.to_s, action, Date.today, nil, ".png"))
    end


    # permet de choisir un link en s'assurant que ce link n'est pas un lien comme déja identifié ne fonctionnant pas car
    # il apprtient à la liste des failed_links connnu du visitor
    # les links déjà parcourus ne sont pas éliminé du choix car un visitor peut avoir envie
    # de revenir sur un lien déjà consulté
    # quand il n'y a plus de lien, on relais l'exception

    def choose_link(around = nil)
      begin

        link = @current_page.link(around) unless around.nil?
        link = @current_page.link if around.nil?
        while @failed_links.include?(link.url)
          link = @current_page.link(around) unless around.nil?
          link = @current_page.link if around.nil?
        end
        @failed_links.each { |l| @@logger.an_event.debug "failed_link : #{l}" }

      rescue Exception => e
        raise Error.new(VISITOR_NOT_CHOOSE_LINK, :error => e)

      else
        link

      end

    end

    def cl_on_advert

      @@logger.an_event.debug "action #{__method__}"
      #--------------------------------------------------------------------------------------------------------
      # Chose link
      #--------------------------------------------------------------------------------------------------------
      begin
        #Contrairement aux links qui sont calculés lors de la creation de l'objet Page, les liens des Adverts sont calculés
        #seulement avant de cliquer dessus car on evite de rechercher des liens pour rien.
        advert = @visit.advertising.advert(@browser)

        @@logger.an_event.debug "advert #{advert}"

      rescue Exception => e

        @@logger.an_event.error "visitor #{@id} not found advert on website."
        raise Error.new(VISITOR_NOT_CHOOSE_ADVERT, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} chose advert on website."

      end

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin

        @browser.click_on(advert, true)

      rescue Exception => e

        @@logger.an_event.warn "visitor #{@id} not clicked on link advert on website : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_ADVERT, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link advert on website."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin
        @current_page = Pages::Unmanage.new(@visit.advertising.advertiser.next_duration,
                                            @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 3
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)

      ensure
        @history << [@browser.driver, @current_page]
      end
    end

    def cl_on_landing

      @@logger.an_event.debug "action #{__method__}"

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin
        link = @visit.landing_link #Object Link

        @browser.click_on(link)

      rescue Exception => e

        @@logger.an_event.warn "visitor #{@id} not clicked on landing link #{link.url} on results page : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_LANDING, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link #{link.url} on results page."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin
        @current_page = Pages::Website.new(@visit, @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 10
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end


    end


    def cl_on_link_on_advertiser
      @@logger.an_event.debug "action #{__method__}"
      #--------------------------------------------------------------------------------------------------------
      # Chose link
      #--------------------------------------------------------------------------------------------------------
      begin

        link = choose_link(@visit.advertising.advertiser.next_around)

      rescue Exception => e

        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CHOOSE_LINK, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} chose link <#{link.url}> on advertiser website."

      end

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin

        @browser.click_on(link)

      rescue Exception => e
        @failed_links << link.url
        @@logger.an_event.warn "visitor #{@id} not clicked on link #{link.url} on advertiser website : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_LINK_ON_ADVERTISER, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link #{link.url}> on advertiser website."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin

        @current_page = Pages::Unmanage.new(@visit.advertising.advertiser.next_duration,
                                            @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 5
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end
    end

    def cl_on_link_on_result
      @@logger.an_event.debug "action #{__method__}"
      #--------------------------------------------------------------------------------------------------------
      # Chose link
      #--------------------------------------------------------------------------------------------------------
      begin

        link = choose_link

      rescue Exception => e

        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CHOOSE_LINK, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} chose link <#{link.url}> on results search."

      end

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin

        @browser.click_on(link)

      rescue Exception => e
        @failed_links << link.url
        @@logger.an_event.warn "visitor #{@id} not clicked on link #{link.url} on results page : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_RESULT, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link #{link.url} on results page."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin

        @current_page = Pages::Unmanage.new(@visit.referrer.search_duration,
                                            @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 10
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end
    end

    def cl_on_link_on_unknown
      @@logger.an_event.debug "action #{__method__}"
      #--------------------------------------------------------------------------------------------------------
      # Chose link
      #--------------------------------------------------------------------------------------------------------
      begin

        link = choose_link(:inside_fqdn)

      rescue Exception => e

        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CHOOSE_LINK, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} chose link <#{link.url}> on unknown website."

      end

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin

        @browser.click_on(link)

      rescue Exception => e
        @failed_links << link.url
        @@logger.an_event.warn "visitor #{@id} not clicked on link #{link.url} on unknown website : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_LINK_ON_UNKNOWN, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link <#{link.url}> on unknown website."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin
        @current_page = Pages::Unmanage.new(@visit.referrer.surf_duration,
                                            @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS, Pages::Page::PAGE_NONE_LINK
            count_retry += 1
            sleep 10
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end
    end

    def cl_on_link_on_website
      @@logger.an_event.debug "action #{__method__}"

      #--------------------------------------------------------------------------------------------------------
      # Chose link
      #--------------------------------------------------------------------------------------------------------
      begin

        link = choose_link(@visit.around)

      rescue Exception => e

        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CHOOSE_LINK, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} chose link <#{link.url}> on website."

      end

      #--------------------------------------------------------------------------------------------------------
      # Click on link
      #--------------------------------------------------------------------------------------------------------
      begin

        @browser.click_on(link)

      rescue Exception => e
        @failed_links << link.url
        @@logger.an_event.warn "visitor #{@id} not clicked on link #{link.url} on website : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_LINK_ON_WEBSITE, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link #{link.url} on website."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin

        @current_page = Pages::Website.new(@visit, @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 10
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end

    end

    def cl_on_next
      begin
        @@logger.an_event.debug "action #{__method__}"

        nxt = @current_page.next
        @@logger.an_event.debug "nxt #{nxt}"

        @browser.click_on(nxt)
        @@logger.an_event.debug "click on next"

        @current_page = Pages::Results.new(@visit, @browser)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CLICK_ON_NEXT, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} clicked on next <#{nxt.text}>"
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]

      end
    end

    def cl_on_prev
      begin

        prv = @current_page.prev
        @browser.click_on(prv)

        @current_page = Pages::Results.new(@visit, @browser)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_CLICK_ON_PREV, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} clicked on prev #{prv.text}"

        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]

      end
    end

    def cl_on_referral
      @@logger.an_event.debug "action #{__method__}"

      #--------------------------------------------------------------------------------------------------------
      # Click on link referral
      #--------------------------------------------------------------------------------------------------------
      begin
        link = @visit.referrer.referral_uri_search #Object Link

        @browser.click_on(link)

      rescue Exception => e

        @@logger.an_event.warn "visitor #{@id} not clicked on referral link #{link.url} on results page : #{e.message}."
        raise Error.new(VISITOR_NOT_CLICK_ON_REFERRAL, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} clicked on link #{link.url} on results page."

      end

      #--------------------------------------------------------------------------------------------------------
      # read Page
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin
        @current_page = Pages::Unmanage.new(visit.referrer.duration, @browser)

      rescue Errors::Error => e
        case e.code
          when Pages::Page::PAGE_NONE_INSIDE_LINKS
            count_retry += 1
            sleep 10
            @@logger.an_event.warn "visitor #{@id} try catch links again #{count_retry} times"
            retry if count_retry < 3
        end
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      rescue Exception => e
        raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

      else
        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]
      end

    end

    def go_back
      begin
        @@logger.an_event.debug "action #{__method__}"

        @current_page = @history[@history.size - 2][1].dup
        @@logger.an_event.debug "current page = #{@current_page}"
        @@logger.an_event.debug "@browser.url = #{@browser.url}"
        if @browser.driver == @history[@history.size - 2][0]
          # on est dans la même fenetre que la fenetre où on veut aller
          while @current_page.url != @browser.url
            url = @browser.url
            @browser.go_back
            # pour gérer le retour vers une page de resultats google pour IE : lors du go_back, IE execute à nouveau le redirect Google
            # porté par le lien resultat => boucle
            # comportement différent pour Chrome/FF qui ne réexécute pas la redirection.
            @browser.go_to(@current_page.url) if @browser.url == url


          end
        else
          #on en dans 2 fenetre differente : la principale et celle ouverte par le click sur la advert
          # on repositionne le focus sur la fenetre précédent
          # et on clos la fenetre ouverte par le click
          @@logger.an_event.debug "close popup #{@browser.driver.popup_name}"
          @browser.driver.close
          @browser.driver = @history[@history.size - 2][0]

        end
        @@logger.an_event.debug "visitor #{@id} went back to #{@browser.url}"

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_GO_BACK, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} went back to previous page <#{@current_page.url}>"
        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # captcha page replace search page
          #--------------------------------------------------------------------------------------------------------

          begin

            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_GO_BACK, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          read(@current_page)
          @history << [@browser.driver, @current_page]
          @@logger.an_event.info "visitor #{@id} read previous page <#{@current_page.url}>"

        end

      ensure


      end
    end

    def go_to_landing
      begin
        @@logger.an_event.debug "action #{__method__}"
        url = @visit.landing_link.url
        @browser.go_to(url)

        @current_page = Pages::Website.new(@visit, @browser)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_GO_TO_LANDING, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} went to landing page #{url}."

        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]

      end
    end

    def go_to_referral
      begin
        @@logger.an_event.debug "action #{__method__}"

        url = @visit.referrer.page_url.to_s
        @browser.go_to(url)

        @current_page = Pages::Unmanage.new(visit.referrer.duration, @browser)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_GO_TO_REFERRAL, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} went to referral #{url.to_s}"

        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]

      end
    end

    def go_to_search_engine
      begin
        @@logger.an_event.debug "action #{__method__}"

        url = @browser.engine_search.page_url
        @browser.go_to(url)

        @current_page = Pages::EngineSearch.new(@visit,
                                                @browser)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_GO_TO_ENGINE_SEARCH, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} went to engine search page #{url}"

        read(@current_page)
      ensure
        @max_count_submiting_captcha = MAX_COUNT_SUBMITING_CAPTCHA #initialisation du nombre de submiting captcha
        # pour éviter de partir en boucle infini si on arrive pas a converntir l'image en string

        @history << [@browser.driver, @current_page]

      end
    end

    def go_to_start_engine_search

      #--------------------------------------------------------------------------------------------------------
      # Display start page
      #--------------------------------------------------------------------------------------------------------
      begin
        @@logger.an_event.debug "action #{__method__}"

        url = @browser.engine_search.page_url

        @browser.display_start_page(url, @id)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_START_ENGINE_SEARCH, :error => e)

      end


      #--------------------------------------------------------------------------------------------------------
      # Engine search page displayed
      #--------------------------------------------------------------------------------------------------------
      begin
        @current_page = Pages::EngineSearch.new(@visit, @browser)

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_START_ENGINE_SEARCH, :error => e)

      else
        @@logger.an_event.info "visitor #{@id} went to engine search page <#{url}>"

        read(@current_page)

      ensure
        @max_count_submiting_captcha = MAX_COUNT_SUBMITING_CAPTCHA #initialisation du nombre de submiting captcha
        # pour éviter de partir en boucle infini si on arrive pas a converntir l'image en string

        @history << [@browser.driver, @current_page]

      end


    end

    def go_to_start_landing

      begin
        @@logger.an_event.debug "action #{__method__}"

        url = @visit.landing_link.url
        @browser.display_start_page(url, @id)

        @current_page = Pages::Website.new(@visit, @browser)


      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(VISITOR_NOT_START_LANDING, :error => e)

      else

        @@logger.an_event.info "visitor #{@id} went to landing page <#{url}>"

        read(@current_page)
      ensure
        @history << [@browser.driver, @current_page]

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

      @@logger.an_event.info "visitor #{@id} begin reading <#{page.url}> during #{page.sleeping_time}s"

      sleep page.sleeping_time if $staging != "development"

      @@logger.an_event.debug "visitor #{@id} finish reading on page <#{page.url}>"


    end

    def sb_captcha

      begin
        @@logger.an_event.debug "action #{__method__}"

        @browser.set_input_captcha(@current_page.type, @current_page.input, @current_page.text)

        @browser.submit(@current_page.submit_button)

      rescue Exception => e
        @@logger.an_event.error "visitor #{@id} submited captcha search <#{@current_page.text}> : #{e.message}."
        raise Error.new(VISITOR_NOT_SUBMIT_CAPTCHA, :error => e)

      else
        sleep 2

        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # new captcha page replace captcha page
          #--------------------------------------------------------------------------------------------------------

          begin
            #si la soumission du text du captcha a échoué alors, google en affiche un nouveau.
            #le nouveau screenshot est dans un nouveau volume du flow.
            #le captcha précédent peut être déclaré comme bad aupres de de-capcher.
            #TODO Captchas::bad_string(id_visitor)


            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_SUBMIT_CAPTCHA, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          @@logger.an_event.info "visitor #{@id} submited captcha search <#{@current_page.text}>."
          #il y a pu avoir un succession de saisie de captcha => on les supprime pour trouver la denire page
          history_without_captcha_page = @history.reject { |browser, page| page.is_a?(Pages::Captcha) }
          @@logger.an_event.debug "history_without_captcha_page #{history_without_captcha_page}"

          #on se repositionne sur le dernierélement de l'history et prend la page associée qui a amener le captcha
          @current_page = history_without_captcha_page.last[1]
          @@logger.an_event.info "current page #{@current_page}"

        end


      end
    end

    def sb_final_search
      begin
        #--------------------------------------------------------------------------------------------------------
        # input keywords & submit search
        #--------------------------------------------------------------------------------------------------------
        @@logger.an_event.debug "action #{__method__}"

        keywords = @visit.referrer.keywords

        #permet d'utiliser des méthodes differentes en fonction des moteurs de recherche qui n'identifie pas l'input
        #des mot clé avec le même objet html
        #le omportement de Internet Explorer/Chrome/Opera est différent donc creation d'une méthode pour gérer l'initialisation de la zone de recherche.
        @browser.set_input_search(@current_page.type, @current_page.input, keywords)

        @@logger.an_event.debug "set input search #{@current_page.type} #{@current_page.input} #{keywords}"

        @browser.submit(@current_page.submit_button)


      rescue Error, Exception => e
        sleep 5

        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # captcha page replace search page
          #--------------------------------------------------------------------------------------------------------

          begin

            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_START_ENGINE_SEARCH, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          @@logger.an_event.error "visitor #{@id} submited final search <#{keywords}> : #{e.message}"

          raise Error.new(VISITOR_NOT_SUBMIT_FINAL_SEARCH, :error => e)
        end

      else
        @@logger.an_event.info "visitor #{@id} submited final search <#{keywords}>."

      end

      #--------------------------------------------------------------------------------------------------------
      # Page Results display
      #--------------------------------------------------------------------------------------------------------
      begin

        @current_page = Pages::Results.new(@visit, @browser)

      rescue Error, Exception => e
        sleep 5

        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # captcha page replace results page
          #--------------------------------------------------------------------------------------------------------
          begin

            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          @@logger.an_event.error "visitor #{@id} browsed results search <#{keywords}> : #{e.message}"

          raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

        end

      else
        read(@current_page)

      ensure
        @history << [@browser.driver, @current_page]

      end
    end

    def sb_search
      begin
        #--------------------------------------------------------------------------------------------------------
        # input keywords & submit search
        #--------------------------------------------------------------------------------------------------------
        @@logger.an_event.debug "action #{__method__}"

        keywords = @visit.referrer.next_keyword

        #permet d'utiliser des méthodes differentes en fonction des moteurs de recherche qui n'identifie pas l'input
        #des mot clé avec le même objet html
        #le omportement de Internet Explorer/Chrome/Opera est différent donc creation d'une méthode pour gérer l'initialisation de la zone de recerche.
        @browser.set_input_search(@current_page.type, @current_page.input, keywords)

        @@logger.an_event.debug "set input search #{@current_page.type} #{@current_page.input} #{keywords}"

        @browser.submit(@current_page.submit_button)

      rescue Error, Exception => e

        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # captcha page replace search page
          #--------------------------------------------------------------------------------------------------------
          begin

            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_START_ENGINE_SEARCH, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          @@logger.an_event.error "visitor #{@id} submited search <#{keywords}> : #{e.message}"

          raise Error.new(VISITOR_NOT_SUBMIT_FINAL_SEARCH, :error => e)
        end

      else

        @@logger.an_event.info "visitor #{@id} submited search <#{keywords}>."

      ensure

      end


      #--------------------------------------------------------------------------------------------------------
      # Page Results displayed
      #--------------------------------------------------------------------------------------------------------
      count_retry = 0
      begin

        @current_page = Pages::Results.new(@visit, @browser)


      rescue Error, Exception => e
        sleep 5

        if @browser.engine_search.is_captcha_page?(@browser.url)
          #--------------------------------------------------------------------------------------------------------
          # captcha page replace results page
          #--------------------------------------------------------------------------------------------------------
          begin

            @current_page = Pages::Captcha.new(@browser, @id, @home)

          rescue Exception => e
            @@logger.an_event.error e.message
            raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

          else
            @@logger.an_event.info "visitor #{@id} see captcha page"
            raise Error.new(VISITOR_SEE_CAPTCHA, :values => {:type => @current_page.type})

          end

        else
          @@logger.an_event.error "visitor #{@id} browsed results search <#{keywords}> : #{e.message}"

          raise Error.new(VISITOR_NOT_READ_PAGE, :error => e)

        end

      else
        read(@current_page)

      ensure
        @history << [@browser.driver, @current_page]

      end
    end

  end
end
