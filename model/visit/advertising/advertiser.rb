require_relative '../../../lib/error'
module Visits
  module Advertisings
    class Advertiser
      #----------------------------------------------------------------------------------------------------------------
      # include class
      #----------------------------------------------------------------------------------------------------------------

      include Errors
      #----------------------------------------------------------------------------------------------------------------
      # variable class
      #----------------------------------------------------------------------------------------------------------------
      @@logger = nil
      #----------------------------------------------------------------------------------------------------------------
      # attribut
      #----------------------------------------------------------------------------------------------------------------
      attr :durations,
           :arounds

      #----------------------------------------------------------------------------------------------------------------
      # instance methods
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # initialize
      #----------------------------------------------------------------------------------------------------------------
      #----------------------------------------------------------------------------------------------------------------
      # input :
      #----------------------------------------------------------------------------------------------------------------
      def initialize(advertiser_details)
        @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)

        @@logger.an_event.debug "durations #{advertiser_details[:durations]}"
        @@logger.an_event.debug "arounds #{advertiser_details[:arounds]}"

        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "durations"}) if advertiser_details[:durations].nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "arounds"}) if advertiser_details[:arounds].nil?

        @durations = advertiser_details[:durations]
        @arounds = advertiser_details[:arounds]
      end


      def next_duration
        @durations.first
      end

      def next_around
        @arounds.first
      end

      def to_s
        "durations : #{@durations}\n" +
            "arounds : #{@arounds}\n"
      end
    end
  end
end