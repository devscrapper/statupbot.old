require 'webrick'
require 'webrick/https'
require 'openssl'
require 'yaml'
require_relative '../lib/logging'

class StartPageVisitServer
  attr :server

  def initialize
    cert = OpenSSL::X509::Certificate.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.cert')
    pkey = OpenSSL::PKey::RSA.new File.read File.join(File.dirname(__FILE__), '..', 'certificat', 'start_page_visit_server.key')

    @server = WEBrick::HTTPServer.new(:Port => 443,
                                      :SSLEnable => true,
                                      :SSLCertificate => cert,
                                      :SSLPrivateKey => pkey)
    trap 'INT' do
      @server.shutdown
    end

    server.mount_proc '/' do |req, res|
      res.body = "<html><head> </head><body>#{req}</body></html>"
      res['Content-Type'] = 'text/html'
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
