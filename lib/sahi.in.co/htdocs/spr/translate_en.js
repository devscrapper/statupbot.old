function Stub(s) {
	this.toString = function(){return s;}
	this.value = "value of " + s;
}

function Translator(isLib) {
	this.accessors = [[]];
	this.num2word = ["", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth"];
	this.CHECK_REGEXP = /^\/.*\/i?$/;
	this.prefix = "";
	this.isLib = (isLib == true);

	this.addAccessorFunctions = function (acc) {
		var k = acc[0];
		var v = (acc.length > 1) ? acc[1] : k; 
		this["_" + k] = function () {
			var s = ' ' + this.inWords(arguments[0]) + ' ' + v + this.concat(arguments);
			return new Stub(s);
		}
	}
	
	this.getAccessorsInfo = function () {
		if (this.isLib) {
			var Utils = Packages.net.sf.sahi.util.Utils;
			var Configuration = Packages.net.sf.sahi.config.Configuration;
			var CSV = Packages.net.sf.sahi.util.CSV;
			var fileStr = Utils.readFileAsString(Utils.concatPaths(Configuration.getHtdocsRoot(),"spr/accessors.csv"));
			var csv = new CSV();
			csv.load(fileStr);
			return csv.toJSON();
		} else {
			return sahiSendToServer("/_s_/dyn/pro/SahiAPIHelper_getAccessorsInfo");
		}
	}
	
	this.init = function () {
		var csv = this.getAccessorsInfo();//sahiSendToServer("/_s_/dyn/pro/SahiAPIHelper_getAccessorsInfo");
		csv = eval("(" + csv + ")");
		for (var i=1; i<csv.length; i++) {
			var apiName = csv[i][0];
			apiName = apiName.replace("_", "");
			this.addAccessorFunctions([apiName, getTranslatedText(apiName)]);
		}
	}
	
	this.inWords = function (s) {
		if (typeof s == "number") {
			if (s <= this.num2word.length)
				return 'the ' + this.num2word[s];
			else 
				return s;
		}
		var o = this.getArrayNameAndIndex(s);
		var i = o.index;
		var n = o.name;
		if (i == -1) return '"' + customizeIdentifier(n) + '"';
		return 'the ' + customizeIdentifier(this.num2word[i]) + ' "' + n + '"';
	}

	this.concat = function (args) {
		var s = " ";
		for (var i=1; i<args.length; i++) {
			if (i != 1) s += " and ";
			s += args[i];
		}
		return s;
	}

	this._near = function (s) {
		return 'near ' + s;
	}

	this._under = function (s) {
		return 'under ' + s;
	}

	this._in = function (s) {
		return 'inside ' + s;
	}

	this._click = function (s) {
		return this.addPrefix('Click on ' + s);
	}
	
	this._include = function (s) {
		return 'Include file "' + s + '".';
	}
	
	this._rightClick = function (s) {
		return this.addPrefix('Right click on ' + s);
	}

	this._doubleClick = function (s) {
		return this.addPrefix('Double click on ' + s);
	}
	
	this._check = function (s) {
		return this.addPrefix('Check ' + s);
	}
	
	this._uncheck = function (s) {
		return this.addPrefix('Uncheck ' + s);
	}
	
	this._mouseOver = function (s) {
		return this.addPrefix('Hover on ' + s);
	}
	
	this._mouseDown = function (s) {
		return this.addPrefix('Simulate mouse down event on ' + s);
	}
	
	this._mouseUp = function (s) {
		return this.addPrefix('Simulate mouse up event on ' + s);
	}
	
	this._dragDrop = function (f, t) {
		return this.addPrefix('Drag ' + f + ' and drop on ' + t);
	}
	
	this._setValue = function (s, v) {
		return this.addPrefix('Enter value "' + v + '" in ' + s);
	}
	
	this._type = function (e, t) {
		return this.addPrefix('Type "' + t + '" in ' + e);
	}
	
	this._setSelected = function (s, v) {
		return this.addPrefix('Select ' + this.inWords(v) + ' option in ' + s);
	}
	
	this._assertExists = function (s) {
		return this.addPrefix('Assert that ' + s + ' exists');
	}
	
	this._assertVisible = function (s) {
		return this.addPrefix('Assert that ' + s + ' is visible');
	}
	
	this._navigateTo = function (s) {
		return this.addPrefix('Navigate to "' + s + '" URL');
	}


	this._log = function (m, t) {
		return this.addPrefix((typeof t == 'undefined')? 'Log message "' + m + '" in the playback logs' : 
		'Log message "' + m + '" in the playback logs as "' + t + '"');
	}
		
	this._setFile = function(e, f, u) {
		return this.addPrefix('Set the ' + e + ' field with "' + f + '"');
	}
	
	this._wait = function (t) {
		return this.addPrefix('Wait for ' + t + ' milliseconds');
	}
	
	this._focus = function (s) {
		return this.addPrefix('Bring ' + s + ' into focus');
	}
	
	this._removeFocus = function (s) {
		return this.addPrefix('Remove focus from ' + s);
	}
	
	this._keyPress = function (e, c) {
		return this.addPrefix('Press key "' + c + '" in ' + e);
	}
	
	this._keyDown = function (e, c) {
		return this.addPrefix('Simulate key down event for key "' + c + '" in ' + e);
	}
	
	this._keyUp = function (e, c) {
		return this.addPrefix('Simulate key up event for key "' + c + '" in ' + e);
	}
	
	this._blur = function (s) {
		return this.addPrefix('Remove focus from ' + s);
	}
	
	this._assert = function (s) {
		return this.addPrefix('Assert that ' + s);
	}
	
	this._assertEqual = function (e, a) {
		return this.addPrefix('Assert that ' + a + ' is ' + this.inWords(e));
	}
	
	this._assertNull = function (s) {
		return this.addPrefix('Assert that ' + s + ' is null');
	}

	this._assertNotNull = function (s) {
		return this.addPrefix('Assert that ' + s + ' is not null');
	}
	
	this._isVisible = function (s) {
		return  s + ' is visible';
	}
	
	this._getValue = function (s) {
		return "value of " + s;
	}	
	
	this._getText = function (s) {
		return "text of " + s;
	}	
	
	this._takeScreenShots = this._takeSnapShots = function (enabled) {
		return (enabled ? "Start" : "Stop") + " taking screen shots of window after each step";
	}

	this._takePageScreenShot = function (el) {
		return "Take screen shot of " + (el == null ? "window" : el);
	}
	
	this._takeScreenShot = this._takeSnapShot = function () {
		return this._takePageScreenShot();
	}
	
	this._focusWindow = function (s) {
		return this.addPrefix('Bring window into focus');
	}
	
	this._selectWindow = function (s) {
		return "Select "+ (s?('"'+s+'"'):"base") + " window";
	}
	
	this._selectDomain = function (s) {
		return "Select "+ (s?('"'+s+'"'):"base") + " domain";
	}
	
	this.translate = function(s) {
	if(s=="") return s;
		with (this) {
			return eval(s);
		}
	}

	this.getArrayNameAndIndex = function (id) {
	    var o = new Object();
	    if (!(id instanceof RegExp)) {
	    	if (typeof id == "object") {
	    		o.index = (id.sahiIndex != null) ? id.sahiIndex : -1;
	    		o.name = {};
	    		for (var k in id) {
	    			if (k != "sahiIndex") o.name[k] = this.checkRegex(id[k]);
	    		}
	    		return o;
	    	} else {
		    	var m = id.match(/(.*)\[([0-9]*)\]$/);
		    	if (m){
			        o.name = this.checkRegex(m[1]);
			        o.index = m[2];
			        return o;
		    	}
	    	}
	    }
		o.name = this.checkRegex(id);
		o.index = -1;
	    return o;
	};
	
	this.checkRegex = function(s){
		return ((typeof s) == "string" && s.match(this.CHECK_REGEXP)) ?  eval(s) : s;
	};
	
	this._domain = function (s) {
		var d = new Translator(this.isLib);
		d.prefix = " (on domain \"" + s  + "\")";
		return d;
	}
	
	this._popup = function (s) {
		var d = new Translator(this.isLib);
		d.prefix = " (on window \"" + s  + "\")";
		return d;
	}
	
	this.addPrefix = function (s) {
		return s + this.prefix;
	}
	
	
	// initialize
	this.init();
}



getTranslatedText = function (apiName) {
	var overrides = {password:"password box", submit:"submit button", select: "select box"};
	var override = overrides[apiName];
	return override ? override : apiName;
}

function customizeIdentifier(s) {
	return s;
}
