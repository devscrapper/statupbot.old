require_relative 'header'
require_relative 'request_parameters'
require_relative '../geolocation/geolocation'
require_relative '../../model/geolocation/direct'
require_relative '../../model/geolocation/proxy'
require_relative '../../model/geolocation/tor'

module CustomGifRequest
  class CustomGifRequest
    attr :request_parameters
    attr_reader :header, :visitor_id
    DIR_INTERNET = File.dirname(__FILE__) + "/../../internet"
    SUCCESS = "success"
    FAIL = "fail"
    @@sem = Mutex.new

    def initialize(visitor)
      @visitor_id = visitor.id
      @header = Header.new(visitor)
      @request_parameters = RequestParameters.new(visitor)
      @geolocation = visitor.geolocation
    end

    def relay_to(url, header)
      begin
        query = @request_parameters.customize(url)
        header = @header.customize(header)
        @geolocation.go_to(query, header)
        success_to_file(query, header)
      rescue Exception => e
        fail_to_file(query, header)
        raise e
      end
    end

    def success_to_file(query, header)
      data = data_to_file(query, header)
      @@sem.synchronize {
        flow = Flow.new(DIR_INTERNET, SUCCESS, @visitor_id, Date.today, Time.now.hour)
        flow.append(data)
        flow.close
      }
    end

    def fail_to_file(query, header)
      data = data_to_file(query, header)
      @@sem.synchronize {
        flow = Flow.new(DIR_INTERNET, FAIL, @visitor_id, Date.today, Time.now.hour)
        flow.append(data)
        flow.close
      }
    end

    private
    def data_to_file(query, header)
      "#{@geolocation.to_s}\n#{@geolocation.class}(#{@geolocation.object_id}) : header #{header}\n#{@geolocation.class}(#{@geolocation.object_id}) : query #{query}"
    end

  end

end