require 'webrick'
require 'webrick/https'
require 'openssl'
require 'yaml'
require_relative '../lib/logging'
require_relative '../lib/parameter'


class StartPageVisitServer
  attr :server

  def initialize(port)
    cert = OpenSSL::X509::Certificate.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.cert')
    pkey = OpenSSL::PKey::RSA.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.key')

    #@server = WEBrick::HTTPServer.new(:Port => 443,
    #                                      :SSLEnable => true,
    #                                      :SSLCertificate => cert,
    #                                      :SSLPrivateKey => pkey)

    @server = WEBrick::HTTPServer.new(:Port => port,
                                      :SSLEnable => false,
                                      :SSLCertificate => nil,
                                      :SSLPrivateKey => nil)
    trap 'INT' do
      @server.shutdown
    end
    begin
    server.mount_proc '/start_link' do |req, res|
      param = req.query
      @@logger.a_log.info "method #{param["method"]}"
      @@logger.a_log.info "url #{param["url"]}"
      @@logger.a_log.info "visitor id #{param["visitor_id"]}"
      @@logger.a_log.info "header http #{req.header}"
      @@logger.a_log.info "cookies http #{req.cookies}"
      case param["method"]
        when "noreferrer"
          res.body =<<-_end_of_html_
            <HTML>
             <HEAD>
              <BODY>
                <A href=\"#{param["url"]}\" rel=\"noreferrer\">#{param["url"]}</A><BR>
                <H3>Query String</H3>
                  #{req.query_string}
                <H3>Header Variables</H3>
                  #{req.header}
                <H3>Cookies</H3>
                  #{req.cookies}
              <BODY
            </HEAD>
            </HTML>
          _end_of_html_

        when "datauri"

          res.body =<<-_end_of_html_
            <HTML>
             <HEAD>
              <BODY>
                <A href=\"#{param["url"]}\" style=\"color:blue\">#{param["url"]}</A><meta http-equiv=refresh content=\"0;url=#{param["url"]}\"><BR>
                <H3>Query String</H3>
                  #{req.query_string}
                <H3>Header Variables</H3>
                  #{req.header}
                <H3>Cookies</H3>
                  #{req.cookies}
              <BODY
            </HEAD>
            </HTML>
          _end_of_html_

      end

      res['Content-Type'] = 'text/html; charset=iso-8859-1'
      res.status = 200
    end
    rescue Exception => e
      @@logger.an_event.error e.message
    end
  end

  def start
    @server.start
    @@logger.a_log.info "start page visit server is starting"
  end
end


#--------------------------------------------------------------------------------------------------------------------
# INIT
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
rescue Exception => e
  STDERR << e.message
else
  $staging = parameters.environment
  $debugging = parameters.debugging
  $start_page_server_port = parameters.start_page_server_port

  @@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.join("#{File.basename(__FILE__, ".rb")}"), :debugging => $debugging)
  @@logger.a_log.info "parameters of start page visit server :"
  @@logger.a_log.info "debugging : #{$debugging}"
  @@logger.a_log.info "staging : #{$staging}"
  @@logger.a_log.info "staging : #{ $start_page_server_port}"

  if  $start_page_server_port.nil? or
      $debugging.nil? or
      $staging.nil?
    STDERR << "some parameters not define"
    Process.exit(1)
  end
end


#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
StartPageVisitServer.new($start_page_server_port).start
@@logger.a_log.info "start page visit server stopped"
