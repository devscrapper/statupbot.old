module CustomGifRequest
  class Header
    attr :accept,
         :accept_encoding,
         :accept_language,
         :user_agent


    def initialize(visitor)
      @accept = visitor.browser.accept
      @accept_encoding = visitor.browser.accept_encoding
      @user_agent = visitor.browser.user_agent
      @accept_language = visitor.accept_language
    end

    def customize(header)
      header["Accept"] = @accept; header.delete(:accept)
      header["Accept-Encoding"] = @accept_encoding; header.delete(:accept_encoding)
      header["Accept-Language"] = @accept_language; header.delete(:accept_language)
      header["Connection"] = header[:connection]; header.delete(:connection)
      header["Host"] = header[:host]; header.delete(:host)
      if header.has_key?(:referer)
        header["Referer"] = header[:referer]
        header.delete(:referer)
      end
      header["User-Agent"] = @user_agent; header.delete(:user_agent)
      header
    end

    def to_s
        "Accept : #{@accept}\n" + \
        "Accept-Encoding : #{@accept_encoding}\n" + \
        "Accept-Language : #{@accept_language}\n" + \
        "User-Agent : #{@user_agent}"
    end
  end

end