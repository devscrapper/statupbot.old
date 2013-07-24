require_relative 'browser/browser'

class UserAgent
  class UseAgentException < StandardError
  end


  def self.build(browser)
    return UserAgent.ie(browser.browser_version, browser.operating_system, browser.operating_system_version) if browser.is_a?(Browsers::InternetExplorer)
    return firefox(browser.browser_version, browser.operating_system, browser.operating_system_version) if  browser.is_a?(Browsers::Firefox)
    return chrome(browser.browser_version, browser.operating_system, browser.operating_system_version) if browser.is_a?(Browsers::Chrome)
    return safari(browser.browser_version, browser.operating_system, browser.operating_system_version) if browser.is_a?(Browsers::Safari)
    raise UserAgentException, "browser #{browser.class} is unknown"
  end

  def self.ie(browserversion, os, osversion)
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

  def self.chrome(browserversion, os, osversion)
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

  def self.firefox(browserversion, os, osversion)
    case os
      when "Macintosh"
        return "Mozilla/5.0 (Macintosh; #{osversion.gsub!(" ", " Mac OS X ")}; rv:#{browserversion}) Gecko/20100101 Firefox/#{browserversion}"
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
        return ["Mozilla/5.0 (#{os}; WOW64; rv:#{browserversion}) Gecko/20130401 Firefox/#{browserversion}",
                "Mozilla/5.0 (#{os}; rv:#{browserversion}) Gecko/20100101 Firefox/#{browserversion}",
                "Mozilla/5.0 (#{os}; Win64; x64; rv:#{browserversion}) Gecko/20130328 Firefox/#{browserversion}"].sample
      when "Linux"
        return ["Mozilla/5.0 (X11; Linux x86_64; rv:#{browserversion}) Gecko/20100101 Firefox/#{browserversion}",
                "Mozilla/5.0 (X11; Linux i686; rv:#{browserversion}) Gecko/20100101 Firefox/#{browserversion}"].sample
    end
  end


  def self.safari(browserversion, os, osversion)
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