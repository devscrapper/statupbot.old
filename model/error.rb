module Errors

  class Error < StandardError
    attr_reader :code, :origin_code, :history

    def initialize(code, error=nil)

      @code = code
      if  error.is_a?(Error) and !error.nil?
        @origin_code = error.origin_code ? error.origin_code : error.code
        @history = error.history
      end
      @history = @history.nil? ? [code] : @history << code
    end

    def to_s
      "exception #{self.class} code #{@code}, origin_code #{@origin_code}, history #{@history}"
    end
  end
end