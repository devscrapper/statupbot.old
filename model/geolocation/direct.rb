require_relative "../flow"

module Geolocations
  class Direct < Geolocation
    class DirectException < StandardError

    end

    def initialize()
      super("FR", "fr")
    end

    def go_to(uri,query, header,http_handler,visitor_id, logger)
      super(uri, query, header,http_handler, {}, visitor_id, logger)
    end

    def to_s()
      "#{self.class}(#{object_id}) :#{super.to_s}"
    end
  end
end