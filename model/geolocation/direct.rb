module Geolocations
  class Direct < Geolocation
    class DirectException < StandardError

    end

    def initialize()
      super("FR", "fr")
    end

    def go_to(query, header)
      http = EM::HttpRequest.new(query).get :redirects => 5, :head => header
      http.callback {
        response = EM::DelegatedHttpResponse.new(self)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
      http.errback {
        raise DirectException, "#{http.error}/#{http.response}"
      }
    end

    def to_s()
      "#{self.class}(#{object_id}) :#{super.to_s}"
    end
  end
end