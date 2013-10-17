module Visitors
  module Geolocations
  #----------------------------------------------------------------------------------------------------------------
  # crée un geolocation :
  #-----------+-----------------+--------------+-------------------------------------------------------------------
  #   OS      |   Localisation  |   outbound   |  Geolocation
  #           |   de            |   Flux       |
  #           |   l'exécution   |              |
  #-----------+-----------------+--------------+-------------------------------------------------------------------
  # Linux     |   home          |   debug      |  WebProxy      (le debugging sera réalisé par mitmproxy)
  # Linux     |   home          |   not debug  |  WebProxy
  # Linux     |   not home      |   ------------    use case not exist   ------------------------------------------
  # Windows   |   home          |   debug      |  MitmProxy
  # Windows   |   home          |   not debug  |  MitmProxy
  # Windows   |   not home      |   debug      |  FakeProxy
  # Windows   |   not home      |   not debug  |  Direct
  #-----------+-----------------+----------------------------------------------------------------------------------
  class Proxy < Geolocation
    attr :ip, :port

    def initialize(country)
      super country
    end
  end
  class Socks < Proxy
    def initialize(country)
      super(country)
    end
  end
  class Https < Proxy
    def initialize(country)
      super(country)
    end

    def update_profile(profile)
      profile['network.proxy.http'] = @ip
      profile['network.proxy.http_port'] = @port
      profile['network.proxy.ssl'] = @ip
      profile['network.proxy.ssl_port'] = @port
      profile['network.proxy.type'] = 1
      profile
    end
  end

  # class à utiliser
  class Tor < Socks
    def initialize
      @ip = "localhost"
      @port = 0000
      super("FR")
    end

    def update_profile(profile)
      profile['network.proxy.socks'] = @ip
      profile['network.proxy.socks_port'] = @port
      profile['network.proxy.type'] = 1
    end

  end
  class MitmProxy < Https
    def initialize
      @ip = "192.168.1.16"
      @port = 8080
      super("FR")
    end
  end
  class FakeProxy < Https
    def initialize
      @ip = "localhost"
      @port = 9999
      super("FR")
    end
  end
  class WebProxy < Https
    #TODO meo une factory de proxy qui delivre des ip/port à la demande lors de l'affecation d'un proxy à une geolocation : la factory s'appuie sur un fichier CSV dans un premier temps qui contient port/ip/anonimity degrees/country ; on expose une fonction qui retourne un couple port/ip  avec le plus haut degree d'anonitmity.    #
    def initialize
      @ip = "localhost"
      @port = 8010
      super("FR")
    end
  end
end
end