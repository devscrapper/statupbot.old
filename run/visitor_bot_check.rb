#encoding:utf-8
require 'uuid'
require 'yaml'
require 'trollop'
require 'selenium-webdriver'
require 'open-uri'
require_relative '../lib/flow'
require_relative '../lib/keyword'
require_relative '../lib/backlink'
require_relative '../model/browser_type/browser_type'
require_relative '../lib/os'
require_relative '../lib/parameter'

#bot which test visitor_bot with browser_type repository available on device
#
#Usage:
#       visitor_bot_check [options]
#where [options] are:
#       --fqdn, -f <s>:   fqdn (without http) of landing url to browse (default:
#                         www.ergonomie-interface.com)
#  --page-path, -p <s>:   path of landing url to browse (default:
#                         /internet-web-site/formulaire-validation-verification-champs-saisie/)
#     --driver, -d <s>:   type of webdriver (withgui|headless) (default:
#                         withgui)
#            --geo, -g:   use or not geolocation (true|false)
#        --version, -v:   Print version and exit
#           --help, -h:   Show this message
#--------------------------------------------------------------------------------------------------------------------
# LOCAL FUNCTION
#--------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------
# get_referral :
# Recupere les backlinks
# Evalue les backlinks en s'assurant que landing_url est bien présente dans les backlinks
# choisit au hasard un Backlink
#-------------------------------------------------------------------------------------------------------------------
# input :
# l'url recherchee
# le driver pour rechercher les backlinks dans le moteur de recherche (google, bing, yahoo)
# opts : ip / port du proxy si besoin
#-------------------------------------------------------------------------------------------------------------------
def get_referral(landing_url, driver, opts)
  include Backlinks
  backlinks = nil
  backlink = []
  begin

    backlinks = scrape(landing_url, driver)
    p "Backlinks scraped(#{backlinks.size}) => "
    backlinks.each { |bl| p bl }
    backlinks = evaluate(backlinks, landing_url, opts)
    p "Backlinks evaluated(#{backlinks.size}) => "
    if backlinks.empty?
      p "none backlink"
    else
      backlinks.each { |bl| p bl }
    end
  rescue Exception => e
    $stderr << e.message << "\n"
  else
    uri = URI.parse(backlinks.shuffle![0])
    backlink = [uri.hostname, uri.path]

  ensure
    return backlink
  end
end

#--------------------------------------------------------------------------------------------------------------------
# get_title :
# recupere le titre de la page
#-------------------------------------------------------------------------------------------------------------------
# input :
# l'url recherchee
# opts : ip / port du proxy si besoin
#-------------------------------------------------------------------------------------------------------------------
def get_title(url, opts)


  title = ""
  begin
    html = open(url, :proxy => "http://#{opts[:ip]}:#{opts[:port]}")

  rescue Exception => e
    $stderr << e.message << "\n"

  else
    title = Nokogiri::HTML(html).title

  ensure
    return title
  end
end

#--------------------------------------------------------------------------------------------------------------------
# get_keywords :
# recupere les mots clé
# range les mots en 2 groupes :
# ceux qui n'atteignent pas le landing_url => kw_non_valuable
# ceux qui atteignent le landing url => kw_valuable
# identifie un moteur de recherche pour lequel il ya des mots clé qui fonctionnent
#-------------------------------------------------------------------------------------------------------------------
# input :
# l'url recherchee
# le driver pour rechercher les backlinks dans le moteur de recherche (google, bing, yahoo)
# le titre de l'url pour determiner des mots qui atterrissent sur le landing_url en dernier ressort
# opts : ip / port du proxy si besoin
#-------------------------------------------------------------------------------------------------------------------
def get_keyword(landing_url, driver, title, opts)
  words = Keywords::scrape(landing_url, Keywords::KEYWORD_COUNT_MAX, opts)
  p "Keywords => #{words}" unless words.nil?
  p "Keywords => none" if words.nil?
  kw_valuable = []
  kw_non_valuable = []
  kw_valuable, kw_non_valuable = Keywords::evaluate(words, landing_url, driver) unless words.nil?
  kw_valuable = [Keywords::Keyword.new(title, {:google => Keywords::KEYWORD_COUNT_MAX})] if kw_valuable.empty?
  p "Keywords valuable(#{kw_valuable.size})=>"
  kw_valuable.each { |kw| p kw }
  p "Keywords non valuable(#{kw_non_valuable.size})=>"
  kw_non_valuable.each { |kw| p kw }
  #organisation des recherches qui n'atteignent pas l'objectif
  keywords = []
  prng = Random.new(1234)
  kw_non_valuable.map! { |keyword|
    {
        :words => keyword.words,
        :durations => Array.new(prng.rand(2..5), READING_TIME)
    }
  }
  keywords += kw_non_valuable
  #sélection du keyword qui atteind l'objectif
  keyword = kw_valuable.shuffle![0]
  search_engine = keyword.index.to_a.shuffle![0][0]
  keywords << {
      :words => keyword.words,
      :durations => Array.new(keyword.index[search_engine], READING_TIME)
  }
  [search_engine, keywords]
