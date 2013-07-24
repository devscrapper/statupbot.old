require_relative 'browser'
require_relative '../webdriver'
module Browsers
  class InternetExplorer < Browser
    class InternetExplorerException < StandardError

    end
    #----------------------------------------------------------------------------------------------------------------
    # class methods
    #----------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------
    # instance methods
    #----------------------------------------------------------------------------------------------------------------

    def accept()
      "image/png, image/svg+xml, image/*;q=0.8, */*;q=0.5"
    end

    def user_agent()
     super
    end

    def accept_encoding()
      "gzip, deflate"
    end


  end
end