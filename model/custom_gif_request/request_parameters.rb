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
#	Language encoding for the browser. Some browsers don't set this, in which case it is set to "-"
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

module CustomGifRequest
  class RequestParameters
    attr :utmcs


    def initialize(visitor)

    end
    def customize(url)
       url
    end
  end

end