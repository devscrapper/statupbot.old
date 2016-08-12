if (phantom.args.length === 0) {
	console.log('Usage: sahi.js <Sahi Playback Start URL>');
	phantom.exit();
} else {
// unescape not needed since 1.7. Causes problems if url has ampersand	
	var address = phantom.args[0]; 
	console.log('Loading ' + address);
	//setInterval(testNative, 30);
	var page = new WebPage();
	page.viewportSize = { width: 1366, height: 728 };
	page.open(address, function (status) {
	    if (status !== 'success') {
	        console.log('Unable to load the address!');
	    } else {
			console.log("Playback started");
	    }
	});
}

var counter = 0;
var fs = require('fs');
page.onCallback = function(data) {
	var delimiter = "___sahi___format___";
    if(!data || data.indexOf(delimiter) == 0){
    	var imgFormat = null;
    	if(!data){
    		imgFormat = _sahi.getImageFormat();
    	}
    	else if(data.indexOf(delimiter) == 0){
    		try {
    			imgFormat = data.substring(delimiter.length);
    		}
    		catch(err) {
    			imgFormat = _sahi.getImageFormat();
    		}
    	} 
    	if (fs.exists('screenshot.' + imgFormat)) {
    		fs.remove('screenshot.' + imgFormat);
    	}
    	if (fs.exists('screenshottemp.' + imgFormat)) {
    		fs.remove('screenshottemp.' + imgFormat);
    	}
    	page.render('screenshottemp.' + imgFormat, {format: imgFormat});
    	fs.copy('screenshottemp.' + imgFormat, 'screenshot.' + imgFormat);
    }
    else{
    	if(isNaN(data)){
    		page.sendEvent('keypress', data);
    	}else{
    		page.sendEvent('keypress', parseInt(data));
    	}
    }		
};

/*else{
	console.log(1);
	var combo = null;
	if(data.indexOf("__SAHIDELIMITER__") != -1){
		var dataAr = data.split("__SAHIDELIMITER__");
		data = dataAr[0];
		combo = dataAr[1];
		page.sendEvent('keypress', data, null, null, combo);
	}else {
		page.sendEvent('keypress', data);
	}
*/
/*function testNative() {
		var data = fs.read('triggerNative.txt');
		page.sendEvent('keypress', eval(data));
}*/