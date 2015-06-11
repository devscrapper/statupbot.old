require_relative '../../lib/error'

module Pages
  #----------------------------------------------------------------------------------------------------------------
  # action                    | id | produce Page
  #----------------------------------------------------------------------------------------------------------------
  # go_to_start_landing	      | a	 | Website
  # go_to_start_engine_search	| b	 | SearchEngine
  # go_back_engine_search	    | c	 | SearchEngine
  # go_to_landing	            | d	 | Website
  # go_to_referral	          | e	 | UnManage
  # go_to_search_engine 	    | f	 | SearchEngine
  # sb_search 	              | 0	 | Results
  # sb_final_search 	        | 1	 | Results
  # cl_on_next 	              | A	 | Results
  # cl_on_previous 	          | B	 | Results
  # cl_on_result 	            | C	 | UnManage
  # cl_on_landing 	          | D	 | Website
  # cl_on_link_on_website 	  | E	 | Website
  # cl_on_advert	            | F	 | UnManage
  # cl_on_link_on_unknown	    | G	 | UnManage
  # cl_on_link_on_advertiser	| H	 | UnManage
  #----------------------------------------------------------------------------------------------------------------
  class Results < Page
    #----------------------------------------------------------------------------------------------------------------
    # include class
    #----------------------------------------------------------------------------------------------------------------
    include Errors

    #----------------------------------------------------------------------------------------------------------------
    # message exception
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # constant
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :links,
                :landing_link,
                :next,
                :prev,
                :body

    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # initialize
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------

    def initialize(visit, browser)
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "visit"}) if visit.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser"}) if browser.nil?

        start_time = Time.now

        @body = browser.body
        @@logger.an_event.debug "body #{@body}"
        nxt = browser.engine_search.next(@body)
        prv = browser.engine_search.prev(@body)
        @links = browser.engine_search.links(@body)

        @landing_link = visit.landing_link

        super(browser.url,
              browser.title,
              visit.referrer.search_duration,
              Time.now - start_time)

        @next = Pages::Link.new(nxt[:href], @title, nxt[:text]) unless nxt.empty?
        @prev = Pages::Link.new(prv[:href], @title, prv[:text]) unless prv.empty?

        # suppression du landing dans les resultats pour ne pas cliquer dessus
        # suppression des liens sur des pdf
        @links.delete_if { |l|
          true if l[:href] == @landing_link.url or !l[:href].rindex(".pdf").nil?

        }
        @links.map! { |l|
          begin
            Pages::Link.new(l[:href], @title, l[:text])
          rescue Exception => e
            @@logger.an_event.debug "link #{l["href"]} #{e.message}"
          end
        }

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(PAGE_NOT_CREATE, :error => e)

      else
        @@logger.an_event.debug "#{self.to_s}"

      end
    end

    #----------------------------------------------------------------------------------------------------------------
    # landing
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # ouput : landing link
    # exception : landing link not found
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def landing_link
      @landing_link
    end

    #----------------------------------------------------------------------------------------------------------------
    # link
    #----------------------------------------------------------------------------------------------------------------
    # input : RAS
    # ouput : un link choisit au hasard
    # exception : aucun link trouv�
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------------------------------
    def link
      #retourne un element choisit au hasard et le supprime de la liste
      #quand la liste est vide alors remonte une exception
      link = @links.shuffle!.shift
      raise Error.new(PAGE_NONE_LINK, :values => {:url => url}) if link.nil?
      link
    end

    def to_s
      "Page : #{self.class.name}\n" +
          super.to_s +
          "next : #{@next}\n" +
          "prev : #{@prev}\n" +
          "landing_link : #{@landing_link}\n" +
          "links (#{@links.size}): \n#{@links.map{|t| "#{t}\n"}.join("")}\n" +
          "body : #{}\n"
    end

  end
end
