
module VisitorFactory
  class French < Nationality
    class FrenchException < StandardError
    end

    def initialize
      @code_langue2 = "FR"
      @charset_iso = "ISO-8859-1"
      @charset_win = "windows-1252"
    end


    def utmul_for_browser(browser)
      return "fr" if browser.is_a?(InternetExplorer)
      return "fr-fr" if browser.is_a?(Firefox)
      return "fr" if browser.is_a?(Chrome)
      return "fr-fr" if browser.is_a?(Safari)

      raise FrenchException, "browser #{browser.class} unknown"

    end
  end
end