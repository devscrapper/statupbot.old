module Browsers
  class Chrome < Browser
    class ChromeException < StandardError

    end
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #["browser", "Firefox"]
    #["browser_version", "16.0"]
    #["operating_system", "Windows"]
    #["operating_system_version", "7"]
    def initialize(browser_details, nationality, user_agent)
      super(browser_details, user_agent)

      @profile['intl.accept_languages'] = "#{nationality.language.downcase}-#{nationality.language},#{nationality.language.downcase};q=0.8,en-US;q=0.6,en;q=0.4"
      @profile['network.http.accept-encoding'] = 'gzip,deflate,sdch'

      cq = CustomQuery.new("http://www.google-analytics.com/__utm.gif")
      cq.add_var_http("Accept", "image/webp,*/*;q=0.8")
      # Liste des variables customisable par le proxy (car pas le choix)
      # utmcs : charset
      # utmsr : screen resolution
      # utmsc : Screen color depth 	utmsc=24-bit
      # utmje : indicates if browser is Java-enabled. 1 is true. 	utmje=1
      # utmfl : #	Flash Version 	utmfl=9.0%20r48&
      # utme : variable personnalisée
      # utmul : Browser language. 	utmul=fr
      cq.add_var_query("utmcs", nationality.charset(browser_details[:operating_system], browser_details[:name]))
      cq.add_var_query("utmul", nationality.language.downcase)
      cq.add_var_query("utmsr", browser_details[:screen_resolution])
      cq.add_var_query("utmsc", browser_details[:screens_colors])
      cq.add_var_query("utmje", (browser_details[:java_enabled]=="Yes" ? 1 : 0))
      cq.add_var_query("utmfl", browser_details[:flash_version])
      cq.add_var_query("utme", "Chrome#{browser_details[:version]} \
      #{browser_details[:operating_system]} \
      #{browser_details[:operating_system_version]}")
      @custom_queries << cq
    end

    def user_agent(browserversion, os, osversion)
      case os
        when "Macintosh"
          return "Mozilla/5.0 (Macintosh; #{osversion.gsub!(" ", " Mac OS X ")}) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/#{browserversion} Safari/537.17"
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
          return ["Mozilla/5.0 (#{os}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/#{browserversion} Safari/537.36",
                  "Mozilla/5.0 (#{os}; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/#{browserversion} Safari/537.36"].sample
        when "Linux"
          ["Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/#{browserversion} Safari/536.5",
           "Mozilla/5.0 (X11; Linux i686) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/#{browserversion} Safari/536.5"].sample
      end
    end


  end
end