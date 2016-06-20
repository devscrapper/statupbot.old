require 'rest-client'
require 'socket'
require 'json'

module Captcha


  #-----------------------------------------------------------------------------------------------------------------
  # convert_to_string
  #-----------------------------------------------------------------------------------------------------------------
  # input : image (png) encodeé en base 64
  # output : une chaine représetnnant l'image
  # exception : none
  #-----------------------------------------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------------------------------------------


  def convert_to_string(captcha)
    #--------------------------------------------------------------------------------------------------------------------
    # LOAD PARAMETER
    #--------------------------------------------------------------------------------------------------------------------
    begin
      parameters = Parameter.new(__FILE__)

    rescue Exception => e
      $stderr << e.message << "\n"

    else
      $staging = parameters.environment
      $debugging = parameters.debugging
      saas_host = parameters.saas_host
      saas_port = parameters.saas_port
      time_out_saas_captcha = parameters.time_out_saas_captcha
      if saas_host.nil? or
          saas_port.nil? or
          time_out_saas_captcha.nil? or
          $debugging.nil? or
          $staging.nil?
        $stderr << "some parameters not define" << "\n"
      end
    end

    # envoie l'image captcha vers le saas_captcha pour le transformer en string
    begin
      str = ""
#TODO envoyer le captcha au service de conversion saas_captcha
# TODO spécficier un time_out à la requete post avec la avriable time_out_saas_captcha
      response = RestClient.post "http://#{saas_host}:#{saas_port}/captcha/",
                                 JSON.generate(captcha),
                                 :content_type => :json,
                                 :accept => :json
      raise response.content if response.code != 201
        #TODO gerer l'envoie de l'image et le retour
        #TODO doit conserver post, la librairie rest-client ...., peut on envoyer une image en post ou avec get
      str = response.res

    rescue Exception => e
      raise "convert image captcha to string #{saas_host}:#{saas_port} => #{e.message}"

    else
      $stdout << "convert image captcha to string #{saas_host}:#{saas_port}" if $staging == "development"

    ensure
      str
    end
  end


  module_function :convert_to_string

end