require_relative 'header'
require_relative 'request_parameters'
require_relative '../geolocation/geolocation'
require_relative '../../model/geolocation/direct'
require_relative '../../model/geolocation/proxy'
require_relative '../../model/geolocation/tor'
require_relative '../visitor'
module CustomGifRequest
  class CustomGifRequest
    attr :request_parameters
    attr_reader :header, :visitor_id


    def initialize(visitor, referer)
      @visitor_id = visitor.id
      @header = Header.new(visitor)
      @request_parameters = RequestParameters.new(visitor, referer)
      @geolocation = visitor.geolocation
    end

    def relay_to(uri, query, header, http_handler, logger)#, referer)
      logger.an_event.debug "query before customize : #{query}"
      query = @request_parameters.customize(query)#, referer)
      logger.an_event.debug "query after customize : #{query}"
      logger.an_event.debug "header before customize : #{header}"
      header = @header.customize(header)
      logger.an_event.debug "header after customize : #{header}"
      @geolocation.go_to(uri, query, header, http_handler, @visitor_id, logger)
    end

    def to_s
      @request_parameters.to_s + "\n" + \
      @header.to_s + "\n" + \
      @visitor_id
    end

  end

end