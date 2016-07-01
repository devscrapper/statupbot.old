require_relative '../../lib/error'
require_relative '../../lib/captcha'
require "base64"

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
  class Captcha < Page
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
    TMP = Pathname(File.join(File.dirname(__FILE__), "..", "..", "tmp")).realpath
    #----------------------------------------------------------------------------------------------------------------
    # variable de class
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # attribut
    #----------------------------------------------------------------------------------------------------------------
    attr_reader :input, # zone de saisie du capcha
                :type, #type de la zone de saisie
                :submit_button, # bouton de validation du formulaire de saisie de captcha
                :image, # le capcha sous forme image
                :str # la représentation du captcha sous forme d'une chaine de caractere
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

    def initialize(browser)
      begin
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser"}) if browser.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser.engine_search"}) if  browser.engine_search.nil?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser.engine_search.id_captcha"}) if browser.engine_search.id_captcha.nil? or browser.engine_search.id_captcha.empty?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser.engine_search.type_captcha"}) if browser.engine_search.type_captcha.nil? or  browser.engine_search.type_captcha.empty?
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "browser.engine_search.label_button_captcha"}) if browser.engine_search.label_button_captcha.nil? or  browser.engine_search.label_button_captcha.empty?

        @@logger.an_event.debug "engine_search : #{browser.engine_search}"

        @input = browser.engine_search.id_captcha
        @type = browser.engine_search.type_captcha
        @submit_button = browser.engine_search.label_button_captcha

        @@logger.an_event.debug "input #{@input}"
        @@logger.an_event.debug "type #{@type}"
        @@logger.an_event.debug "submit_button #{@submit_button}"

        super(browser.url,
              browser.title,
              0,
              0)

        captcha_file = Flow.new(TMP, "captcha", browser.name, Date.today, nil, ".png")
        @@logger.an_event.debug "captcha file :  #{captcha_file.absolute_path}"

        browser.take_screenshot(captcha_file)

        @image = Base64.urlsafe_encode64(captcha_file.read)
        @@logger.an_event.debug "encode image en base64"

        # TODO convertir le captcha en string
        #@str = Captcha::convert_to_string(image)
        @str = "not convert to string"
        @@logger.an_event.debug "receive string of captcha"

      rescue Exception => e
        @@logger.an_event.error e.message
        raise Error.new(PAGE_NOT_CREATE, :error => e)

      ensure
        @@logger.an_event.debug "page engine captcha #{self.to_s}"

      end
    end

    def to_s
      super +
          "input : #{@input}\n" +
             "type : #{@type}\n" +
             "submit_button : #{@submit_button}\n" +
             "image : #{@image}\n" +
             "str : #{@str}\n"
    end

  end
end
