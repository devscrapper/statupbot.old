require 'yaml'
require 'trollop'
require 'uuid'
require 'uri'
require 'rubygems'
require 'eventmachine'
require_relative '../model/browser_type/browser_type'
require_relative '../lib/os'
require_relative '../lib/parameter'


#--------------------------------------------------------------------------------------------------------------------
# PARAMETER START
#--------------------------------------------------------------------------------------------------------------------
opts = Trollop::options do
  version "visit_generator 0.1 (c) 2015 Dave Scrapper"
  banner <<-EOS
functionnalities :
1-generate visit file

Usage:
       visitor_check

  EOS
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
end

#--------------------------------------------------------------------------------------------------------------------
# OBJECT Browser
#--------------------------------------------------------------------------------------------------------------------
class Browser
  SCREEN_RESOLUTION = "1366x768"

  attr :name, :version, :operating_system, :operating_system_version, :screen_resolution, :engine_search

  def self.[](i, engine_search)
    bt = BrowserTypes.list[i.to_i].split("-")
    {:name => bt[0].strip,
     :version => bt[1].strip,
     :operating_system => OS.name,
     :operating_system_version => OS.version,
     :screen_resolution => SCREEN_RESOLUTION,
     :engine_search => engine_search
    }
  end

  def self.list
    i = -1
    BrowserTypes.list.each { |l| "#{i+=1} - #{l}" }
  end

  def self.display
    i = -1
    BrowserTypes.list.each { |l| p "#{i+=1} - #{l}" }
  end

  def initialize
    #valeurs par defaut
    @screen_resolution = "1366x768"
  end


end

#--------------------------------------------------------------------------------------------------------------------
# OBJECT Website
#--------------------------------------------------------------------------------------------------------------------
class Website
  TMP = Pathname(File.join(File.dirname(__FILE__), "..", "tmp")).realpath
  WEBSITES = "websites.yml"
  attr_accessor :label, :many_hostname, :many_account_ga, :scheme, :fqdn, :path, :text, :index, :keywords, :referral_text, :referral_kw
  attr_writer :referral_uri
  @@websites = nil

  def self.[](i)
    @@websites[i.to_i]
  end

  def self.display

    i = -1
    @@websites.each { |l| p "#{i+=1} - #{l.to_yaml}" }
  end

  def self.list

    i = -1
    @@websites.each { |l| "#{i+=1} - #{l}" }
  end

  def initialize
    #valeurs par defaut
    @many_hostname = :true
    @many_account_ga = :no
    @scheme = :http
    @@websites = []
    YAML::load(File.open(File.join(TMP, WEBSITES)), "r:UTF-8").each { |w| @@websites << w } if File.exist?(File.join(TMP, WEBSITES))
    @referral_uri = nil
    @referral_text = ""
    @referral_kw = ""
  end

  def referral_uri
     @referral_uri.nil? ? "" : @referral_uri
  end

  def save
    @@websites << self unless @@websites.include?(self)
    File.open(File.join(TMP, WEBSITES), "w:UTF-8") { |f| f.write @@websites.to_yaml }
  end

  def website
    {:label => @label,
     :many_hostname => @many_hostname,
     :many_account_ga => @many_account_ga}
  end

  def landing
    {:scheme => @scheme,
     :fqdn => @fqdn,
     :path => @path,
     :text => @text}
  end
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

  def self.display
    i = -1
    Dir[File.join(INPUT, "visit_*.yml")].each { |v| p "#{i+=1} - #{v}" }
  end

  def self.list

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

  def generate
    $stderr << "website not define\n" if @website.empty?
    $stderr << "browser not define\n" if @browser.empty?
    if !@browser.empty? and !@website.empty?
      visit_filename = "visit_#{@type}_#{@referrer}_#{@advert}_#{@engine}_#{Browser[@browser.to_i, @engine][:name].strip}_#{Browser[@browser.to_i, @engine][:version].strip}.yml"
      visit_filename.gsub!(" ", "_")
      visit = {:id_visit => UUID.generate,
               :start_date_time => Time.now,
               :type => @type,
               :website => Website[@website.to_i].website,
               :landing => Website[@website.to_i].landing,
               :visitor => {
                   :id => UUID.generate,
                   :browser => Browser[@browser.to_i, @engine]
               },
               :referrer => {:medium => @referrer},
               :advert => {:advertising => @advert},
               :durations => Array.new(3).fill(5)
      }
      case @type
        when :traffic, :advert
          case @referrer
            when :none
            when :referral
              visit[:referrer].merge!({:random_search => {:min => 5, :max => 10},
                                       :random_surf => {:min => 5, :max => 10},
                                       :keyword => Website[@website.to_i].referral_kw,
                                       :durations => Array.new(Website[@website.to_i].index.to_i).fill(2),
                                       :referral_path => Website[@website.to_i].referral_uri.path,
                                       :source => Website[@website.to_i].referral_uri.hostname,
                                       :title => Website[@website.to_i].referral_text.strip,
                                       :duration => 5})
            when :organic
              visit[:referrer].merge!({:random_search => {:min => 5, :max => 10},
                                       :random_surf => {:min => 5, :max => 10},
                                       :keyword => Website[@website.to_i].keywords,
                                       :durations => Array.new(Website[@website.to_i].index.to_i).fill(2)})
          end
          if @advert != :none
            visit[:advert].merge!({:advertiser => {:durations => Array.new(3).fill(2),
                                                   :arounds => Array.new(3).fill(:inside_fqdn)}})
          end
        when :rank
          visit[:referrer].merge!({:random_search => {:min => 5, :max => 10},
                                   :random_surf => {:min => 5, :max => 10},
                                   :keyword => Website[@website.to_i].keywords,
                                   :durations => Array.new(Website[@website.to_i].index.to_i).fill(2)})

      end
      File.open(File.join(INPUT, visit_filename), "w:UTF-8") { |f| f.write(visit.to_yaml) }
    else

    end
  end


