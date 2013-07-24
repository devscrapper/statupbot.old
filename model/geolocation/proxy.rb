module Geolocations
  class Proxy < Geolocation
    class ProxyException < StandardError

    end
    #TODO meo une factory de proxy qui delivre des ip/port à la demande lors de l'affecation d'un proxy à une geolocation : la factory s'appuie sur un fichier CSV dans un premier temps qui contient port/ip/anonimity degrees/country ; on expose une fonction qui retourne un couple port/ip  avec le plus haut degree d'anonitmity.
    attr :ip, :port

    def initialize
      @ip = "localhost"
      @port = 8010
      super("FR", "fr")
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un proxy
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display()
      super.display
      p "ip : #{@ip}"
      p "port : #{@port}"
    end

    def go_to(uri, query, header, http_handler,visitor_id,logger)
      connection_opts = {
          :proxy => {
              :host => @ip,
              :port => @port,
              # :authorization => ['username', 'password']
          }
      }
      super(uri, query, header,http_handler, connection_opts, visitor_id, logger)
    end

    def to_s()
      "#{self.class}(#{object_id}) : ip #{@ip}, port #{@port}, #{super.to_s}"
    end

  end
end
