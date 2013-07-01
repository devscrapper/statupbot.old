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

    def go_to(query, header)
      #proxy socks
      # af aire

      #connection_opts = {
      #        :proxy => {
      #            :host => @ip,
      #            :port => @port,
      #            # :authorization => ['username', 'password']
      #        }
      #    }
      #    http = EM::HttpRequest.new(query, connection_opts).get :redirects => 5, :head => header
      #    http.callback {
      #      response = EM::DelegatedHttpResponse.new(self)
      #      response.headers=http.response_header
      #      response.content = http.response
      #      response.send_response
      #    }
      #http.errback {
      #  raise  DirectException, "#{http.error}/#{http.response}"
      #}
    end

    def to_s()
      "#{self.class}(#{object_id}) : ip #{@ip}, port #{@port}, #{super.to_s}"
    end
  end
end