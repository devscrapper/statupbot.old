module Errors
  #-----------------------------------------------------------------------------------------------------------------
  # error range
  #-----------------------------------------------------------------------------------------------------------------
  # proxy.rb          | 100 - ...
  # driver.rb         | 200 - ...
  # browser.rb        | 300 - ...
  # link.rb           | 400 - ...
  # page.rb           | 500 - ...
  # visitor.rb        | 600 - ...
  # visit.rb          | 700 - ...
  # referrer.rb       | 800 - ...
  # engine_search.rb  | 900 - ...
  # visitor_factory   | 1000 - ...
  # browser_type.rb   | 1100 - ...
  #-------------------------------------------------------------------------------------------------------------------
  class Error < StandardError
    attr_accessor :code, :origin_code, :history

    def initialize(code, error=nil)

      @code = code
      if  error.is_a?(Error) and !error.nil?
        @origin_code = error.origin_code ? error.origin_code : error.code
        @history = Array.new(error.history)
      end
      @history = @history.nil? ? [code] : @history << code
    end

    def to_s
      "exception #{self.class} code #{@code}, origin_code #{@origin_code}, history #{@history}"
    end

    # convertit une sous class de Error en class Error pour le monitoring afin d'eviter d'envoyer une sous class au monitor
    def to_super
      er =  Error.new(code)
      er.origin_code = @origin_code
      er.history = @history
      return er
    end
  end
end