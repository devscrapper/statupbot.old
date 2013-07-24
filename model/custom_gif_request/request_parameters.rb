require 'uri'
#Variable 	Description 	Example Value
#utmac 	Account String. Appears on all requests. 	utmac=UA-2202604-2
#utmcc
#	Cookie values. This request parameter sends all the cookies requested from the page.
#	utmcc=__utma%3D117243.1695285.22%3B%2B __utmz%3D117945243.1202416366.21.10. utmcsr%3Db%7C utmccn%3D(referral)%7C utmcmd%3Dreferral%7C utmcct%3D%252Fissue%3B%2B
#utmcn 	Starts a new campaign session. Either utmcn or utmcr is present on any given request. Changes the campaign tracking data; but does not start a new session
#	utmcn=1
#utmcr
#	Indicates a repeat campaign visit. This is set when any subsequent clicks occur on the same link. Either utmcn or utmcr is present on any given request.
#	utmcr=1
#utmcs

#	utmcs=ISO-8859-1
#utmdt
#	Page title, which is a URL-encoded string. 	utmdt=analytics%20page%20test
#utme 	Extensible Parameter 	Value is encoded. Used for events and custom variables.
#utmfl
#	Flash Version 	utmfl=9.0%20r48&
#utmhn
#
#	Host Name, which is a URL-encoded string. 	utmhn=x343.gmodules.com
#utmhid
#
#	A random number used to link Analytics GIF requests with AdSense. 	utmhid=2059107202
#utmipc
#	Product Code. This is the sku code for a given product.
#
#	utmipc=989898ajssi
#utmipn
#	Product Name, which is a URL-encoded string. 	utmipn=tee%20shirt
#utmipr
#	Unit Price. Set at the item level. Value is set to numbers only in U.S. currency format.
#	utmipr=17100.32
#utmiqt
#	Quantity. 	utmiqt=4
#utmiva
#	Variations on an item. For example: large, medium, small, pink, white, black, green. String is URL-encoded.
#	utmiva=red;
#utmje
#	Indicates if browser is Java-enabled. 1 is true. 	utmje=1
#utmn
#	Unique ID generated for each GIF request to prevent caching of the GIF image. 	utmn=1142651215
#utmp
#	Page request of the current page. 	utmp=/testDirectory/myPage.html
#utmr
#	Referral, complete URL. 	utmr=http://www.example.com/aboutUs/index.php?var=selected
#utmsc
#	Screen color depth 	utmsc=24-bit
#utmsr
#	Screen resolution 	utmsr=2400x1920&
#utmt
#	Indicates the type of request, which is one of: event, transaction, item, or custom variable. If this value is not present in the GIF request, the request is typed as page. 	utmt=event
#utmtci
#	Billing City 	utmtci=San%20Diego
#utmtco
#	Billing Country 	utmtco=United%20Kingdom
#utmtid
#	Order ID, URL-encoded string. 	utmtid=a2343898
#utmtrg
#	Billing region, URL-encoded string. 	utmtrg=New%20Brunswick
#utmtsp
#	Shipping cost. Values as for unit and price. 	utmtsp=23.95
#utmtst
#	Affiliation. Typically used for brick and mortar applications in ecommerce. 	utmtst=google%20mtv%20store
#utmtto
#	Total. Values as for unit and price. 	utmtto=334.56
#utmttx
#	Tax. Values as for unit and price. 	utmttx=29.16
#utmul
#	Browser language. 	utmul=pt-br
#utmwv
#	Tracking code version 	utmwv=1

#TODO utmwv=5.4.3&utms=1&utmn=693578322&utmhn=www.epilation-laser-definitive.info&utmcs=iso-8859-1&utmsr=2025x1139&utmvp=825x319&utmsc=32-bit&utmul=fr&utmje=1&utmfl=10.1%20r102&utmdt=Epilation%20Laser%20Epilation%20Definitive%20comment%20s'%C3%A9piler%20au%20laser%20pour%20que%20les%20poils%20repoussent%20plus&utmhid=1367063264&utmr=-&utmp=%2F&utmht=1372954335463&utmac=UA-32426100-1&utmcc=__utma%3D60866808.1582664500.1372954335.1372954335.1372954335.1%3B%2B__utmz%3D60866808.1372954335.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&utmu=qB~

