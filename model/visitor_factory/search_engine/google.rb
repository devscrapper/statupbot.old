module VisitorFactory
  module SearchEngines
    class Google < SearchEngine
      class GoogleException < StandardError
      end

      URL = "http://www.google.fr"
      attr :driver,
           :sleeping_time # permet d'attendre qu'une page est affichée

      def initialize(driver, sleeping_time)
        @driver = driver
        @sleeping_time = sleeping_time
      end

      # recherche les mots chez google
      # positionne le driver (firefox) sur la premiere page de resultat
      # retourne le numero de la page
      # si pas de resultat alors retourne la page 0
      def search(keywords)
        @driver.get URL
        element = @driver.find_element(:name, 'q')
        element.send_keys keywords
        element.submit
        sleep(@sleeping_time)
        begin
          @driver.find_element(:class, "cur").text.to_i
        rescue Exception => e
          0
        end
      end

      # click sur la fleche/page  suivante si elle existe et retourne le numero de la nouvelle page
      # Si il ny a pas de fleche suivante alors retourne 0
      def next
        begin
          @driver.find_element(:id => "pnnext").click
          sleep(sleeping_time)
          @driver.find_element(:class, "cur").text.to_i
        rescue Exception => e
          # pnnext n'est pas trouvé dans la page
          0
        end
      end

      #determine si l'url du landing page est dans la page courante
      # si l'url est dans la page alors true, sinon false
      # si un pb alors false
      def exist?(url)
        begin
          @driver.find_elements(:tag_name, "a").each { |a|
            return true if (a[:href] == ((url.start_with?("http://")) ? url : ("http://"+url)))
          }
          return false
        rescue Exception => e
          false
        end
      end
    end
  end
end