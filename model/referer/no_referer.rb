module Referers
  class NoReferer < Referer

    def initialize(landing_page)
       super(landing_page, "(none)", "(direct)", "(not set)", "(not set)")
    end

    def plan(scheduler)
      p "no referer's plan"
    end
  end
end