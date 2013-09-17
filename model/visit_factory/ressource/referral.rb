module VisitFactory
  module Ressources
    class Referral < Ressource
      class ReferralException < StandardError

      end
      DURATION = 5

      def initialize(source, referral_path, start_date_time)
        super("#{source}#{referral_path}",
              start_date_time-DURATION,
              DURATION)
      end
    end
  end
end