end

#--------------------------------------------------------------------------------------------------------------------
# GLOBAL DECLARATIONS
#--------------------------------------------------------------------------------------------------------------------
TMP = Pathname(File.join(File.dirname(__FILE__), '..', 'tmp')).realpath

#duree de lecture par defaut pour chaque page lue
READING_TIME = 5
# liste des regie publicitaires
advertisings = [:none, :adsense]
# localisation du robot visitor_bot
visitor_bot = File.join(File.dirname(__FILE__), "visitor_bot.rb")

# pattern par defaut decrivant le fichier de visit
PATTERN_VISIT = "---
:start_date_time: 2014-04-25 11:40:37.351568000 +02:00
:website:
  :label: epilation-laser-definitive
  :many_hostname: :true
  :many_account_ga: :no
:visitor:
  :return_visitor: :true
  :browser:
    :flash_version: 11.5 r502
    :java_enabled: 'Yes'
    :screens_colors: 32-bit
    :screen_resolution: 1366x768
:referrer:
  :referral_path:
  :source:
  :medium:
  :duration:
:landing:
  :fqdn:
  :page_path:
:durations:
- 2
- 5
:advert:
  :advertiser:
    :durations:
    - 5
    - 6
    :arounds:
    - :inside_fqdn
    - :outside_fqdn"


#--------------------------------------------------------------------------------------------------------------------
# PARAMETER START
#--------------------------------------------------------------------------------------------------------------------
opts = Trollop::options do
  version "visitor_bot_check 0.2 (c) 2014 Dave Scrapper"
  banner <<-EOS
bot which test visitor_bot with browser_type repository available on device

Usage:
       visitor_bot_check [options]
where [options] are:
  EOS
  opt :fqdn, "fqdn (without http) of landing url to browse", :type => :string, :default => "www.pataweb.com"
  opt :page_path, "path of landing url to browse", :type => :string, :default => "/s-trois-roles-du-seo-p110.html"
  opt :driver, "type of webdriver (withgui|headless)", :type => :string, :default => "withgui"
  opt :geo, "use or not geolocation (true|false)", :type => :boolean, :default => false
end

#--------------------------------------------------------------------------------------------------------------------
# PARAMETER FILE
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
rescue Exception => e
  $stderr << e.message << "\n"
else
  $staging = parameters.environment
  $debugging = parameters.debugging
  query_http_pxy_ip = parameters.query_http_pxy_ip
  query_http_pxy_port = parameters.query_http_pxy_port
  webdriver_pxy_type = parameters.webdriver_pxy_type
  webdriver_pxy_ip = parameters.webdriver_pxy_ip
  webdriver_pxy_port = parameters.webdriver_pxy_port
  webdriver_pxy_user = parameters.webdriver_pxy_user
  webdriver_pxy_pwd = parameters.webdriver_pxy_pwd
  webdriver_headless_path = parameters.webdriver_headless_path
  webdriver_withgui_path = parameters.webdriver_withgui_path
  webdriver_listening_port= parameters.webdriver_listening_port
  ruby_path = parameters.ruby_path
end

#--------------------------------------------------------------------------------------------------------------------
# ANALYSE INPUT PARAM
#--------------------------------------------------------------------------------------------------------------------

