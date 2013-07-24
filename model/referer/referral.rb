require_relative '../page'
module Referers
  class Referral < Referer

    attr_reader :referral_page,
                :landing_page

    def initialize(medium, source, referral_path, start_date_time, visit_id, landing_page)
      @start_date_time = start_date_time
      @landing_page = landing_page
      @referral_page = Page.new({"id_uri" => "0",
                                       "delay_from_start" => "0",
                                       "hostname" => source,
                                       "page_path" => referral_path}, start_date_time, visit_id)
      super(landing_page, medium, source, "(not set)", referral_path)

    end

    def browse()
      @referral_page.browse
    end

    def display()
      super.display
      p self.to_s
    end

    def plan(scheduler)
      @referral_page.plan(scheduler)
    end
    def start_date_time
      @referral_page.start_date_time
    end
    def to_s()
      "start date time : #{@start_date_time}\n" + \
         "landing page : #{@landing_page}"
    end
    def url
      @referral_page.url
    end
  end
end
