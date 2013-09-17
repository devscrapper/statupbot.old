module VisitorFactory
  class Geolocation
    class GeolocationException < StandardError
    end

    attr :country
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # build
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
    require 'rbconfig'

    def self.build()
      @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          if VisitorFactory.home
            return MitmProxy.new()
          else
            # if debug queries google (parameter debug_outbound_queries=true) alors fakeproxy sinon Direct avec utilisation des paramettre system
            if VisitorFactory.debug_outbound_queries
              return FakeProxy.new()
            else
              Direct.new()
            end
          end
        #when /darwin|mac os/
        #  :macosx
        when /linux/
          return WebProxy.new()
        #when /solaris|bsd/
        #  :unix
        else
          raise GeolocationException, "unknown os: #{host_os.inspect}"
      end
      )
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(country)
      @country = country
    end

  end
end
