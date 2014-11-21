require 'uri'
require_relative '../../../lib/error'
module Visits
  module Referrers
    class Referral < Referrer

      attr :page_url, # URI de la page referral
           :duration

      include Errors

      def initialize(referer_details, landing_page)


        begin
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "landing_page"}) if landing_page.nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "referral_path"}) if referer_details[:referral_path].nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "duration"}) if referer_details[:duration].nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "source"}) if referer_details[:source].nil?

          super(landing_page)

          @page_url = referer_details[:source].start_with?("http:") ?
              URI.join(referer_details[:source], referer_details[:referral_path]) :
              URI.join("http://#{referer_details[:source]}", referer_details[:referral_path])
          @duration = referer_details[:duration]

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(REFERRER_NOT_CREATE, :error => e)

        else
          @@logger.an_event.debug "referral create"

        ensure

        end
      end

    end
  end
end
