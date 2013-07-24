module Geolocations
  class Tor < Geolocation
    class TorException < StandardError

    end
    attr :ip, :port

    def initialize
      @ip = "localhost"
      @port = 8010
      super("FR", "fr")
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un tor
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display()
      super.display
      p "ip : #{@ip}"
      p "port : #{@port}"
    end

    def go_to(uri,query, header, http_handler, visitor_id, logger)
      connection_opts = {
          :proxy => {
              :host => @ip,
              :port => @port,
              :type => :socks5
              # :authorization => ['username', 'password']
          }
      }
      super(uri, query, header, http_handler, connection_opts, visitor_id, logger)
    end

    def to_s()
      "#{self.class}(#{object_id}) : ip #{@ip}, port #{@port}, #{super.to_s}"
    end
  end
end