case opts[:geo]
  when false
    geolocation = ""
    local_proxy_sahi_ip = nil
    local_proxy_sahi_port = nil

    case opts[:driver]
      when "withgui"
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['network.proxy.type'] = 0
        profile['network.proxy.no_proxies_on'] = ""
        Selenium::WebDriver::Firefox.path = webdriver_withgui_path.join(File::SEPARATOR)
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = 120 # seconds
        driver = Selenium::WebDriver.for :firefox, :profile => profile, :http_client => client
        driver.manage.timeouts.implicit_wait = 3

      when "headless"

        cmd = "#{webdriver_headless_path.join(File::SEPARATOR)} --webdriver=#{webdriver_listening_port} --proxy-type='none' --disk-cache=true --ignore-ssl-errors=true --load-images=false  --webdriver-loglevel='#{$debugging ? 'DEBUG' : 'FALSE' }'"
        raise "phantomjs runtime not found" unless File.exist?(webdriver_headless_path.join(File::SEPARATOR))
        phantomjs_pid = Process.spawn(cmd) #, [:out, :err] => [sahi_proxy_log_file, "w"])
        sleep 5
                                           #mettre un user agent dont on connait le comportement google
        capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:32.0) Gecko/20100101 Firefox/32.0")
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = 120 # seconds
        driver = Selenium::WebDriver.for :phantomjs, :url => "http://localhost:#{webdriver_listening_port}", :desired_capabilities => capabilities, :http_client => client
        driver.manage.timeouts.implicit_wait = 3
    end

  when true
    geolocation = "-r #{webdriver_pxy_type} -o #{webdriver_pxy_ip} -x #{webdriver_pxy_port} -y #{webdriver_pxy_user} -w #{webdriver_pxy_pwd}"
    p "=======> PENSER A DEMARRER SAHI PROXY, si besoin !!!!"
    p "=======> est utilise pour les requetes http (hors driver with gui)"
    local_proxy_sahi_ip = query_http_pxy_ip
    local_proxy_sahi_port = query_http_pxy_port

    case opts[:driver]
      when "withgui"
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['network.proxy.type'] = 1
        profile['network.proxy.http'] = webdriver_pxy_ip
        profile['network.proxy.http_port'] = webdriver_pxy_port
        profile['network.proxy.ssl'] = webdriver_pxy_ip
        profile['network.proxy.ssl_port'] = webdriver_pxy_port

        #profile['network.proxy.https'] = webdriver_pxy_ip
        #profile['network.proxy.https_port'] = webdriver_pxy_port
        Selenium::WebDriver::Firefox.path = webdriver_withgui_path.join(File::SEPARATOR)
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = 120 # seconds
        driver = Selenium::WebDriver.for :firefox, :profile => profile, :http_client => client
        driver.manage.timeouts.implicit_wait = 3
      when "headless" #--debug=true
        cmd = "#{webdriver_headless_path.join(File::SEPARATOR)} --webdriver=#{webdriver_listening_port} --disk-cache=true --ignore-ssl-errors=true --load-images=false  --webdriver-loglevel='#{$debugging ? 'DEBUG' : 'FALSE' }' --proxy=#{webdriver_pxy_ip}:#{webdriver_pxy_port} --proxy-auth=#{webdriver_pxy_user}:#{webdriver_pxy_pwd} --proxy-type=#{webdriver_pxy_type}"
        phantomjs_pid = Process.spawn(cmd) #, [:out, :err] => [sahi_proxy_log_file, "w"])
        sleep 5
                                           #mettre un user agent dont on connait le comportement google
        capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:32.0) Gecko/20100101 Firefox/32.0")
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = 120 # seconds
        driver = Selenium::WebDriver.for :phantomjs, :url => "http://localhost:#{webdriver_listening_port}", :desired_capabilities => capabilities, :http_client => client
        driver.manage.timeouts.implicit_wait = 3

    end
end

#--------------------------------------------------------------------------------------------------------------------
# URL
#--------------------------------------------------------------------------------------------------------------------
url = "http://#{opts[:fqdn]}#{opts[:page_path]}"
p "=======> url : #{url}"

#--------------------------------------------------------------------------------------------------------------------
# GET TITRE
#--------------------------------------------------------------------------------------------------------------------
title = get_title(url, {:ip => local_proxy_sahi_ip, :port => local_proxy_sahi_port})
p "=======> title : #{title}"


#--------------------------------------------------------------------------------------------------------------------
# GET REFERRAL : BACKLINK
#--------------------------------------------------------------------------------------------------------------------
referral_fqdn, referral_path = get_referral(url, driver, {:ip => local_proxy_sahi_ip, :port => local_proxy_sahi_port})
p "=======> referral : #{referral_fqdn} : #{referral_path}" unless referral_fqdn.nil? or referral_path.nil?
p "=======> referral : none" if referral_fqdn.nil? or referral_path.nil?

#--------------------------------------------------------------------------------------------------------------------
# GET KEYWORDS
#--------------------------------------------------------------------------------------------------------------------
search_engine, keywords = get_keyword(url, driver, title, {:ip => local_proxy_sahi_ip, :port => local_proxy_sahi_port})
p "=======> organic : #{search_engine} : "
keywords.each{|k| p k}

