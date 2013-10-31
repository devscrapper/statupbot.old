module Browsers
  class InternetExplorer < Browser
    class InternetExplorerException < StandardError

    end
    include Selenium::WebDriver::Firefox
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(browser_details, nationality, user_agent)
      super(browser_details, user_agent)

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

    #http://www.google-analytics.com/__utm.gif?utmwv=5.4.4&utms=2&utmn=1833189289&utmhn=centre.epilation-laser-definitive.info&utmcs=iso-8859-1&utmsr=2025x1139&utmvp=1911x647&utmsc=32-bit&utmul=fr&utmje=1&utmfl=10.1%20r102&utmdt=Descamps%20Val%C3%A9rie%2029%20rue%2027%20Juin%20Beauvais%2060000%20Oise&utmhid=486352529&utmr=-&utmp=%2F8796.htm&utmht=1378374948269&utmac=UA-32426100-1&utmcc=__utma%3D60866808.1732016411.1378374935.1378374935.1378374935.1%3B%2B__utmz%3D60866808.1378374935.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&utmu=qB~

    def user_agent(browserversion, os, osversion)
      case os
        when "Macinstosh"
          return "Mozilla/5.0 (compatible; MSIE 10.0; Macintosh; #{osversion.gsub!(" ", " Mac OS X ")}; Trident/6.0)"
        when "Windows"
          trident = ""
          case browserversion
            when "10.0"
              trident = "Trident/6.0"
            when "9.0"
              trident = "Trident/9.0"
            when "8.0"
              trident = "Trident/4.0"
            else
              trident = "Trident/4.0"
          end
          browserversion = "MSIE #{browserversion}"
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
          return ["Mozilla/5.0 (compatible; #{browserversion}; #{os}; #{trident})",
                  "Mozilla/5.0 (compatible; #{browserversion}; #{os}; Win64; IA64; #{trident})",
                  "Mozilla/5.0 (compatible; #{browserversion}; #{os}; Win64; x64; #{trident})",
                  "Mozilla/5.0 (compatible; #{browserversion}; #{os}; WOW64; #{trident})"].sample
      end
    end
  end

end