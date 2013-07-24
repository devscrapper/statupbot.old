require 'selenium-webdriver'

class Webdriver
  class WebdriverException < StandardError
  end
  attr        :driver,
       :profile


  def to_s
    "driver : #{@driver.to_s}\n" + \
    "capabilities : #{@profile.to_s}"

  end

  def initialize(user_agent)
    begin
      @driver = nil
      #@profile = Selenium::WebDriver::Firefox::Profile.from_name "default"
      @profile = Selenium::WebDriver::Firefox::Profile.new
      @profile['general.useragent.override'] = user_agent
      @profile.proxy = Selenium::WebDriver::Proxy.new(:http => "localhost:9250")
    rescue Exception => e
      raise WebdriverException, "cannot create webdriver : #{e.message}"
    end
  end

  def open
    @driver =  Selenium::WebDriver.for :firefox, :profile => @profile
  end

  def go(url)
    begin
      @driver.navigate.to url
    rescue Exception => e
      raise WebdriverException, e.message
    end
  end

  def close()
    begin
      @driver.manage.delete_all_cookies()
      @driver.close
    rescue Exception => e
      raise WebdriverException, e.message
    end
  end

  def display()
    p "+----------------------------------------------"
    p "| WEBDRIVER                                   |"
    p "+---------------------------------------------+"
    p "| driver : #{@driver.inspect}"
    p "| profile : #{@profile.inspect}"
    p "+----------------------------------------------"
    p "| WEBDRIVER                                   |"
    p "+---------------------------------------------+"
  end
end