#--------------------------------------------------------------------------------------------------------------------
# LISTE DE REFERRER
#--------------------------------------------------------------------------------------------------------------------
referrers = {:direct => {:referral_path => "(not set)", :source => "(direct)", :medium => "(none)", :keyword => "(not set)", :fqdn => opts[:fqdn], :page_path => opts[:page_path], :duration_referral => nil},
             :organic => {:referral_path => "(not set)", :source => search_engine.to_s, :medium => "organic", :keyword => keywords, :fqdn => opts[:fqdn], :page_path => opts[:page_path], :duration_referral => nil}}

unless referral_fqdn.nil? or referral_path.nil?
  referrers.merge!({:referral => {:referral_path => referral_path, :source => referral_fqdn, :medium => "referral", :keyword => "(not set)", :fqdn => opts[:fqdn], :page_path => opts[:page_path], :duration_referral => 20}})
end


#--------------------------------------------------------------------------------------------------------------------
# STOP WEBDRIVER
#--------------------------------------------------------------------------------------------------------------------
driver.quit
Process.kill("KILL", phantomjs_pid) if opts[:driver] == "headless"

#--------------------------------------------------------------------------------------------------------------------
# PUBLISH BROWSER TYPE TO SAHI
#--------------------------------------------------------------------------------------------------------------------
bt = BrowserTypes.new()
p "=======> load browser type repository file : #{BrowserTypes::BROWSER_TYPE}"
bt.publish_to_sahi
p "=======> publish browser type to \\lib\\sahi.in.co"

#--------------------------------------------------------------------------------------------------------------------
# RUN
#--------------------------------------------------------------------------------------------------------------------
results = {"OK" => 0, "ERROR" => 0, "NO_AD" => 0}
bt.browser.each { |browser_name|
  bt.browser_version(browser_name).each { |browser_version|
    referrers.each_value { |referrer|
      advertisings.each { |advertising|
        visit = YAML::load(PATTERN_VISIT)

        visit[:id_visit] = UUID.generate
        visit[:visitor][:id] = UUID.generate
        visit[:visitor][:browser][:name] = browser_name
        visit[:visitor][:browser][:version] = browser_version
        visit[:visitor][:browser][:operating_system] = OS.name
        visit[:visitor][:browser][:operating_system_version] = OS.version
        visit[:referrer][:referral_path] = referrer[:referral_path]
        visit[:referrer][:source] =referrer[:source]
        visit[:referrer][:medium] = referrer[:medium]
        visit[:referrer][:keyword] = referrer[:keyword]
        visit[:referrer][:duration] = referrer[:duration_referral]
        visit[:landing][:fqdn] = referrer[:fqdn]
        visit[:landing][:page_path] = referrer[:page_path]
        visit[:advert][:advertising] = advertising

        file_visit = Flow.new(TMP, "#{browser_name}_#{browser_version}", "#{referrer[:medium]}_#{advertising}", Date.today, 1, '.yml')
        p "=======> generate file visit : #{file_visit.basename}"
        file_visit.write(visit.to_yaml)
        file_visit.close

        proxy_system = bt.proxy_system?(browser_name, browser_version) == true ? "yes" : "no"
        listening_port_proxy = bt.listening_port_proxy(browser_name, browser_version)[0]


        begin
          cmd = "#{ruby_path.join(File::SEPARATOR)} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)  #{visitor_bot} -v #{file_visit.absolute_path} -t #{listening_port_proxy} -p #{proxy_system} #{geolocation}"
          p "=======> start visitor_bot : #{cmd}"

          pid = Process.spawn(cmd)

          pid, status = Process.wait2(pid, 0)

        rescue Exception => e
          $stderr << e.message

        else
          case status.exitstatus
            when 0
              p "visitor_bot finish normaly"
              results.merge!({file_visit.basename => "OK"})
              results["OK"] += 1
            when 1
              $stderr << "an error occured" << "\n"
              results.merge!({file_visit.basename => "ERROR"})
              results["ERROR"] += 1
            when 2
              $stderr << "no ad" << "\n"
              results.merge!({file_visit.basename => "NO_AD"})
              results["NO_AD"] += 1
          end

        ensure
        end
      }
    }
  }
}

#--------------------------------------------------------------------------------------------------------------------
# DISPLAY RESULTS
#--------------------------------------------------------------------------------------------------------------------
p "-------------------------------------------------------------------------------------------------------------------"
p "| results : OK => #{results["OK"]}, ERROR => #{results["ERROR"]}, NO_AD => #{results["NO_AD"]}                                                                                                         |"
p "-------------------------------------------------------------------------------------------------------------------"
results.each_pair { |visit, result|
  p "#{visit} => #{result}"
}
p "-------------------------------------------------------------------------------------------------------------------"