module CustomGifRequest
  class RequestParameters

    attr :utmcs, #	Language encoding for the browser. Some browsers don't set this, in which case it is set to "-"
         :utmsr, # Screen resolution 	utmsr=2400x1920&
         :utmvp,
         :utmsc, #	Screen color depth 	utmsc=24-bit
         :utmul, #	Browser language. 	utmul=pt-br
         :utmje, #	Indicates if browser is Java-enabled. 1 is true. 	utmje=1
         :utmfl, #	Flash Version 	utmfl=9.0%20r48&
         :utmr, #	Referral, complete URL. 	utmr=http://www.example.com/aboutUs/index.php?var=selected
         :referer,
         :utmccn,
         :utmcsr,
         :utmcmd,
         :utmctr,
         :utmcct


    def initialize(visitor, referer)
      @utmcs = visitor.utmcs
      @utmsr = visitor.browser.screen_resolution
      @utmsc = visitor.browser.screens_colors
      @utmvp = visitor.browser.viewport_resolution
      @utmul = visitor.utmul
      @utmje = 0 if visitor.browser.java_enabled == "No"
      @utmje = 1 if visitor.browser.java_enabled == "Yes"
      @utmfl = visitor.browser.flash_version #encoder la version de flash
      @utme = "8(visitor)9(#{visitor.id})11(1)"
      @referer = referer
                                             #@utmccn = referer.utmccn #TODO à valider
                                             #@utmcsr = referer.utmcsr #TODO à valider
                                             #@utmcmd = referer.utmcmd #TODO à valider
                                             #@utmctr = referer.utmctr
                                             #@utmcct = referer.utmcct

      if !@referer.is_a?(Referers::NoReferer)
        uri = URI("http://#{referer.landing_page}")
        @utmhn = uri.host
        @utmp = "#{uri.path}"
        @utmp += "?#{uri.query}" unless uri.query.nil?
        @utmp += "##{uri.fragment}" unless uri.fragment.nil?
      end
    end

    def customize(query)
      #@utmcc =__utma%3D60866808.1582664500.1372954335.1372954335.1372954335.1%3B%2B__utmz%3D60866808.1372954335.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B
      request_parameters = Hash[URI.decode_www_form(query).collect { |v| v }]
      request_parameters["utmcs"] = @utmcs
      request_parameters["utmsr"] = @utmsr
      request_parameters["utmsc"] = @utmsc
      p request_parameters["utmvp"] #TODO controler que la valeur recuperer de phantomjs est suffisante.
      request_parameters["utmvp"] = @utmvp
      request_parameters["utmul"] = @utmul
      request_parameters["utmje"] = @utmje
      request_parameters["utmfl"] = @utmfl
      request_parameters["utme"] = @utme
      request_parameters["utmac"] = "UA-25661960-2" #TODO à supprimer dès lors que l'on veut enregistrer les requete sur le GA de epilation
      #TODO faire fontionnler le parametrage manuel du utmcc si la maj auto par phantomjs ne fonctionne pas ; pour cela request_parameter consever l'objet referer et demande à la methode utmcc de chaque referer de faire le rempalczement qui se doit. ATTENTION : prendre garder à l'ordre des utm... pour chaque referer (ordre aujord'huio non connu)
      #request_parameters["utmcc"].gsub!(/utmcsr=(.+)\|utmccn=(.+)\|utmcmd=(.+);/, \
      # "utmcsr=(#{@utmcsr})|utmccn=(#{@utmccn})|utmcmd=(#{@utmcmd});") if  !@referer.is_a?(Referers::NoReferer) and \
      #                                                                     request_parameters["utmhn"] == @utmhn and \
      #                                                                    request_parameters["utmp"] == @utmp


      URI.encode_www_form(request_parameters)
    end

    def to_s
      "utmcs : #{@utmcs}\n" + \
      "utmsr : #{@utmsr}\n" + \
      "utmsc : #{@utmsc}\n" + \
      "utmvp : #{@utmvp}\n" + \
      "utmul : #{@utmul}\n" + \
      "utmje : #{@utmje}\n" + \
      "utmfl : #{@utmfl}\n" + \
      "utme : #{@utme}\n" + \
      "utmr : #{@utmr}\n" + \
      "utmcsr : #{@utmcsr}\n" + \
      "utmccn : #{@utmccn}\n" + \
      "utmcmd : #{@utmcmd}"
    end

    private

  end

end