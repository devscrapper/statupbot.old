module VisitorFactory
  class Nationality
    class NationalityException < StandardError
    end
  end
  attr :code_langue2, #code langue sur 2 positions
       :charset_iso,
       :charset_win

  def language
    @code_langue2
  end

  #--------------------------------------------------------------------------------------------------------------
  # Navigateur  | Os        | charset
  #--------------------------------------------------------------------------------------------------------------
  # FF          | windows   | charset_win
  # FF          | Linux     | charset_iso    à valider
  # FF          | Macintosh | charset_iso    à valider
  # FF          | Android   | charset_iso    à valider
  #--------------------------------------------------------------------------------------------------------------
  # IE          | windows   | charset_iso
  #--------------------------------------------------------------------------------------------------------------
  # Chrome      | windows   | charset_iso
  # Chrome      | linux     | charset_iso   à valider
  # Chrome      | Macintosh | charset_iso   à valider
  # Chrome      | Android   | charset_iso   à valider
  # Chrome      | iOS       | charset_iso   à valider
  #--------------------------------------------------------------------------------------------------------------
  # Safari      | windows   | à déterminer
  # Safari      | iOS       | à déterminer
  # Safari      | Macintosh | à déterminer
  #--------------------------------------------------------------------------------------------------------------
  # mot clé utulisés pour les requetes de scraping de google analitycs :
  # Browser : "Chrome", "Firefox", "Internet Explorer", "Safari"
  # operatingSystem:  "Windows", "Linux", "Macintosh"
  def charset(operating_system, browser)
    case browser
      when "Firefox"
        case operating_system
          when "Windows"
            @charset_win
          when "Linux"
            @charset_iso
          when "Macintosh"
            @charset_iso
          when "Android"
            @charset_iso
          else
            raise NationalityException, "unknown operating system #{operating_system}"
        end
      when "Internet Explorer"
        case operating_system
          when "Windows"
            @charset_iso
          else
            raise NationalityException, "unknown operating system #{operating_system}"
        end
      when "Chrome"
        @charset_iso
      when "Safari"
        @charset_iso
      else
        raise NationalityException, "unknown browser #{browser}"
    end

  end
end

require_relative "french"