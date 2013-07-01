require 'selenium-webdriver'

class Webdriver
  class WebdriverException < StandardError
  end
  attr :uri,
       :port,
       :driver,
       :capabilities
  attr_accessor :pid

  def initialize(host, port, user_agent, pid)
    begin
      @port = port
      @uri= "http://#{host}:#{@port}"
      @driver = nil
      @pid = pid
      @capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => user_agent)
    rescue Exception => e
      raise WebdriverException, "cannot create webdriver : #{e.message}"
    end
  end

  def open
    @driver = Selenium::WebDriver.for(:phantomjs, :url => @uri, :desired_capabilities => @capabilities)
  end

  def go(url)
    begin
      @driver.navigate.to url
    rescue Exception => e
      raise WebdriverException, e.message
    end
  end

  def close()
    #TODO controler si il faut supprimer les coockies manuellement ou pris en compte par la fermeture du browser
    begin
      @driver.close
    rescue Exception => e
      raise WebdriverException, e.message
    end
  end

  def display()
    p "+----------------------------------------------"
    p "| WEBDRIVER                                   |"
    p "+---------------------------------------------+"
    p "| uri : #{@uri}"
    p "| port : #{@port}"
    p "| driver : #{@driver.inspect}"
    p "| pid : #{@pid}"
    p "| capabilities : #{@capabilities.inspect}"
    p "+----------------------------------------------"
    p "| WEBDRIVER                                   |"
    p "+---------------------------------------------+"
  end
end