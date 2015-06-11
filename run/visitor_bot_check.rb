#encoding:utf-8
require 'uuid'
require 'yaml'
require 'trollop'
require 'eventmachine'
require_relative '../model/browser_type/browser_type'
require_relative '../lib/os'
require_relative '../lib/parameter'

#bot which test visitor_bot with browser_type repository available on device
#
#Usage:
#       visitor_bot_check [options]
#where [options] are:
#            --geo, -g:   use or not geolocation (true|false)
#        --version, -v:   Print version and exit
#           --help, -h:   Show this message
#--------------------------------------------------------------------------------------------------------------------
# LOCAL FUNCTION
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# GLOBAL DECLARATIONS
#--------------------------------------------------------------------------------------------------------------------
INPUT = Pathname(File.join(File.dirname(__FILE__), '..', 'input')).realpath


# localisation du robot visitor_bot
VISITOR_BOT = File.join(File.dirname(__FILE__), "visitor_bot.rb")

#--------------------------------------------------------------------------------------------------------------------
# PARAMETER START
#--------------------------------------------------------------------------------------------------------------------
opts = Trollop::options do
  version "visitor_bot_check 0.3 (c) 2015 Dave Scrapper"
  banner <<-EOS
bot which test visitor_bot with browser_type repository available on device

Usage:
       visitor_bot_check [options]
where [options] are:
  EOS
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
  ruby_path = parameters.ruby_path
end

#--------------------------------------------------------------------------------------------------------------------
# ANALYSE INPUT PARAM
#--------------------------------------------------------------------------------------------------------------------

case opts[:geo]
  when false
    geolocation = ""
  when true
    geolocation = "-r #{webdriver_pxy_type} -o #{webdriver_pxy_ip} -x #{webdriver_pxy_port} -y #{webdriver_pxy_user} -w #{webdriver_pxy_pwd}"
end

#--------------------------------------------------------------------------------------------------------------------
# OBJECT Visit
#--------------------------------------------------------------------------------------------------------------------
class Visit
  INPUT = Pathname(File.join(File.dirname(__FILE__), "..", "input")).realpath

  attr_reader :types, :referrers, :adverts, :engines
  attr_accessor :type, :referrer, :advert, :browser, :website, :engine
  #generer automatiquement
  attr :id_visit, :start_date_time, :durations

  def self.[](index)
    Dir[File.join(INPUT, "visit_*.yml")][index.to_i]
  end

  def self.display
    i = -1
    Dir[File.join(INPUT, "visit_*.yml")].each { |v| p "#{i+=1} - #{v}" }
  end

  def self.list
    Dir[File.join(INPUT, "visit_*.yml")]
  end

  def initialize
    @types = [:rank, :traffic, :advert]
    @referrers = [:none, :referral, :organic]
    @adverts = [:adsense, :none]
    @engines = [:google, :bing, :yahoo]
    # valeur par defaut
    @type = :traffic
    @referrer = :none
    @advert = :none
    @engine = :google
    @browser = ""
    @website = ""
  end


end

#--------------------------------------------------------------------------------------------------------------------
# PUBLISH BROWSER TYPE TO SAHI
#--------------------------------------------------------------------------------------------------------------------
bt = BrowserTypes.new()
p "=======> load browser type repository file : #{BrowserTypes::BROWSER_TYPE}"
bt.publish_to_sahi
p "=======> publish browser type to \\lib\\sahi.in.co"

#--------------------------------------------------------------------------------------------------------------------
# MENU MANAGEMENT
#--------------------------------------------------------------------------------------------------------------------
module MyKeyboardHandler
  attr :bt, :param, :geolocation
  include EM::Protocols::LineText2
  @@results = {"OK" => 0, "ERROR" => 0, "NO_AD" => 0, "NO_LANDING" => 0}

  def initialize (bt, param, geolocation)
    @bt = bt
    @param = param
    @geolocation = geolocation
    display
  end

  def execute(visit_idx)
    filename = Visit[visit_idx]
    visit = YAML::load(File.open(filename), "r:UTF-8")
    proxy_system = @bt.proxy_system?(visit[:visitor][:browser][:name],
                                     visit[:visitor][:browser][:version]) == true ? "yes" : "no"
    listening_port_proxy = @bt.listening_port_proxy(visit[:visitor][:browser][:name], visit[:visitor][:browser][:version])[0]


    begin
      cmd = "#{@param.ruby_path.join(File::SEPARATOR)} -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift) \
      #{VISITOR_BOT} -v #{filename} -t #{listening_port_proxy} -p #{proxy_system} #{@geolocation}"
      p "=======> start visitor_bot : #{cmd}"

      pid = Process.spawn(cmd)

      pid, status = Process.wait2(pid, 0)

    rescue Exception => e
      $stderr << e.message

    else
      case status.exitstatus
        when 0
          p "visitor_bot finish normaly"
          @@results.merge!({filename => "OK"})
          @@results["OK"] += 1
        when 1
          $stderr << "an error occured" << "\n"
          @@results.merge!({filename => "ERROR"})
          @@results["ERROR"] += 1
        when 2
          $stderr << "no ad" << "\n"
          @@results.merge!({filename => "NO_AD"})
          @@results["NO_AD"] += 1
        when 3
          $stderr << "no landing" << "\n"
          @@results.merge!({filename => "NO_LANDING"})
          @@results["NO_LANDING"] += 1
      end

    ensure
    end
  end

  def execute_all
      Visit.list.each_index  { |i| execute(i)}
  end

  def display
    begin
      p " Visits list : -----------------------------------------------------------------------------------------------"
      Visit.display
      p " Commands : --------------------------------------------------------------------------------------------------"
      p " [e]xecute visit from list : #{Array.new(Visit.list.size) { |i| i }.join("|")}|all"
      p " [r]eload visits"
      p "x -> exit"
      p "--------------------------------------------------------------------------------------------------------------"
      p "--------------------------------------------------------------------------------------------------------------"
      p "| results : OK => #{@@results["OK"]}, ERROR => #{@@results["ERROR"]}, NO_AD => #{@@results["NO_AD"]}                                                                                                         |"
      p "--------------------------------------------------------------------------------------------------------------"
      @@results.each_pair { |visit, result| p "#{visit} => #{result}" }
    rescue Exception
    end
  end

  def receive_line data
    /(?<cmd>[a,b,c,e,f,g,i,k,l,n,p,r,s,t,v,w,x])[[:blank:]]*(?<value>([[:word:]]|[[:punct:]]|[[:blank:]])*)/u =~ data.force_encoding("utf-8")
    p cmd
    p value
    case cmd
      when "e"
        if value == "all"
          execute_all
        else
          if value.to_i >= 0 and value.to_i <= Visit.list.size - 1
          execute(value)
          else
            $stderr << "id visit #{value} unknown\n"
            end
        end

      when "r"
        display
      when "x"
        EM.stop
      else
        p "cmd #{cmd} unknown"
    end
    display
  end
end

EM.run {
  EM.open_keyboard MyKeyboardHandler, bt, parameters, geolocation
}
