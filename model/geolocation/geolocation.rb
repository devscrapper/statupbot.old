module Geolocations
  class Geolocation
    class GeolocationException < StandardError

    end
    DIR_INTERNET = File.dirname(__FILE__) + "/../../internet"
    SUCCESS = "success"
    FAIL = "fail"
    @@sem = Mutex.new
    attr :country,
         :language  # n'est pas utilisé pour calculer le accept_language et utmul car ces valeurs doivent être initialisée avec le langage du visitor.
    #en effet, un visitor peut être francais et se connecté à l'etranger, natrellement ou au travers d'un proxy, de la même manière avce un mobile
    #on ne maitrise plus la loclisation d'un visitor

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    # build
    #----------------------------------------------------------------------------------------------------------------
    # crée un geolocation :
    #----------------------------------------------------------------------------------------------------------------
    # input :
    # une visite qui est une ligne du flow : published-visits_label_date_hour.json, sous forme de hash
    #["id_visit", "162"]
    #["start_date_time", "2013-04-21 00:09:00 +0200"]
    #["account_ga", "pppppppppppppp"]       => non repris car fourni par lexecution de la page dans phantomjs
    #["return_visitor", "true"]
    #["browser", "Firefox"]
    #["browser_version", "16.0"]
    #["operating_system", "Windows"]
    #["operating_system_version", "7"]
    #["flash_version", "11.4 r402"]
    #["java_enabled", "No"]
    #["screens_colors", "24-bit"]
    #["screen_resolution", "1366x768"]
    #["referral_path", "(not set)"]
    #["source", "(direct)"]
    #["medium", "(none)"]
    #["keyword", "(not set)"]
    #["pages", [{"id_uri"=>"19155", "delay_from_start"=>"10", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-cadaujac.htm", "title"=>"Centre d'\u00E9pilation laser CADAUJAC centres de remise en forme CADAUJAC"}, {"id_uri"=>"19196", "delay_from_start"=>"15", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-le_pian_medoc_.htm", "title"=>"Centre d'\u00E9pilation laser LE PIAN M\u00C9DOC  centres de remise en forme LE PIAN M\u00C9DOC"}, {"id_uri"=>"19253", "delay_from_start"=>"39", "hostname"=>"centre-gironde.epilation-laser-definitive.info", "page_path"=>"/ville-33-yvrac.htm", "title"=>"Centre d'\u00E9pilation laser YVRAC centres de remise en forme YVRAC"}, {"id_uri"=>"115", "delay_from_start"=>"12", "hostname"=>"www.epilation-laser-definitive.info", "page_path"=>"/en/", "title"=>"Final Laser depilation"}]]
    #----------------------------------------------------------------------------------------------------------------
    def self.build(visit)
      # return by default : direct
      return Direct.new() #if visit["return_visitor"] == "true" #pour tester
      #   return Proxy.new()  if visit["return_visitor"] == "false" #pour tester
    end

    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    def initialize(country, language)
      @country = country
      @language = language
    end

    #----------------------------------------------------------------------------------------------------------------
    # display
    #----------------------------------------------------------------------------------------------------------------
    # affiche le contenu d'un geolocation
    #----------------------------------------------------------------------------------------------------------------
    # input :
    #----------------------------------------------------------------------------------------------------------------
    def display()
      p "+----------------------------------------------"
      p "| GEOLOCATION                                     |"
      p "+---------------------------------------------+"
      p "| country : #{@country}"
      p "| language : #{@language}"
      p "+----------------------------------------------"
      p "| GEOLOCATION                                     |"
      p "+---------------------------------------------+"
    end


    def go_to(uri, query, header, http_handler, connection_opts={}, visitor_id, logger)
      http = EM::HttpRequest.new(uri, connection_opts).get :redirects => 5, :head => header , :query => query
      http.callback {
        logger.an_event.info "visitor #{header["User-Agent"]} browse #{uri}"
        success_to_file(uri, query, header, visitor_id)
        response = EM::DelegatedHttpResponse.new(http_handler)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
      http.errback {
        logger.an_event.error "visitor #{header["User-Agent"]} cannot browse #{uri}"
        fail_to_file(uri, query, header, visitor_id)
        response = EM::DelegatedHttpResponse.new(http_handler)
        response.headers=http.response_header
        response.content = http.response
        response.send_response
      }
    end


    private
    def data_to_file(uri, query, header)
      headers = ""
      header.each_pair{|k,v| headers += "#{k} : #{v}\n"}
      "B---------------------------\n" + \
       "country : #{@country}\nlanguage : #{@language}\n" + \
      "B-HEADER--------------------\n" + \
      headers  + \
      "E-HEADER--------------------\n" + \
      "B-URI-----------------------\n" + \
      "#{uri}\n"  + \
      "E-URI-----------------------\n" + \
      "B-QUERY---------------------\n" + \
      "#{query.gsub!(/&/, "\n")}\n" + \
      "E-QUERY---------------------\n" + \
      "E---------------------------\n"
    end

    def success_to_file(uri,query, header, visitor_id)
      p SUCCESS
      begin
        data = data_to_file(uri,query, header)
        @@sem.synchronize {
          flow = Flow.new(DIR_INTERNET, SUCCESS, visitor_id, Date.today, Time.now.hour)
          flow.append(data)
          flow.close
        }
      rescue Exception => e
        p e.message
      end
    end

    def fail_to_file(uri, query, header, visitor_id)
      p FAIL
      begin
        data = data_to_file(uri,query, header)
        @@sem.synchronize {
          flow = Flow.new(DIR_INTERNET, FAIL, visitor_id, Date.today, Time.now.hour)
          flow.append(data)
          flow.close
        }
      rescue Exception => e
        p e.message
      end
    end
  end
end
