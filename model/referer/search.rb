module Referers
  class Search < Referer
    attr_reader            :landing_page,
                :search_engine_page
    HOSTNAME_SEARCH_ENGINE = "www.google.fr"
    PATH_SEARCH_ENGINE = "/"

    def initialize(medium, source, keyword, start_date_time, visit_id, landing_page)
      @start_date_time = start_date_time
      @landing_page = landing_page
      # on ne gère que le moteur de recherche google pour le moment
      @search_engine_page = Page.new({"id_uri" => "0",
                                      "delay_from_start" => "0",
                                      "hostname" => HOSTNAME_SEARCH_ENGINE,
                                      "page_path" => PATH_SEARCH_ENGINE}, start_date_time, visit_id)
      super(landing_page, medium, source, keyword, "(not set)")
    end

    def browse()
      #TODO meo en le search dans le moteur avec accès à la page du moteur, saisie des keywords et click sur le bouton recherche
      p "je ne fais rien pour le moment"
    end

    def display()
      super.display
      p self.to_s
    end
    def start_date_time
      @search_engine_page.start_date_time
    end
    def to_s()
      "start date time : #{@start_date_time}\n" + \
      "landing page : #{@landing_page}"
    end

    def plan(scheduler)
      @search_engine_page.plan(scheduler)
    end

    def url
      @search_engine_page.url
    end
  end
end