module Errors

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