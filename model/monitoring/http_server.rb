require 'eventmachine'
require 'em-http-server'
require_relative '../../lib/message'

class Hash
  def to_html_stat(messages)
    [
        '<ul>',
        map { |k, v| [!k.is_a?(Date) ? "<li><strong>#{k}</strong> - #{messages[k]}" : "<li><strong>#{k}</strong> : " , v.respond_to?(:to_html) ? v.to_html_stat(messages) : " (<strong>#{v}</strong>)</li>"] },
        '</ul>'
    ].join
  end
  def to_html(messages)
    [
        '<ul>',
        map { |k, v| ["<li><strong>#{k}</strong> - #{messages[k]}", v.respond_to?(:to_html) ? v.to_html(messages) : " #{v}</li><br>"] },
        '</ul>'
    ].join
  end
end


class HTTPHandler < EM::HttpServer::Server
  attr :return_codes, :return_codes_stat, :count_success,:count_visits, :messages


  def initialize(return_codes,return_codes_stat, count_success, count_visits)
    @return_codes = return_codes
    @return_codes_stat = return_codes_stat
    @count_visits = count_visits
    @count_success = count_success
    @messages = Messages.instance
    super
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'text/html'

    response.content =<<-_end_of_html_
                <HTML>
                 <HEAD>
                  <BODY>
                    <ul>
                      <li><h1>Statistics</h1>
                    <h2>count visits(#{@count_visits[0]}),
                    success(#{@count_success[0]}, #{(@count_success[0] * 100/@count_visits[0]).to_i if @count_visits[0] > 0}%)</h2>
                    #{@return_codes_stat.to_html_stat(@messages)}</li>
                      <li><h1>Errors history</h1>
                    #{@return_codes.to_html(@messages)}</li>
                    </ul>
                  <BODY
                </HEAD>
                </HTML>
              _end_of_html_

    response.send_response
  end

  def http_request_errback e
    # printing the whole exception
    puts e.inspect
  end

end

