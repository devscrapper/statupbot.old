require_relative '../../lib/flow'
require_relative '../../lib/error'
require_relative 'geolocation'
require 'eventmachine'
module Geolocations
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include Errors
  #----------------------------------------------------------------------------------------------------------------
  # Message exception
  #----------------------------------------------------------------------------------------------------------------
  class GeolocationError < Error
  end
  ARGUMENT_UNDEFINE = 1300
  NONE_GEOLOCATION = 1301
  GEO_BAD_PROPERTIES = 1302
  GEO_NOT_AVAILABLE = 1303
  GEO_FILE_NOT_FOUND = 1304
  GEO_NONE_FRENCH = 1305

  class GeolocationFactory


    EOFLINE ="\n"
    attr :geolocations,
         :geolocations_file,
         :logger

    TMP = Pathname(File.join(File.dirname(__FILE__), "..", "..", "tmp")).realpath


    def initialize(delay_periodic_load, logger)
      @logger = logger
      @logger.an_event.debug "BEGIN GeolocationFactory.initialize"

      raise GeolocationError.new(ARGUMENT_UNDEFINE), "delay_periodic_load undefine" if delay_periodic_load.nil?

      begin

        basename = ["geolocations", $staging, Date.today.strftime("%Y-%m-%d")].join("_")
        absolute_path = File.join(TMP, "#{basename}.txt")

        @geolocations_file = Flow.from_absolute_path(absolute_path).last

        raise GeolocationError.new(GEO_FILE_NOT_FOUND), "geolocation file not found" if @geolocations_file.nil?

        @geolocations = []


        #premier chargement pour eviter d'avoir des erreur, car l'EM::periodic déclenche dans le dealy et pas à zero
        load

        EM.add_periodic_timer(delay_periodic_load) do
          load
        end

      rescue GeolocationError => e
        raise e

      rescue Exception => e
        @logger.an_event.error e.message

        retry

      ensure

        @logger.an_event.debug "END GeolocationFactory.initialize"

      end
    end


    def clear
      @logger.an_event.debug "BEGIN GeolocationFactory.clear"

      #@geolocations.each { |geo| @geolocations.delete(geo) }
      @geolocations = []

      @logger.an_event.debug "END GeolocationFactory.clear"
    end


    # retourne un objet geolocation ou
    # retourne une exception si plus aucun geolocation dans la factory
    def get
      @logger.an_event.debug "BEGIN GeolocationFactory.get"

      begin

        raise GeolocationError.new(NONE_GEOLOCATION) if @geolocations.size == 0

        geo = @geolocations.shift

        geo.available?

      rescue Exception => e

        case e.code
          when NONE_GEOLOCATION

            raise e

          when GEO_NOT_AVAILABLE

            retry

          else
            @logger.an_event.error e.message
        end

      else
        # on range la gelocation pour conserver une file tournante.
        @geolocations << geo

      ensure

        @logger.an_event.debug "END GeolocationFactory.get"

      end

      geo

    end

    # retourne un objet geolocation ou
    # retourne une exception si plus aucun geolocation dans la factory
    def get_french
      @logger.an_event.debug "BEGIN GeolocationFactory.get_french"

      begin

        geo_count = @geolocations.size
        geo = get
        i = 1

        while geo.country != "fr" and i < geo_count
          geo = get
          i += 1
        end

      rescue Exception => e
        #si il n'y a plus de geo dans la factory
        raise e

      else
        #on sort de la boucle :
        # soit on a trouve une geo francais
        # soit parce que on les a tous passé et il n'y a aucun geolocation francais => execption
        raise GeolocationError.new(GEO_NONE_FRENCH), "none french geolocation" unless geo.country == "fr"

      ensure

        @logger.an_event.debug "END GeolocationFactory.get_french"
        return geo
      end
    end


    def to_s
      @geolocations.join("\n")
    end

    def load
      @logger.an_event.debug "BEGIN GeolocationFactory.load"

      clear

      @geolocations_file.foreach(EOFLINE) { |geo_line|

        begin

          @geolocations << Geolocation.new(geo_line)

        rescue Exception => e

          @logger.an_event.warn e.message

        end
      }

      @geolocations_file.close

      @logger.an_event.info "#{@geolocations.size} geolocation(s) loaded"

      @logger.an_event.debug "END GeolocationFactory.load"
    end
  end
end