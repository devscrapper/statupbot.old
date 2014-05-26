require 'eventmachine'
require 'em-http-server'

class Hash
  def to_html
    [
        '<ul>',
        map { |k, v| ["<li><strong>#{k}</strong> ", v.respond_to?(:to_html) ? v.to_html : "<span>#{v}</span></li>"] },
        '</ul>'
    ].join
  end
end


class HTTPHandler < EM::HttpServer::Server
  attr :return_codes, :count_success,:count_visits


  def initialize(return_codes, count_success, count_visits)
    @return_codes = return_codes
    @count_visits = count_visits
    @count_success = count_success
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
                    <h1>count visits #{@count_visits[0]}</h1>
                    <h1>success #{@count_success[0]} (#{(@count_success[0] * 100/@count_visits[0]).to_i if @count_visits[0] > 0}%)</h1>
                    <h1> error visit</h1
                    #{@return_codes.to_html}
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

