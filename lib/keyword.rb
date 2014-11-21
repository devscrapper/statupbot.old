require 'net/http'
require 'nokogiri'
require 'uri'
require 'ruby-progressbar'


module Keywords

  KEYWORD_COUNT_MAX = 10

  class Keyword
    INDEX_MAX = 5

    attr_reader :words, #array of word
                :index # hash of index page by search engine

    def initialize(keywords, index={})
      @words = keywords.strip
      @index = index
    end

    def evaluate(url, driver)
      [[:yahoo, 'https://fr.yahoo.com/', 'p', 'h3 > a.yschttl.spt', 'a#pg-next'],
       [:google, 'https://www.google.fr/', 'q', 'h3.r > a', 'a#pnnext.pn'],
       [:bing, 'http://www.bing.com/', 'q', 'h2 > a', 'a.sb_pagN']].each { |search_engine, search_engine_url, input_css, link_css, next_css|
        found, index_page = search_keywords(search_engine, driver, url, search_engine_url, input_css, link_css, next_css, INDEX_MAX)
        @index.merge!(found ? {search_engine => index_page} : {})
      }
    end

    def to_s
      "#{@words};#{@index}"
    end


    private
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

      rescue Exception => e
        raise "not found backlinks : #{e.message}"
      else
        links.compact! unless links.empty?
      ensure
        return links.uniq
      end
    end

    def find_next(driver, next_css)
      nxt = nil
      begin

        nxt = driver.find_element(:css, next_css)

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
      rescue Exception => e
        raise "not search : #{str}, #{e.message}"
      else
      ensure
      end
    end

    def search_keywords(search_engine, driver, url, search_engine_url, input_css, link_css, next_css, max_count_page=3)
      found = false
      i = 0

      begin
        navigate_to(driver, search_engine_url)

        search(driver, input_css, @words)

        p = ProgressBar.create(:title => "Evaluating keywords on #{search_engine}", :length => 100, :starting_at => 0, :total => max_count_page, :format => '%t, %c/%C, %a|%w|')

        max_count_page.times { |index_page|

          found  = find_links(driver, link_css).include?(url)

          nxt = find_next(driver, next_css)

          if !found and index_page < max_count_page - 1 and !nxt.nil?
            nxt.click
            p.increment
          else
            i = index_page + 1
            break
          end
        }
      rescue Exception => e
        $stderr << e.message << "\n"
      else

      ensure
        return [found, i]
      end
    end

    def search_keywords_old(driver, url, search_engine_url, input_css, link_css, next_css, max_count_page=3)
      driver.navigate.to search_engine_url
      element = driver.find_element(:name, input_css)
      element.clear
      element.send_keys @words
      element.submit
      sleep 1
      i = 1
      found = false
      begin
        #p driver.current_url
        raise "not found landing url" unless driver.find_elements(:css, link_css).map { |e|
          # p e.attribute('href')
          e.attribute('href')
        }.include?(url)


      rescue Exception => e

        case e.message
          when "not found landing url"
            driver.find_element(:css, next_css).click
            sleep 1
            if i < max_count_page
              i+=1
              retry
            end
          else
            $stderr << e.message
        end
      else
        found = true
      ensure
        return [found, i]
      end
    end
  end


  def scrape(url, keyword_count, proxy=[])
    scraper_from_tagcrowd(url, keyword_count, proxy)
  end

  # evalue les mots et les répartit entre ceux qui trouvent l'url et ceux qui ne la trouvent pas.
  def evaluate(words, url, driver)
    kw_valuable = []
    kw_fake = []
    begin
      p = ProgressBar.create(:title => "Evaluating keywords", :length => 100, :starting_at => 0, :total => words.size, :format => '%t, %c/%C, %a|%w|')
      keywords = ""
      words.each { |word|
        keywords += "#{word} "
        k = Keyword.new(keywords)
        k.evaluate(url, driver)
        kw_valuable << k unless k.index.empty?
        kw_fake << k if k.index.empty?
        if k.index[:google] and k.index[:yahoo] and k.index[:bing]
          p.finish
          break
        end
        p.increment
      }
    rescue Exception => e
      $stderr << e.message << "\n"
    else

    ensure
      return kw_valuable, kw_fake
    end

  end

  private
  def scraper_from_tagcrowd(url, keyword_count, proxy=[])
    uri = URI.parse('http://tagcrowd.com/')
    req = Net::HTTP::Post.new(uri.path)
    req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.56.5 (KHTML, like Gecko) Version/5.1.6 Safari/534.56.5'
    req.set_form_data('source' => 'url_file',
                      'url_file' => url.to_s,
                      'language' => "French",
                      'topTags' => keyword_count.to_s,
                      "minFreq" => "2",
                      "showFreq" => "yes",
                      "lettercase" => "lowercase")

    keywords = []

    begin

      res = Net::HTTP.start(uri.hostname, uri.port, proxy[:ip], proxy[:port], proxy[:user], proxy[:pwd], :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end

    rescue Exception => e

      $stderr << e.message

    else

      case res

        when Net::HTTPSuccess, Net::HTTPRedirection
          keywords = Nokogiri::HTML(res.body).xpath("//a[@href=\"#tagcloud\"]").collect { |h|
            k = /(?<keyword>\w+).+\((?<frequency>\d+)\)/.match(h.children.text)
            [k[:keyword], k[:frequency].to_i]
          }
          # ordonner les keywords en fonction de leur frequence
          keywords.sort! { |a, b| b[1] <=> a[1] }.collect! { |k| k[0] }

          # calcule des chaines de mot clé de 1 mot à n mot
          keywords.each_index { |i|
            keywords[i] = keywords[i] if i == 0
            keywords[i] = "#{keywords[i - 1].words} #{keywords[i]}" if i > 0 }

          # on conserve la chaine de mot la plus longue
          keywords = keywords.pop
        else
          $stderr << res.message
      end

    ensure
      return keywords
    end


  end


  module_function :scrape
  module_function :evaluate
  module_function :scraper_from_tagcrowd


end