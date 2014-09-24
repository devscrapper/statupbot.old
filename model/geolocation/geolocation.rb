require 'net/http'

module Geolocations
  class Geolocation
    SEPARATOR = ";"

    attr_accessor :country,
                  :protocol,
                  :ip,
                  :port,
                  :user,
                  :password

    def initialize(geo_line)
      # accepte les hsotname ou les @ip pour <ip>
      r = /(?<country>.*)#{SEPARATOR}(?<protocol>http);(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|.*\..*\..*);(?<port>\d{1,5});(?<user>.*);(?<password>.*)/.match(geo_line)
      unless r.nil?
        @country = r[:country]
        @protocol = r[:protocol]
        @ip = r[:ip]
        @port = r[:port]
        @user = r[:user]
        @password = r[:password]
      else
        raise GeolocationError.new(GEO_BAD_PROPERTIES), "geolocation bad properties : #{geo_line}"
      end
    end

    def available?
      begin
        response = Net::HTTP::Proxy(@ip, @port).start('www.ruby-doc.org') { |http|}
      rescue Exception => e
        case response
          when Net::HTTPSuccess
            true
          else
            raise GeolocationError.new(GEO_NOT_AVAILABLE), "geolocation non available"
        end
      end
    end

    def to_s
      "#{@country} - #{@protocol} - #{@ip} - #{@port} - #{@user} - #{@password}"
    end
  end
end