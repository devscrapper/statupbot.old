require 'eventmachine'
require 'em-http-server'
require 'uuid'
require 'yaml'
require_relative '../../lib/flow'


class HTTPHandler < EM::HttpServer::Server
  attr        :debugging_visitor_bot

  ARCHIVE = Pathname(File.join(File.dirname(__FILE__), "..", "..", "archive")).realpath
  LOG = Pathname(File.join(File.dirname(__FILE__), "..", "..", "log")).realpath

  def initialize(debugging_visitor_bot)
    @debugging_visitor_bot = debugging_visitor_bot
    super
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'text/html'

    case @http_request_uri
      when /\/visit_id\/.+/
        visit_id = @http_request_uri.split(/\/visit_id\//).join("")
        visit_flow = Flow.from_absolute_path(Dir.glob(File.join(ARCHIVE, "*#{visit_id}.yml"))[0])
        response.content =<<-_end_of_html_
#{YAML::load(visit_flow.read).to_html}
        _end_of_html_
      when /\/visitor_id\/.+/
        visitor_id = @http_request_uri.split(/\/visitor_id\//).join("")
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
      when "/favicon.ico"
        # on fait rien
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

