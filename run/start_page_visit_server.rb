require 'webrick'
require 'webrick/https'
require 'openssl'
require 'yaml'
require_relative '../lib/logging'
#TODO declarer le server comme un service windows
class StartPageVisitServer
  attr :server

  def initialize
    cert = OpenSSL::X509::Certificate.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.cert')
    pkey = OpenSSL::PKey::RSA.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.key')

    #@server = WEBrick::HTTPServer.new(:Port => 443,
    #                                      :SSLEnable => true,
    #                                      :SSLCertificate => cert,
    #                                      :SSLPrivateKey => pkey)
    #TODO externliser le port d'ecoute et l'usage de https
    @server = WEBrick::HTTPServer.new(:Port => 8080,
                                      :SSLEnable => false,
                                      :SSLCertificate => nil,
                                      :SSLPrivateKey => nil)
    trap 'INT' do
      @server.shutdown
    end

    server.mount_proc '/start_link' do |req, res|
      param = req.query

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
          #res.body = "<html><head> </head><body><a href=\"#{param["url"]}\" rel=\"noreferrer\">#{param["url"]}</a></body></html>"
        when "datauri"
          res.body = "<html><head> </head><body>no defined</body></html>"
      end

      res['Content-Type'] = 'text/html; charset=iso-8859-1'
      res.status = 200
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
ENVIRONMENT= File.join(File.dirname(__FILE__) ,'..', 'parameter/environment.yml')
$staging = "production"
$debugging = false
#--------------------------------------------------------------------------------------------------------------------
# INPUT
#--------------------------------------------------------------------------------------------------------------------
begin
  environment = YAML::load(File.open(ENVIRONMENT), "r:UTF-8")
  $staging = environment["staging"] unless environment["staging"].nil?
rescue Exception => e
  STDERR << "loading environement file #{ENVIRONMENT} failed : #{e.message}"
end

@@logger = Logging::Log.new(self, :staging => $staging, :id_file => File.basename(__FILE__, ".rb"), :debugging => $debugging)


@@logger.a_log.info "parameters of start page visit server :"
@@logger.a_log.info "debugging : #{$debugging}"
@@logger.a_log.info "staging : #{$staging}"
#--------------------------------------------------------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------------------------------------------------------
StartPageVisitServer.new.start
@@logger.a_log.info "start page visit server stopped"
