require 'net/http'
require 'nokogiri'
require 'uri'
require 'ruby-progressbar'
require 'thread'

module Backlinks

  INDEX_MAX = 5
  COUNT_THREAD = 10

  def scrape(landing_url, driver)
    backlinks = []
    #
    [[:yahoo, 'https://fr.search.yahoo.com/', 'p', 'h3 > a.yschttl.spt', 'a#pg-next'],
     [:google, 'https://www.google.fr/', 'q', 'h3.r > a', 'a#pnnext.pn'],
     [:bing, 'http://www.bing.com/', 'q', 'h2 > a', 'a.sb_pagN']].each { |search_engine, search_engine_url, input_css, link_css, next_css|
      backlinks += scrape_backlinks(search_engine, driver, landing_url, search_engine_url, input_css, link_css, next_css, INDEX_MAX)
    }


    backlinks
  end

  # evalue les backlink en s'assurant que le landing_url est présent dans la page
  def evaluate(backlinks, landing_url, proxy=[])

    begin
      p = ProgressBar.create(:title => "Evaluating backlinks", :length => 100, :starting_at => 0, :total => backlinks.size, :format => '%t, %c/%C, %a|%w|')
      work_q = Queue.new
      res_q = Queue.new
      backlinks.each { |x| work_q.push x }

      workers = (0...COUNT_THREAD).map do
        Thread.new do
          begin
            while bl = work_q.pop(true)
              evaluate_backlink(bl, landing_url, proxy) ? res_q.push(bl) : nil
              p.increment
            end
          rescue ThreadError
          end
        end
      end
      workers.map(&:join)
      backlinks = []
      res_q.size.times {
        backlink = res_q.pop()
        backlinks << backlink
      } unless res_q.size == 0
    rescue Exception => e
      $stderr << e.message << "\n"
    else

    ensure
      return backlinks
    end

  end

  private

  def evaluate_backlink(backlink, landing_link, proxy=[])
    uri = URI.parse(backlink)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.56.5 (KHTML, like Gecko) Version/5.1.6 Safari/534.56.5'
    links = []

    begin
      res = Net::HTTP.start(uri.hostname, uri.port, proxy[:ip], proxy[:port], proxy[:user], proxy[:pwd], :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end

    rescue Exception => e
      $stderr << e.message << "\n"

    else
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          Nokogiri::HTML(res.body).xpath("//a").each { |h| links << h.attributes["href"].value if h.attributes["href"] }

        else
          $stderr << res.message << "\n"

      end

    ensure
      return links.include?(landing_link)

    end
  end


  def find_links(driver, link_css)
    links = []
    begin

      links = driver.find_elements(:css, link_css).map { |e|
        begin
          #on elimine les backlinks https
          href = e.attribute('href')
          raise if URI.parse(href).scheme == "https"
        rescue Exception => e
        else
          href
        ensure
        end
      }
      sleep 1
    rescue Exception => e
      raise "not found backlinks : #{e.message}"
    else
      links.compact! unless links.empty?
    ensure
      return links
    end
  end

  def find_next(driver, next_css)
    nxt = nil
    begin

      nxt = driver.find_element(:css, next_css)
      sleep 1
    rescue Exception => e
      raise "not found next link : #{e.message}"
    else
    ensure
      return nxt
    end
  end

  def navigate_to(driver, url)
    count_retry = 3
    i = 1
    begin

      driver.navigate.to url
      sleep 1
    rescue Timeout::Error => e
      i+=1
      retry if i < count_retry
      raise "not reach url : #{url}"

    rescue Exception => e
      raise "not reach url : #{url}"

    else
      crt_u = driver.current_url
      raise "reach bad url : #{crt_u}" if crt_u != url
    ensure
    end
  end

  def search(driver, input_css, str)
    begin
      element = driver.find_element(:name, input_css)
      element.clear
      element.send_keys str
      element.submit
      sleep 1
    rescue Exception => e
      raise "not search : #{str}, #{e.message}"
    else
    ensure
    end
  end

  def scrape_backlinks(search_engine, driver, landing_url, search_engine_url, input_css, link_css, next_css, max_count_page=3)
    backlinks = []
    begin
      navigate_to(driver, search_engine_url)

      search(driver, input_css, "link: #{landing_url}")

      p = ProgressBar.create(:title => "Scraping backlinks on #{search_engine}", :length => 100, :starting_at => 0, :total => max_count_page, :format => '%t, %c/%C, %a|%w|')

      max_count_page.times { |index_page|

        backlinks += find_links(driver, link_css)

        nxt = find_next(driver, next_css)

        if index_page < max_count_page - 1 and !nxt.nil?
          nxt.click
          p.increment
        else
          break
        end
      }
    rescue Exception => e
      $stderr << e.message << "\n"
    else

    ensure
      return backlinks.uniq
    end
  end


  module_function :scrape
  module_function :evaluate
  module_function :evaluate_backlink


end