end

#--------------------------------------------------------------------------------------------------------------------
# MENU MANAGEMENT
#--------------------------------------------------------------------------------------------------------------------
module MyKeyboardHandler

  include EM::Protocols::LineText2
  attr :visit, :website, :browser

  def initialize
    @visit = Visit.new
    @website = Website.new
    @browser = Browser.new

    display
  end

  def receive_line data

    #/(?<cmd>[a,b,c,e,f,g,i,k,l,n,p,q,r,s,t,v,w,x])[[:blank:]]+(?<value>([[:word:]]|[[:punct:]]|[[:blank:]])*)[[:blank:]]+(\|(?<value2>([[:word:]]|[[:punct:]]|[[:blank:]])*))?[[:blank:]]+(\|(?<value3>([[:word:]]|[[:punct:]]|[[:blank:]])*)?)/u =~ data.force_encoding("utf-8")
    /(?<cmd>[a,b,c,e,f,g,i,k,l,n,p,q,r,s,t,v,w,x])[[:blank:]]*(?<value>([[:word:]]|[[:punct:]]|[[:blank:]]|\|)*)/u =~ data.force_encoding("utf-8")
    p "cmd #{cmd}"
    p "value <#{value}>"
    cmd = cmd.strip
    value = value.strip
    p "cmd <#{cmd}>"
    p "value <#{value}>"

    case cmd
      when "a"
        if @visit.adverts.include?(value.to_sym)
          @visit.advert = value.to_sym
          if @visit.advert == :none
            @visit.type = :traffic
          else
            @visit.type = :advert
          end
        else
          $stderr << "value #{value} for advert unacceptable"
        end
      when "b"
        if value.to_i < Browser.list.size
          @visit.browser = value
        else
          $stderr << "value #{value} for browser unacceptable"
        end
      when "c"
      when "e"
        @website.text = value
      when "f"
        begin

          @website.referral_uri = URI.parse(value.split("|")[0].strip)
          @website.referral_text = value.split("|")[1].strip
            @website.referral_kw = value.split("|")[2].strip
        rescue Exception => e
          $stderr << e.message
        end
      when "g"
        @visit.generate
      when "i"
        @website.index = value
      when "k"
        @website.keywords = value
      when "l"
        @website.label = value
      when "n"
        if @visit.engines.include?(value.to_sym)
          @visit.engine = value.to_sym
        else
          $stderr << "value #{value} for engine unacceptable"
        end
      when "p"
        @website.path = value
      when "q"
        @website.fqdn = value
      when "r"
        if @visit.referrers.include?(value.to_sym)
          @visit.referrer = value.to_sym
        else
          $stderr << "value #{value} for referrer unacceptable"
        end
      when "s"
        @website.scheme = value
      when "t"
        if @visit.types.include?(value.to_sym)
          @visit.type = value.to_sym
          if @visit.type == :rank
            @visit.engine = :google
            @visit.referrer = :organic
            @visit.advert = :none
          elsif @visit.type == :advert
            @visit.advert = :adsense
          else
            @visit.advert = :none
          end
        else
          $stderr << "value #{value} for type unacceptable"
        end
      when "v"
        @website.save
      when "w"
        if value.to_i < Website.list.size
          @visit.website = value
          @website.label = Website[@visit.website.to_i].label
          @website.scheme = Website[@visit.website.to_i].scheme
          @website.fqdn = Website[@visit.website.to_i].fqdn
          @website.path = Website[@visit.website.to_i].path
          @website.text = Website[@visit.website.to_i].text
          @website.index = Website[@visit.website.to_i].index
          @website.keywords = Website[@visit.website.to_i].keywords
          @website.referral_uri = Website[@visit.website.to_i].referral_uri unless  Website[@visit.website.to_i].referral_uri.nil?
          @website.referral_text = Website[@visit.website.to_i].referral_text  unless  Website[@visit.website.to_i].referral_text.nil?
          @website.referral_kw = Website[@visit.website.to_i].referral_kw  unless  Website[@visit.website.to_i].referral_kw.nil?
        else
          $stderr << "value #{value} for website unacceptable"
        end
      when "x"
        EM.stop
      else
        p "cmd #{cmd} unknown"
    end
    display
  end

  def display
    begin
      p " Website properties : ----------------------------------------------------------------------------------------"
      p " [l]abel     : <label>       => crt value : #{@website.label}"
      p " [s]cheme    : http|https    => crt value : #{@website.scheme}"
      p " f[q]dn      : <fqdn>        => crt value : #{@website.fqdn}"
      p " [p]ath      : <path>        => crt value : #{@website.path}"
      p " t[e]xte     : <title>       => crt value : #{@website.text}"
      p " [i]ndex     : <index>       => crt value : #{@website.index}"
      p " [k]eywords  : <keywords>    => crt value : #{@website.keywords}"
      p " re[f]erral  : <uri>|<title> => crt value : #{@website.referral_uri.to_s}  | #{@website.referral_text.strip} "
      p "                                                                           | #{@website.referral_kw.strip}"
      p " Website list : ----------------------------------------------------------------------------------------------"
      Website.display
      p " Browser list : ----------------------------------------------------------------------------------------------"
      Browser.display
      p " Visit properties : ------------------------------------------------------------------------------------------"
      p " [t]ype      : #{@visit.types.join("|")} => crt value : #{@visit.type}"
      p " [r]eferrer  : #{@visit.referrers.join("|")} => crt value : #{@visit.referrer}"
      p " [a]dvert    : #{@visit.adverts.join("|")} => crt value : #{@visit.advert}"
      p " [b]rowser   : #{Array.new(Browser.list.size) { |i| i }.join("|")} => crt value : #{@visit.browser}"
      p " [w]ebsite   : #{Array.new(Website.list.size) { |i| i }.join("|")} => crt value : #{@visit.website}"
      p " e[n]gine    : #{@visit.engines.join("|")} => crt value : #{@visit.engine}"
      p " Visits list : -----------------------------------------------------------------------------------------------"
      Visit.display
      p " Commands : --------------------------------------------------------------------------------------------------"
      p "sa{v]e website properties to list."
      p "[g]enerate visit with current website properties"
      p "x -> exit"
      p "--------------------------------------------------------------------------------------------------------------"
    rescue Exception => e
    else
    end
  end
end

EM.run {
  EM.open_keyboard MyKeyboardHandler
}