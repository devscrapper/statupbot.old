module Browsers
  class Safari < Browser
    class SafariException < StandardError

    end
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(browser_details, nationality, user_agent)
      super(browser_details, user_agent)
      #TODO definir le profil de safari

      @profile['intl.accept_languages'] = "#{nationality.language.downcase}-#{nationality.language},en-US;q=0.5"
      @profile['network.http.accept-encoding'] = 'gzip, deflate'

      cq = CustomQuery.new("http://www.google-analytics.com/__utm.gif")
      cq.add_var_http("Accept", "image/png, image/svg+xml, image/*;q=0.8, */*;q=0.5")
      # Liste des variables customisable par le proxy (car pas le choix)
      # utmcs : charset
      # utmsr : screen resolution
      # utmsc : Screen color depth 	utmsc=24-bit
      # utmje : indicates if browser is Java-enabled. 1 is true. 	utmje=1
      # utmfl : #	Flash Version 	utmfl=9.0%20r48&
      # utme : variable personnalisée
      # utmul : Browser language. 	utmul=fr
      cq.add_var_query("utmcs", nationality.charset(browser_details[:operating_system], browser_details[:name]).downcase)
      cq.add_var_query("utmul", nationality.language.downcase)
      cq.add_var_query("utmsr", browser_details[:screen_resolution])
      cq.add_var_query("utmsc", browser_details[:screens_colors])
      cq.add_var_query("utmje", (browser_details[:java_enabled]=="Yes" ? 1 : 0))
      cq.add_var_query("utmfl", browser_details[:flash_version])
      cq.add_var_query("utme", "IE#{browser_details[:version]} \
      #{browser_details[:operating_system]} \
      #{browser_details[:operating_system_version]}")
      @custom_queries << cq
    end
    def user_agent(browserversion, os, osversion)
      case os
            when "Macintosh"
              return "Mozilla/5.0 (Macintosh; #{osversion.gsub!(" ", " Mac OS X ")}) AppleWebKit/537.13+ (KHTML, like Gecko) Version/#{browserversion} Safari/534.57.2"
            when "Windows"
              case osversion
                when "XP"
                  os = "Windows NT 5.1"
                when "vista"
                  os = "Windows NT 6.0"
                when "7"
                  os = "Windows NT 6.1"
                when "8"
                  os = "Windows NT 6.2"
                else
                  os = "Windows NT 6.2"
              end
              return "Mozilla/5.0 (Windows; #{os}) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/#{browserversion} Safari/533.20.27"
            when "Linux"
              ["Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/531.2+ (KHTML, like Gecko) Version/#{browserversion} Safari/531.2+",
               "Mozilla/5.0 (X11; Linux i686) AppleWebKit/531.2+ (KHTML, like Gecko) Version/#{browserversion} Safari/531.2+"].sample
          end
    end
  end
end