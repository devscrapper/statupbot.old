require_relative 'nationality'
require_relative '../browser/browser'
module Nationalities
  class French < Nationality
    class FrenchException < StandardError
    end

    include Browsers

    def accept_language
      "fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4"
    end

    def utmcs
      "iso-8859-1"
    end

    def utmul_for_browser(browser)
      return "fr" if browser.is_a?(Browsers::InternetExplorer)
      return "fr-fr" if browser.is_a?(Browsers::Firefox)
      return "fr" if browser.is_a?(Browsers::Chrome)
      return "fr-fr" if browser.is_a?(Browsers::Safari)

      raise FrenchException, "browser #{browser.class} unknown"

    end
  end
end