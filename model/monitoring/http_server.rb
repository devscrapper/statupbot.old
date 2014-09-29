require 'eventmachine'
require 'em-http-server'
require 'uuid'
require 'yaml'
require_relative '../../lib/message'
require_relative '../../lib/flow'

class Hash

  def to_html_stat(messages)
    [
        '<ul>',
        map { |k, v| [!k.is_a?(Date) ? "<li><strong>#{k}</strong> - #{messages[k]}"  : "<li><strong>#{k}</strong> : ", v.respond_to?(:to_html) ? v.to_html_stat(messages) : " (<strong>#{v}</strong>)</li>"] },
        '</ul>'
    ].join
  end

  def to_html_stat3
    [
        '<ul>',
        map { |k, v| [!k.is_a?(Date) ? "<li><strong>#{k}</strong>" : "<li><strong>#{k}</strong> : ", v.respond_to?(:to_html) ? v.to_html_stat3 : " (<strong>#{v[0]} - max #{v[1]}</strong>)</li>"] },
        '</ul>'
    ].join
  end
  def to_html_stat2
    [
        '<ul>',
        map { |k, v| [!k.is_a?(Date) ? "<li><strong>#{k}</strong>" : "<li><strong>#{k}</strong> : ", v.respond_to?(:to_html) ? v.to_html_stat2 : " (<strong>#{v}</strong>)</li>"] },
        '</ul>'
    ].join
  end
  def to_html(messages)
    [
        '<ul>',
        map { |k, v| ["<li>#{display_code(k, v, messages)}", v.respond_to?(:to_html) ? v.to_html(messages) : " #{v}</li>"] },
        '</ul>'
    ].join
  end

  def display_code(k, v, messages)

    if  UUID.validate(k)
      "<a href=\"/visit_id/#{k}\">#{k}</a>"
    else
      case k
        when :visitor
          "<a href=\"/visitor_id/#{v}\">#{k}</a>"
        when :visit_details, :browser, :name, :version, :operating_system, :operating_system, :version, :referrer, :referral_path, :source, :medium, :keyword, :durations
          "<strong>#{k}</strong> : "
        else
          "<strong>#{k}</strong> - #{messages[k]}"
      end
    end
  end
end


class HTTPHandler < EM::HttpServer::Server
  attr :return_codes,
       :return_codes_stat,
       :count_success,
       :count_visits,
       :messages,
       :pool_size,
       :visits_out_of_time,
       :advert_select_stat,
       :debugging_visitor_bot
  ARCHIVE = Pathname(File.join(File.dirname(__FILE__), "..", "..", "archive")).realpath
  LOG = Pathname(File.join(File.dirname(__FILE__), "..", "..", "log")).realpath

  def initialize(return_codes, return_codes_stat, count_success, count_visits, pool_size, visits_out_of_time, advert_select_stat, debugging_visitor_bot)
    @return_codes = return_codes
    @return_codes_stat = return_codes_stat
    @count_visits = count_visits
    @count_success = count_success
    @pool_size = pool_size
    @visits_out_of_time = visits_out_of_time
    @advert_select_stat = advert_select_stat
    @messages = Messages.instance
    @debugging_visitor_bot = debugging_visitor_bot
    super
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'text/html'

    case @http_request_uri
      when "/"
        response.content =<<-_end_of_html_
                        <HTML>
                         <HEAD>
                          <BODY>
                            <ul>
                              <li><h1>Statistics</h1>
                            <h2>Advert select</h2>
                            #{@advert_select_stat.to_html_stat2}
                            <h2>Pools size</h2>
                            #{@pool_size.to_html_stat3}
                            <h2>Visits out of time</h2>
                            #{@visits_out_of_time.to_html_stat2}
                            <h2>count visits(#{@count_visits[0]}),
                            success(#{@count_success[0]}, #{(@count_success[0] * 100/@count_visits[0]).to_i if @count_visits[0] > 0}%)</h2>
                            #{@return_codes_stat.to_html_stat(@messages)}</li>
                              <li><h1>Errors history</h1>
                            #{@return_codes.to_html(@messages)}</li>
                            </ul>
                          <BODY>
                        </HEAD>
                        </HTML>
        _end_of_html_
      when /\/visit_id\/.+/
        visit_id = @http_request_uri.split(/\/visit_id\//).join("")
        visit_flow = Flow.from_absolute_path(Dir.glob(File.join(ARCHIVE, "*#{visit_id}.yml"))[0])
        response.content =<<-_end_of_html_
#{YAML::load(visit_flow.read).to_html(@messages)}
        _end_of_html_
      when /\/visitor_id\/.+/
        visitor_id = @http_request_uri.split(/\/visitor_id\//).join("")
        #TODO recuperer la valeur de la variable debug en fonction de l'environement bien sur car on va lire dans le fichier de parametrage de visitor_bot
        log_visitor_flow = Flow.first(LOG, {:typeflow => "visitor", :label => "bot", :date => visitor_id, :ext => @debugging_visitor_bot ? ".deb" : ".log"})

        if log_visitor_flow.nil?
          response.content =<<-_end_of_html_
                        <HTML>
                         <HEAD>
                          <BODY>
                            log visitor <strong>#{visitor_id}</strong> not found
                          <BODY>
                        </HEAD>
                        </HTML>
          _end_of_html_
        else
          response.content =<<-_end_of_html_
          #{log_visitor_flow.readlines("\n").map{|l| "#{l}<br>"}}
          _end_of_html_
        end
      else
        p "uri <#{@http_request_uri}> unknown"
    end


    response.send_response
  end

  def http_request_errback e
    # printing the whole exception
    puts e.inspect
  end

end

