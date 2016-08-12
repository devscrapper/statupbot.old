/**
 * Copyright Tyto Software Pvt. Ltd.
 */
Sahi.prototype.getSahiScriptStackTrace = function(){
// this.print("getSahiScriptStackTrace called " + (new Date()));
	var s = "";
	try{
		var ss=null;
		ss.toString();
	}catch(edd){
		var s = edd.rhinoException.getScriptStackTrace();
		s = ScriptRunner.getStackTraceForLogging(s);
		s = s.replace(/\\/g, "\\\\");
	}
	return s;
}
// stub start
var __SAHI_NOT_SET__ = "__SAHI_NOT_SET__"
function Stub(s, count){
	this.s = s;
	this.toString = function() {return this.s;};
}
function stubBinder(nodeName){
	return function () {return new Stub(this.s + "." + nodeName);};
}
function indexBinder(index){
	return function () { return new Stub(this.s + "[" + index + "]"); };
}
/*
function xfunctionBinder(nodeName){
	return function () {return this.getNodesArrayFn(nodeName);};
}
*/
var stubGetters = ['ATTRIBUTE_NODE', 'CDATA_SECTION_NODE', 'COMMENT_NODE', 'Components', 'DOCUMENT_FRAGMENT_NODE', 
                   'DOCUMENT_NODE', 'DOCUMENT_POSITION_CONTAINED_BY', 'DOCUMENT_POSITION_CONTAINS', 'DOCUMENT_POSITION_DISCONNECTED', 'DOCUMENT_POSITION_FOLLOWING', 
                   'DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC', 'DOCUMENT_POSITION_PRECEDING', 'DOCUMENT_TYPE_NODE', 'ELEMENT_NODE', 'ENTITY_NODE', 
                   'ENTITY_REFERENCE_NODE', 'NOTATION_NODE', 'PROCESSING_INSTRUCTION_NODE', 'TEXT_NODE', 'URL', 'accept', 
                   'acceptCharset', 'accessKey', 'action', 'activeElement', 'align', 
                   'alinkColor', 'alt', 'anchors', 'applets', 'applicationCache', 
                   'attributes', 'baseURI', 'bgColor', 'body', 'boxObject', 
                   'characterSet', 'charset', 'checked', 'childNodes', 'className', 
                   'clientHeight', 'clientLeft', 'clientTop', 'clientWidth', 'closed', 
                   'cols', 'compatMode', 'console', 'content', 'contentEditable', 
                   'contentType', 'controllers', 'cookie', 'coords', 'crypto', 
                   'defaultChecked', 'defaultStatus', 'defaultValue', 'defaultView', 'designMode', 
                   'dir', 'directories', 'disabled', 'doctype', 'document', 
                   'documentElement', 'documentURI', 'domain', 'elements', 'embeds', 
                   'encoding', 'enctype', 'fgColor', 'files', 'firstChild', 
                   'form', 'forms', 'frameElement', 'frames', 'fullScreen', 
                   'globalStorage', 'hash', 'height', 'history', 'host', 
                   'hostname', 'href', 'hreflang', 'id', 'images', 
                   'implementation', 'innerHTML', 'innerHeight', 'innerWidth', 'inputEncoding', 
                   'lang', 'lastChild', 'lastModified', 'lastStyleSheetSet', 'length', 
                   'length', 'length', 'linkColor', 'links', 'localName', 
                   'location', 'locationbar', 'maxLength', 'menubar', 'method', 
                   'multiple', 'name', 'namespaceURI', 'navigator', 'netscape', 
                   'nextSibling', 'nodeName', 'nodeType', 'nodeValue', 'offsetHeight', 
                   'offsetLeft', 'offsetParent', 'offsetTop', 'offsetWidth', 'opener', 
                   'options', 'outerHeight', 'outerWidth', 'ownerDocument', 'pageXOffset', 
                   'pageYOffset', 'parent', 'parentNode', 'pathname', 'personalbar', 
                   'ping', 'pkcs11', 'plugins', 'port', 'preferredStyleSheetSet', 
                   'prefix', 'previousSibling', 'protocol', 'readOnly', 'readyState', 
                   'referrer', 'rel', 'rev', 'rows', 'cells', 'screen', 
                   'screenX', 'screenY', 'scrollHeight', 'scrollLeft', 'scrollMaxX', 
                   'scrollMaxY', 'scrollTop', 'scrollWidth', 'scrollX', 'scrollY', 
                   'scrollbars', 'search', 'selectedIndex', 'selectedStyleSheetSet', 'selectionEnd', 
                   'selectionStart', 'self', 'sessionStorage', 'shape', 'size', 
                   'spellcheck', 'src', 'status', 'statusbar', 'strictErrorChecking', 
                   'style', 'styleSheetSets', 'styleSheets', 'tabIndex', 'tagName', 
                   'target', 'text', 'textContent', 'textLength', 'title', 
                   'toolbar', 'top', 'type', 'useMap', 'value', 
                   'vlinkColor', 'width', 'window', 'xmlEncoding', 'xmlStandalone', 
                   'xmlVersion'];

for (var i = 0; i < stubGetters.length; i++) {
	nodeName = stubGetters[i];
	Stub.prototype.__defineGetter__(nodeName, stubBinder(nodeName));
}                  
for (var i=0; i<100; i++){
	Stub.prototype.__defineGetter__(""+i, indexBinder(i));
}
Stub.prototype.getClass = function(){
	return {getName: function(){return "Stub";}};
};
Stub.prototype.getNodesArrayFn = function(fnName){
	return function(){
		var s = "";
		for (var i=0; i<arguments.length; i++){
			s += s_v(arguments[i]);
			if (i != arguments.length-1) s += ", ";
		}		
		return new Stub(this.s + "." + fnName + "(" + s + ")");
	};
};
Stub.prototype.__noSuchMethod__ = function(fnName, args){
	var s = "";
	for (var i=0; i<args.length; i++){
		s += s_v(args[i]);
		if (i != args.length-1) s += ", ";
	}
	return new Stub(this.s + "." + fnName + "(" + s + ")");		
};
// stub end
function s_v(v) {
	return _sahi.toJSON(v);
};
SahiHashMap = function(){
	this.keys = new Array();
	this.values = new Array();
	this.put = function(k, v){
		var i = this.getIndex(this.keys, k);
		if (i == -1) i = this.keys.length;
		this.keys[i] = k;
		this.values[i] = v;
	}
	this.get = function(k){
		var i = this.getIndex(this.keys, k);
		return this.values[i];
	}
	this.getIndex = function(ar, k){
		for (var i=0; i<ar.length; i++){
			if (k === ar[i]) return i;
		}		
		return -1;
	}
}
function Sahi(){
	this.stepInterval = ScriptRunner.getTimeBetweenSteps();
	this.maxCycles = ScriptRunner.getMaxCyclesForPageLoad() + 300; // 30 seconds more than page load timeout to account for errors.
	this.maxTimeout = this.stepInterval * this.maxCycles;
	this.countSuffix = 0;
	this.stopOnError = true;
	this.includedFiles = {};
	this.retryOpeningBrowser = true;
};
Sahi.prototype._toJSON = function(o){
 	return this.toJSON(o);
}
Sahi.prototype.toJSON = function(el, map){
	try {
		if (!map) map = new SahiHashMap();
		var j = map.get(el);
		if (j && j == "___in_progress___") {
			return '"recursive_access"'; 
		}
		map.put(el, '___in_progress___');
		var v = this.toJSON2(el, map);
		map.put(el, v);
		return v;
	} catch (e) {
		return "error during toJSON conversion";
	}
}
Sahi.prototype.toJSON2 = function(el, map){
    if (el == null || el == undefined) return 'null';
	try{
		if (el.getClass().getName().indexOf("String")!=-1){
			el = "" + el.toString();
		}
	}catch(e){}    
    
    if (el instanceof Stub) return el.toString();
    if (el instanceof RegExp) return el.toString();
    if (el instanceof Date){
        return String(el);
    }else if (typeof el == 'string'){
        if (/["\\\x00-\x1f]/.test(el)) {
            return '"' + el.replace(/([\x00-\x1f\\"])/g, function (a, b) {
                var c = _sahi.escapeMap[b];
                if (c) {
                    return c;
                }
                c = b.charCodeAt();
                return '\\u00' +
                    Math.floor(c / 16).toString(16) +
                    (c % 16).toString(16);
            }) + '"';
        }
        return '"' + el + '"';
    }else if (el instanceof Array){
        var ar = [];
        for (var i=0; i<el.length; i++){
            ar[i] = this.toJSON(el[i], map);
        }
        return '[' + ar.join(',') + ']';
    }else if (typeof el == 'number'){
        return new String(el);
    }else if (typeof el == 'boolean'){
        return new String(el);
    }else if (typeof el == 'function'){
    	return el.toString();
    }else if (el instanceof Object){
        var ar = [];
        for (var k in el){
            var v = el[k];
            if (typeof v != 'function'){
                ar[ar.length] = this.toJSON(k, map) + ':' + this.toJSON(v, map);
            }
        }
        return '{' + ar.join(',') + '}';
    }
};
Sahi.prototype.convertUnicode = function (source) {
    if (source == null) return null;
    var result = '';
    for (var i = 0; i < source.length; i++) {
        if (source.charCodeAt(i) > 127)
            result += this.addSlashU(source.charCodeAt(i).toString(16));
        else result += source.charAt(i);
    }
    return result;
};
Sahi.prototype.addSlashU = function (num) {
    var buildU
    switch (num.length) {
        case 1:
            buildU = "\\u000" + num
            break
        case 2:
            buildU = "\\u00" + num
            break
        case 3:
            buildU = "\\u0" + num
            break
        case 4:
            buildU = "\\u" + num
            break
    }
    return buildU;
};
Sahi.prototype.escapeMap = {
        '\b': '\\b',
        '\t': '\\t',
        '\n': '\\n',
        '\f': '\\f',
        '\r': '\\r',
        '"' : '\\"',
        '\\': '\\\\'
};
Sahi.prototype.print = function (s){
    java.lang.System.out.println("Rhino lib:" + s);
}
Sahi.prototype.wait = function (n){
    java.lang.Thread.sleep(n);
}

Sahi.prototype.__noSuchMethod__ = function(fnName, args){
	var s = "";
	for (var i=0; i<args.length; i++){
		s += s_v(args[i]);
		if (i != args.length-1) s += ", ";
	}
	return new Stub("_sahi." + fnName + "(" + s + ")");		
};

Sahi.prototype.justStarted = false;
Sahi.prototype.lastId = null;

Sahi.prototype.retry = function(cmd, debugInfo, interval){
    this.wait(interval);
    //this.print('retrying');
    this.schedule(cmd, debugInfo);
};
Sahi.prototype.setStep = function(cmd, debugInfo, stepType){
    //this.print(cmd);
    return ScriptRunner.setStep(cmd, debugInfo, stepType);
};
Sahi.prototype.executeWait = function(cmd, debugInfo){
	var t = this.extractTimeFromWait(cmd);
    var cycles = t / this.stepInterval;    
    this.schedule2(cmd, debugInfo, cycles, "WAIT");	
};
Sahi.prototype.extractTimeFromWait = function(cmd) {
	var ix = cmd.indexOf("(");
	var ix2 = cmd.indexOf(",", ix+1);
	if (ix2 == -1) ix2 = cmd.indexOf(")", ix+1);
	return parseInt(this.trim(cmd.substring(ix+1, ix2)).replace(/["']/g, ""));
}
Sahi.prototype.executeWithLogging  = function(cmd, debugInfo, stepType){
	try {
		eval(cmd);		
		ScriptRunner.stripAndLog(cmd, debugInfo, stepType, "");
	} catch (e) {
		if (e.debugInfo == "FORCED_FAIL") {
			ScriptRunner.stripAndLog(cmd, debugInfo, "ERROR", e.message);
		} else {
			ScriptRunner.stripAndLog(cmd, debugInfo, "ERROR", e.message);				
		}
		throw new SahiException(cmd, debugInfo);
	}
}
Sahi.prototype.sLSc = function (cmd, debugInfo, e) {
	if(this.isScreenShot(cmd)){
		ScriptRunner.setStep(cmd, debugInfo, "WAIT");
		ScriptRunner.stripAndLog(cmd, debugInfo, "INFO", "");
	}
}
Sahi.prototype.isScreenShot = function (cmd) {
	return cmd.indexOf("_takeScreenShot") == 0 || cmd.indexOf("_takeSnapShot") == 0;
}
Sahi.prototype.sL = function (cmd, debugInfo, e) {
	if (e) {
		ScriptRunner.stripAndLog(cmd, debugInfo, "ERROR", (e && e.message) ? e.message : e);
		throw new SahiException("ALREADY_LOGGED" + cmd, debugInfo);
	} else {
		if(!this.isScreenShot(cmd)){
			ScriptRunner.stripAndLog(cmd, debugInfo, "INFO", "");
		}
	}
}
Sahi.prototype.scheduleNoLog = function(cmd){
	this.schedule(cmd, null, "NO_LOG");
}
Sahi.prototype.schedule = function(cmd, debugInfo, stepType){
	if (!stepType) stepType = "NORMAL"; 
	if (this.disableInfo && stepType == "NORMAL")  stepType = "NO_LOG";
    var cycles = this.maxCycles;
    this.schedule2(cmd, debugInfo, cycles, stepType, true);
}
Sahi.prototype._wait = function(t, condn){
    return t;
}
Sahi.prototype.quoted = function (s) {
	if (s == null || s == undefined) return null;
    return '"' + s.replace(/"/g, '\\"') + '"';
};
Sahi.prototype.escapeForCSV = function (s) {
    return '"' + s.replace(/"/g, '""') + '"';
};
Sahi.prototype._condition = function(c, debugInfo){
	var key = "__lastConditionValue__" + (this.countSuffix++);
	ScriptRunner.setVariable(key, __SAHI_NOT_SET__);
	this.scheduleNoLog("_sahi.saveCondition(\"" + key + "\", " + c + ")", debugInfo);
	var i = 0;
	while(i++ < 5){
		this.wait(100);
		var res = this.getServerVar(key);
		if (res != __SAHI_NOT_SET__) {
			break;
		}
	}
	return res == "true";
}
Sahi.prototype.callOnBeforeStep = function(step ,debugInfo){
	if (typeof onBeforeStep != "function") return;
	this.inOnBeforeStepFn = true;
	try {
		return onBeforeStep(step ,debugInfo);
	} finally {
		this.inOnBeforeStepFn = false;
	}
}
Sahi.prototype.callOnAfterStep = function(step ,debugInfo , status){
	if (typeof onAfterStep != "function") return;
	this.inOnAfterStepFn = true;
	try {
		return onAfterStep(step ,debugInfo, status);
	} finally {
		this.inOnAfterStepFn = false;
	}
}
Sahi.prototype._disableInfoLogging = function(){
	this.disableInfo = true;
}
Sahi.prototype._enableInfoLogging = function(){
	this.disableInfo = false;
}
Sahi.prototype._enableDefaultErrorLogging = function(){
	ScriptRunner.setDefaultErrorLoggingEnabled(true);
}
Sahi.prototype._disableDefaultErrorLogging = function(){
	ScriptRunner.setDefaultErrorLoggingEnabled(false);
}
Sahi.prototype.isInCallBackFn = function () {
	return this.inOnBeforeStepFn || this.inOnAfterStepFn  || this.inOnScriptFailureFn || this.inOnScriptErrorFn;
}
Sahi.prototype.schedule2 = function(cmd, debugInfo, cycles, stepType, throwException){
    if (cmd == 'done') return;
    if (!this.handleJSErrors()) {
    	throw new SahiException("Failed due to JS Error", "");
    }
    ScriptRunner.setStackTrace("");
    if (this.windowContext && cmd.indexOf("_sahi._popup") != 0) { 
    	cmd = "_sahi._popup(" + this.quoted(this.windowContext) + ")." + cmd;
    }
    if (this.domainContext && cmd.indexOf("_sahi._domain") != 0) { 
    	cmd = "_sahi._domain(" + this.quoted(this.domainContext) + ")." + cmd;
    }
    if (!this.isInCallBackFn()) this.callOnBeforeStep(cmd, debugInfo);
    this.lastId = this.setStep(cmd, debugInfo, stepType);
    //this.print(cmd);
    var i=0;
    var tempStatus;
    while(i++ < cycles){
        if (ScriptRunner.doneStep(this.lastId) || ScriptRunner.isStopped()){
        	var status = ScriptRunner.getStatus().getName();
        	var exception = new SahiException(ScriptRunner.getBrowserException(), debugInfo);
        	var onScriptErrorResult = false;
        	tempStatus = status;
        	if (!this.isInCallBackFn()) {
	        	if (status == "ERROR") {
	        		var stackTraceBeforeErrorCallback = this.getSahiScriptStackTrace();
	        		onScriptErrorResult = this.callOnScriptError(exception);
	        	} else if (status == "FAILURE"){
	        		this.callOnScriptFailure(exception);
	        	} 
        	}
			if (status == "ERROR" && this.stopOnError && (onScriptErrorResult != true || this.inOnScriptErrorFn)) {
				exception.message += "::>FAILUREMESSAGE:" + stackTraceBeforeErrorCallback + 
					(ScriptRunner.isDefaultErrorLoggingEnabled() ? "\n::>ALREADY_LOGGED" : "");  
				throw exception;
        	}
            if (ScriptRunner.isStopped()) {
            	throw new SahiException("Stopped explicitly by user or script", debugInfo);
            }
            if (!this.isInCallBackFn() && status =="SUCCESS") this.callOnAfterStep(cmd, debugInfo, tempStatus);
            return;
        }else{
        	if (ScriptRunner.needsStackTrace()) {
        		ScriptRunner.setStackTrace(this.getSahiScriptStackTrace());
        	}
        	ScriptRunner.getSession().touch(); // prevent timeout in long waits
            this.wait(this.stepInterval);
        }
    }
    if (throwException){
    	tempStatus = "UNRESPONSIVE_EXCEPTION";
	    var msg = "Step >" + cmd + "< did not complete in "+(this.maxTimeout/1000)+" seconds.";
	    this.print(msg);
	    var exc = new SahiException(msg, debugInfo);
	    exc.isBrowserNotResponding = true;
	    if (!this.inOnBeforeStepFn && !this.inOnAfterStepFn) this.callOnAfterStep(cmd, debugInfo, tempStatus);
	    this.callOnScriptError(exc);
	    throw exc;
    }else{
    	var resultType = (stepType == "NO_LOG") ? "NO_LOG" : "INFO";
    	tempStatus = "WAIT";
    	ScriptRunner.markStepDoneFromLib(""+this.lastId, resultType, null);
    	if (!this.inOnBeforeStepFn && !this.inOnAfterStepFn) this.callOnAfterStep(cmd, debugInfo, tempStatus);
    }
};
Sahi.prototype.firstTime_FOR_TESTING_ONLY = false; // set to true for testing only.;
Sahi.prototype.start = function(){
//	if (net.sf.sahi.config.Configuration.isReportCodeFoldingEnabled()) {
//		_sahi.clubFunctionsLogging(_sahi.global);
//	}
	if (this.started) return;
	this.started = true;
	this.initialMemory = java.lang.Runtime.getRuntime().totalMemory();
    var i=0;
    var cycles = this.maxCycles/3;
    while(i++ < cycles){
        if (this.firstTime_FOR_TESTING_ONLY || !ScriptRunner.isRunning()) {
            this.wait(this.stepInterval);
        }else{
            this.justStarted = true;
            var globalScript = net.sf.sahi.util.Utils.concatPaths(net.sf.sahi.config.Configuration.getUserDataDir(), 
        			net.sf.sahi.config.Configuration.getGlobalncludeFile());
            if (new java.io.File(globalScript).exists()) {
            	this._include(globalScript);
            } else {
            	this.print("\n--\nGlobal include script not found at:\n" + globalScript+"\n--");
            }
            return;
        }
    }
    if (ScriptRunner.isPartOfSuite()) {
    	if (this.retryOpeningBrowser) {
    		var msg = 'Script ' + this._scriptName() + ' did not start within ' + parseInt((this.maxTimeout/3)/1000) + ' seconds. Trying to open browser again.';
    		this.print(msg);
    		this._log(msg, "CUSTOM");
    		this.firstTime_FOR_TESTING_ONLY = false;
    		this._closeBrowser();
    		this.wait(1000);
    		this._openBrowser();
    		this.retryOpeningBrowser = false;
    		this.started = false;
    		this.start();
    	} else {
    		throw new SahiException('Script did not start within ' + parseInt((this.maxTimeout/3)/1000) + ' seconds.');
    	}
    }
};
Sahi.prototype._execute = function (cmd, isSync, timeout) {
	isSync = ""+isSync == "true";
	if (timeout == null) timeout = 5*60*1000;
	return net.sf.sahi.util.Utils.executeCommand(cmd, isSync, timeout);
};
Sahi.prototype._dynamicInclude = function ($fileName) {
	this._include($fileName);
	return;
	var thisPath = this._scriptPath().replace(/\\/g, "/");
	var filePath = "" + net.sf.sahi.util.Utils.concatPaths(thisPath, $fileName);
	if (this.includedFiles[filePath]) return;
	this.includedFiles[filePath] = true;
	var includedScript = (new net.sf.sahi.playback.ScriptFactory()).getScript(filePath);
	var script = ScriptRunner.getScript();
	var includedJS = "" + includedScript.jsString();
	script.addIncludeInfo(includedScript);
	with (this.global){eval(includedJS)};
}
__recoveryFn = null;
Sahi.prototype._setRecovery = function (recoveryScript, forceAtEnd){
	__recoveryFn = recoveryScript;
	ScriptRunner.setRecoveryScript("if (__recoveryFn) __recoveryFn();");
}
Sahi.prototype._removeRecovery = function (){
	__recoveryFn = null;
}
Sahi.prototype._readFile = function (filePath) {
	filePath = this._resolvePath(filePath);
    return "" + Packages.net.sf.sahi.util.Utils.readFileAsString(filePath);
};
Sahi.prototype._copyFile = function (srcFilePath, destFilePath) {
	var absoluteSrc = this._resolvePath(srcFilePath);
	var absoluteDest = this._resolvePath(destFilePath);
	net.sf.sahi.util.FileUtils.copyFile(absoluteSrc, absoluteDest);
};

Sahi.prototype._readLayoutFile = function (layoutFile) {
	//this.print(this._readFile(layoutFile));
	var $fileContents = this._readFile(layoutFile);
	$fileContents = Packages.net.sf.sahi.playback.SahiScript.modifyFunctionNames($fileContents);
	var $lines = $fileContents.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split("\n");
	var s = "[";
	for (var $i=0; $i<$lines.length; $i++){
	  s += "[" + $lines[$i] + "],\n";
	}
	s += "]";
	return eval(s);
};

Sahi.prototype._readURL = function (url) {
    return "" + Packages.net.sf.sahi.util.Utils.getString(net.sf.sahi.util.Utils.readURL(url)); 
};
Sahi.prototype.handleJSErrors = function() {
	var errors = ScriptRunner.getSession().getObject("sahi_jsErrors");
	if (errors == null || errors.size() == 0) 
		return true;
	errors = errors.toString();
	ScriptRunner.getSession().setObject("sahi_jsErrors", null);
	return this.callOnJSError(errors);
}
Object.defineProperties(Sahi.prototype, {
    "SKIP_SCREENSHOTS": { 
    	get: function () { return this.___skipScreenShot},
		set: function (isEnable) {  this.___skipScreenShot = isEnable; ScriptRunner.getSession().setIsSkipScreenShot(isEnable); }
    },
    "SKIP_ASSERT_SNAPSHOTS": { 
    	get: function () { return this.___skipAssertSnapShot},
		set: function (isEnable) {  this.___skipAssertSnapShot = isEnable; ScriptRunner.getSession().setIsSkipAssertSnapShot(isEnable); }
    }
});
/* snapshot start */
Sahi.prototype._takeScreenShot = function(fileSysPath, noLog, props) {
	if (_sahi.SKIP_SCREENSHOTS) return;
	var format;
	var resizePercentage;
	if(props && props.format){
		format = props.format;
	} else{
		format = "" + net.sf.sahi.config.Configuration.getTakeSnapshotImageFormat();
	}
	if(props && props.resizePercentage){
		resizePercentage = props.resizePercentage;
	} else{
		resizePercentage = net.sf.sahi.config.Configuration.getTakeSnapshotImageResizePercentage();
	}
	if (!noLog)	nolog = false;
	if (!fileSysPath) fileSysPath = null;
	var stepId = ""+ScriptRunner.getCounter();
	var filePath;
	if (this.isPhantomJS()) {
		this.scheduleNoLog("_sahi.triggerPhantom("+ this.quoted("___sahi___format___" + format) +")");
		filePath = ScriptRunner.takeSnapShot(stepId, format, resizePercentage, true, true);
	} else {
		filePath = ScriptRunner.takeSnapShot(stepId, format, resizePercentage, false);
	}

	if(fileSysPath != null){
		net.sf.sahi.util.FileUtils.copyFile(filePath, fileSysPath);
	}
	if(!noLog){
		var fileName = new java.io.File(filePath).getName();
		ScriptRunner.getReport().setScreenShot(stepId, fileName);
	}
	else{
		net.sf.sahi.util.Utils.deleteFile(filePath);
	}
}
Sahi.prototype._takeSnapShots = function(toggle, directory) {
	if (_sahi.SKIP_SCREENSHOTS) return;
	if(!directory)
		directory = null;
	ScriptRunner.getSession().setScreenCaptureWithFilePath(toggle, directory);
}
Sahi.prototype._takeScreenShots = Sahi.prototype._takeSnapShots;
Sahi.prototype._takeSnapShot = Sahi.prototype._takeScreenShot;
/* snapshot end */
Sahi.prototype.xfocusWindow = function (newTitle) {
	// do not add any waits in this function.
	// IE will freeze and not come into focus.
	if (Packages.net.sf.sahi.util.Utils.isWindows()) {
		var cmd = "cmd /C " + ("" + net.sf.sahi.config.Configuration.getAbsolutePath("tools/windowfocus.exe")).replace('/', '\\') + " \"" + newTitle + "\"";
		this.print(cmd);
		this._execute(cmd, true);
	}
};
Sahi.prototype._focusWindow = function () {
	this._windowAction("focus");
};
Sahi.prototype._windowAction = function(s, width, height){
	if(Packages.net.sf.sahi.util.Utils.isWindows()) {
		var oldTitle = _sahi._title() || "";
		var newTitle = ""+(new Date()).getTime();
		this.scheduleNoLog("window.document.title = " + this.quoted(newTitle));
		this.wait(net.sf.sahi.config.Configuration.getWindowActionWaitTime("window_action_api.wait_after_unique_title_set"));
		// if (Packages.net.sf.sahi.util.Utils.isWindows()) {
			if(width || height){
				var cmd = "cmd /C " + ("" + net.sf.sahi.config.Configuration.getAbsolutePath("tools/winAction.exe")).replace('/', '\\') + " " + this.quoted(s)+" "+ this.quoted(newTitle) + " " + width +  " " + height;
			}
			else
				var cmd = "cmd /C " + ("" + net.sf.sahi.config.Configuration.getAbsolutePath("tools/winAction.exe")).replace('/', '\\') + " " + this.quoted(s)+" "+ this.quoted(newTitle);
			
		// }
		/* else 	if(Packages.net.sf.sahi.util.Utils.isMac()) {
			
			if(width || height)
				var cmd = "osascript  " + net.sf.sahi.config.Configuration.getAbsolutePath("tools/windowActionMac.scpt") +" "+ s +" "+this.quoted(newTitle)+" "+ width + " " + height;
			else
				var cmd = "osascript  " + net.sf.sahi.config.Configuration.getAbsolutePath("tools/windowActionMac.scpt") +" "+ s +" "+this.quoted(newTitle);
		
		} */
		this._execute(cmd, true);
		
		this.wait(net.sf.sahi.config.Configuration.getWindowActionWaitTime("window_action_api.wait_before_title_revert"));
		var prefix = "";
		if (this.windowContext) prefix = "_sahi._popup(" + this.quoted(newTitle) + ").";
		this.scheduleNoLog(prefix + "document.title = " + this.quoted(oldTitle));
		this.wait(net.sf.sahi.config.Configuration.getWindowActionWaitTime("window_action_api.wait_after_unique_title_revert"));
	}
}
Sahi.prototype._getWindows = function(activePeriod){
	if(!activePeriod){
		activePeriod = -1;
	}
	var json = ScriptRunner.getSession().getWindowsToJSON(activePeriod);
	var obj = eval("(" + json + ")");
	return obj; 
};
Sahi.prototype._windowExists = function(identifier, activePeriod){
	var windows = this._getWindows(activePeriod);
	for(var i=0; i<windows.length; i++){
		var window = windows[i];
		var windowName = window.windowName;
		var windowTitle = window.windowTitle;
		var windowURL = window.windowURL;
		var sahiWinId = window.sahiWinId;
		var isAccessorIgnoreCase = ScriptRunner.getSession().isAccessorIgnoreCase();
		var __SAHI_PROPS_DELIMITER__ = "__SAHI_PROPS_DELIMITER__";
		var s = windowName + __SAHI_PROPS_DELIMITER__ + windowTitle + __SAHI_PROPS_DELIMITER__ + windowURL + __SAHI_PROPS_DELIMITER__ + sahiWinId;
		var b = "" + Packages.net.sf.sahi.util.Utils.isSameWindow(s, identifier, isAccessorIgnoreCase) == "true";
		if(b) return true;
	}
	return false;
};
Sahi.prototype._getRecentWindow = function(){
	var json = ScriptRunner.getSession().getWindowsToJSON(-1);
	var obj = eval("(" + json + ")");
	return obj[obj.length-1]; 
};
Sahi.prototype._startDocumentation = function(filepath, overwrite, refFile){
	overwrite = (overwrite == true);
	filepath = this._resolvePath(filepath);
	var session = ScriptRunner.getSession();
	session.setPlaybackDocFilepath(filepath);
	session.setPlaybackDoc(true);
	session.setOverwriteDoc(overwrite);
	if(refFile){
		refFile = this._resolvePath(refFile);
		var refFileContent = this._readFile(refFile);
		session.setPlaybackDocRefFileContent(refFileContent);
	}
};
Sahi.prototype._stopDocumentation = function(){
	var session = ScriptRunner.getSession();
	session.setPlaybackDoc(false);
	session.setPlaybackDocRunning(false);
	ScriptRunner.changeDocumentByReferenceFile();
};
Sahi.prototype._stop = function(){
	ScriptRunner.stop();
};
Sahi.prototype._pause = function(){
	this.scheduleNoLog("_sahi.setServerVar('sahi_paused', 1);");
}
Sahi.prototype._log = function (s, type){
	ScriptRunner.log(s, "", type);
};
Sahi.prototype._lock = function (label, timeout) {
	if (!timeout) return Packages.net.sf.sahi.util.Lock.getInstance().lock(label);
	else return Packages.net.sf.sahi.util.Lock.getInstance().lock(label, timeout);
};
Sahi.prototype._unlock = function (key) {
	Packages.net.sf.sahi.util.Lock.getInstance().unlock(key);
};
Sahi.prototype._lockWindow = function (timeout) {
	this.windowLockKey = this._lock(Packages.net.sf.sahi.util.Lock.WINDOW_LOCK, timeout);
};
Sahi.prototype._unlockWindow = function () {
	this._unlock(this.windowLockKey);
};
/*
Sahi.prototype._writeFile = function (str, filePath, overwrite) {
	filePath = this._resolvePath(filePath);
	overwrite = (overwrite == true);
    return "" + Packages.net.sf.sahi.util.Utils.writeFile(str, filePath, overwrite);
};
*/
Sahi.prototype._writeFile = function (str, filePath, overwrite, encoding) {
	filePath = this._resolvePath(filePath);
	overwrite = (overwrite == true);
	if (!encoding) encoding = "UTF-8";
    return "" + Packages.net.sf.sahi.util.Utils.writeFile(str, filePath, overwrite, encoding);
};
Sahi.prototype._writeToFile = Sahi.prototype._writeFile;
Sahi.prototype._deleteFile = function (filePath) {
	var absolutePath = this._resolvePath(filePath);
	return "" + Packages.net.sf.sahi.util.Utils.deleteFile(absolutePath) == "true";
};
Sahi.prototype._renameFile = function (oldPath, newPath) {
	var absoluteOldPath = this._resolvePath(oldPath);
	var absoluteNewPath = this._resolvePath(newPath);
	return "" + Packages.net.sf.sahi.util.FileUtils.renameFile(absoluteOldPath, absoluteNewPath) == "true";
};
Sahi.prototype._scriptStatus = function(){
	return ScriptRunner.hasErrors() ? "FAILURE" : "SUCCESS";
}
Sahi.prototype._stopOnError = function(){
	this.stopOnError = true;
    ScriptRunner.setStopOnError(true);
};
Sahi.prototype._continueOnError = function(){
	this.stopOnError = false;
    ScriptRunner.setStopOnError(false);
};
Sahi.prototype._setSpeed = function(ms){
	net.sf.sahi.config.Configuration.setTimeBetweenSteps(ms);
}
Sahi.prototype.makeAssociative = function(array2d){
	array2d.set = function(rowHeader, colHeader, newValue){
        var r = null;
        if ((typeof rowHeader) == "number"){
        	if (rowHeader < 0 || rowHeader >= this.length)
        		return null;
        	r = this[rowHeader];
        }
        else{
            for(var i=0; i<this.length; i++){
            	if (rowHeader == this[i][0]){
                    r = this[i];
                }
            }
        }
        if (!r) {return null};
        if (!r[colHeader]) {return null};
        for (var i=0; i<r.length ;i++){
        	var colIndex = 0;
        	var isAssociativeIndex = true;
			for (var j in this[i]){
				if (j != colIndex && isAssociativeIndex){
					isAssociativeIndex = false;
					colIndex=0;
				}
				if ((typeof colHeader) == "number"){	
					if (r[colHeader] == r[colIndex]){
						r[colHeader] = newValue;
						r[j] = newValue;
					}
				}
				else{ 
					if (r[colHeader] == r[colIndex] && j == colHeader){
						r[colHeader] = newValue;
						r[colIndex] = newValue;
					}
				}
				colIndex++;
			}
		}           
    }
	array2d.get = function(rowHeader, colHeader){
        var r = null;
        if ((typeof rowHeader) == "number"){
            r = this[rowHeader];			
        }else{
            for (var i=0; i<this.length; i++){
                if (rowHeader == this[i][0]){
                    r = this[i];
                }
            }
        }
        if (!r) {return null};
        if ((typeof colHeader) == "number"){
            return r[colHeader];
        }else{
			if (r[colHeader]) return r[colHeader];
			for (var j=0; j<r.length; j++){
				   if (colHeader == this[0][j]){
					return r[j];
				}
			}
        }       
    }
    array2d.sortAscendingBy = function(colHeader, includeHeader){
    	return this.sortBy(colHeader, false, includeHeader);
    }
    array2d.sortDescendingBy = function(colHeader){
    	return this.sortBy(colHeader, true, includeHeader);
    }    
    array2d.sortBy = function(colHeader, isDescending, includeHeader){
        var header = new Array();
        if (!includeHeader) 
            header = this.slice(0, 1);        
        var toSort = includeHeader ? this.slice(0) : this.slice(1);
        var colIndex = null;
        if ((typeof colHeader) == "number"){
            colIndex = colHeader;
        }else{
            for (var j=0; j<this[0].length; j++){
                   if (colHeader == this[0][j]){
                    colIndex = j;
                    break;
                }
            }            
        } 
        toSort.sort(function(a, b){
            if (a[colIndex] == b[colIndex]) return 0;
			if (isDescending) return b[colIndex] < a[colIndex] ? -1 : 1;
			else return a[colIndex] < b[colIndex] ? -1 : 1;
        });
        return _sahi.makeAssociative(header.concat(toSort));
    }
    return array2d;
};
Sahi.prototype.associativeArray = function(array2d, includeHeader){
	var header = array2d.slice(0,1)[0];
	if(!includeHeader) array2d.splice(0,1);
	for(var i = 0; i < array2d.length; i++){
		for(var j=0; j < header.length; j++){
			array2d[i][header[j]] = array2d[i][j];
		}
	}
	return this.makeAssociative(array2d);
};
Sahi.prototype._getDB = function (driver, jdbcurl, username, password) {
    return new Sahi.dB(driver, jdbcurl, username, password);
};
Sahi.dB = function (driver, jdbcurl, username, password) {
    this.driver = driver;
    this.jdbcurl = jdbcurl;
	if (username == null || typeof username == "string") {
		this.usingProps = false;
	    this.username = username;
	    this.password = password;		
	} else {
		this.usingProps = true;
		this.props = username;
	}
	this.getDBClient = function() {
        if (this.usingProps) {
        	return new Packages.net.sf.sahi.plugin.DBClient(this.driver, this.jdbcurl, this.props);
        } else {
        	return new Packages.net.sf.sahi.plugin.DBClient(this.driver, this.jdbcurl, this.username, this.password);
        }		
	}
    this.select = function (sql, includeHeader) {
    	var dbclient = this.getDBClient();
    	var json = dbclient.select(sql);        	
        if (json.indexOf("exception") == 0) {
        	throw new SahiException(json);
        }
        try{
	        var $evaled = eval('('+ json +')')['result'];
	        return _sahi.associativeArray($evaled, includeHeader);
        }catch(e){
        	throw new SahiException(json);
        }
    };
    this.selectWithoutHeader = this.select;
    this.selectWithHeader = function (sql) {
        return this.select(sql, true);
    };
    this.update = function (sql) {
    	var dbclient = this.getDBClient();
    	var error = dbclient.execute(sql);
        if (error != null) {
        	throw new SahiException(error);
        }
    };
};
Sahi.prototype._getQC = function (serverName, serverPort, domainName, projectName, userName, password) {
	return new Sahi.QC(serverName, serverPort, domainName, projectName, userName, password);
};
Sahi.QC = function (serverName, serverPort, domainName, projectName, userName, password) {
    this.serverName = serverName;
    this.serverPort = serverPort;
    this.domainName = domainName;
    this.projectName = projectName;
    this.userName = userName;
    this.password = password;
    this.log = function (testPlanName, testPlanFolderName, testSetName, scriptStatus, scriptTime) {
    	var qcclient = new Packages.net.sf.sahi.plugin.QCClient();
    	qcclient.logToQC(ScriptRunner, this.serverName, this.serverPort, this.domainName, this.projectName, this.userName, this.password, 
    					 testPlanName, testPlanFolderName, testSetName, scriptStatus, "" + scriptTime);
        /*var qs = "serverName=" + this.serverName + "&serverPort=" + this.serverPort + "&domainName=" + this.domainName + "&projectName=" + this.projectName + "&userName="
         + "&password=" + this.password + "&testPlanName=" + testPlanName + "&testPlanFolderName=" + testPlanFolderName + "&testSetName=" + testSetName;
        return eval(sahi._callServer("net.sf.sahi.plugin.QCClient_logToQC", qs));*/
    };
};
Sahi.prototype.end = function(){
	ScriptRunner.stop();
    //this.print('script ended.');
};
Sahi.prototype._getGlobal = function(key){
	var suite = ScriptRunner.getSession().getSuite();
	var val = (suite == null) ? ScriptRunner.getSession().getVariable(key) : suite.getVariable(key);
	return eval('('+val+')');
}
Sahi.prototype.getServerVar = function(key){
    var val = ScriptRunner.getVariable(key);
    //this.print(val);
    return eval('('+val+')');
};
Sahi.prototype._random = function (n) {
    return Math.floor(Math.random() * (n + 1));
};
Sahi.prototype._scriptName = function(){
	var $scriptName = ""+ScriptRunner.getScriptName();
	if ($scriptName == "excelfw.sah") {
		try {
			$scriptName = "" + ScriptRunner.getReport().getScriptName();
		}catch(e){}
	}
    return $scriptName;
};
Sahi.prototype._logException = function(e){
	this.logExceptionCommon(e, "");
};
Sahi.prototype._logExceptionAsFailure = function(e){
	this.logExceptionCommon(e, "FAILURE");
};
Sahi.prototype.logExceptionAsError = function (e){
	this.logExceptionCommon(e, "ERROR");
};
Sahi.prototype.logExceptionCommon = function(e, failType){
    if (e instanceof SahiException)
          ScriptRunner.logException(e.message, e.debugInfo, failType);
    else {
		var msg = e.message ? e.message : e;
    	if (e.lineNumber != null && ("" + parseInt(e.lineNumber)) != "NaN" && e.fileName.indexOf("excelfw")==-1){
    		ScriptRunner.logExceptionWithLineNumber(e.fileName, e.message, e.lineNumber, failType);
    	}else {
    		ScriptRunner.logException(msg, null, failType);
    	}
    }
};

_sahi = new Sahi();

var document = new Stub("document");
var window = new Stub("window");

SahiException = function(message, debugInfo){
	this.message = message;
	this.debugInfo = debugInfo;
	this.toString = function(){return this.message;};
	this.isBrowserNotResponding = false;
};
Sahi.prototype._scriptPath = function(){
    return "" + ScriptRunner.getScript().getFilePath();
};
Sahi.prototype._maskLogs = function(s){
	this._log("maskLogs start: " + s, "CUSTOM2");
    return ScriptRunner.getReport().setMaskLogs(true);
};
Sahi.prototype._unmaskLogs = function(s){
    ScriptRunner.getReport().setMaskLogs(false);
    this._log("maskLogs end: " + s, "CUSTOM2");
};
Sahi.prototype._scriptStartTime = function(){
	var currentTime = ScriptRunner.getReport().getStartTime();
	var date = new Date(currentTime);
	return date;
};
Date.prototype.getMonth2 = function(){
	return this.getMonth() + 1;
};
Sahi.prototype._sessionInfo = function(){
    var info = eval("(" + ScriptRunner.getSession().getInfoJSON() + ")");
    info.threadNumber = ScriptRunner.getThreadNo();
    info.scriptPath = this._scriptPath();
    return info;
};
Sahi.prototype._suiteInfo = function(){
	var suiteInfo = ScriptRunner.getSession().getSuiteInfo();
	if (suiteInfo == null) return {};
    var info = eval("(" + suiteInfo.toJSON() + ")");
    return info;
};

Sahi.prototype._readCSVFile = function(filePath, wordSeparator, ignoreEmptyRows){
	if (!wordSeparator) wordSeparator = Packages.net.sf.sahi.config.Configuration.getCSVWordSeparator();
	if (!ignoreEmptyRows) ignoreEmptyRows = false;
	filePath = this._resolvePath(filePath);
	var dataOut = [];
	var data = Packages.net.sf.sahi.util.CSV.readCSVAs2DList(filePath, wordSeparator, ignoreEmptyRows);
//	this.print(data);
	for (var i=0; i<data.size(); i++) {
		var row = data.get(i);
		var rowOut = [];
		for (var j=0; j<row.size(); j++) {
			rowOut.push(row.get(j));
		}		
		dataOut.push(rowOut);
	}
	return dataOut;
//	var contents = this._readFile(filePath);
//	var csv = new  Packages.net.sf.sahi.util.CSV(wordSeparator, true);
//	csv.load(contents);
//	var data = eval("(" + csv.toJSON() + ")");
//    var lines = contents.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split("\n");
//    var data = []; // new Array();
//    for (var i=0; i<lines.length; i++){
//    	if (lines[i].replace(/^\s*|\s*$/g, '') == "") continue;
//        var words = this.splitUnQuoted(lines[i], wordSeparator); //lines[i].split(",");
//        for (var j=0; j<words.length; j++){
//        	var w = words[j];
//        	w = w.replace(/^\s*|\s*$/g, '');
//        	if (w.match(/^".*"$/)){
//        		//words[j] = eval(w);
//        		words[j] = w.substring(1, w.length-1);
//        	}
//        }
//        data[data.length] = words;
//    }
    return data;
};
Sahi.prototype.splitUnQuoted = function(s, wordSeparator){
	var words = [];
	var prev = ' ';
	var startIx = 0;
	var quoted = false;
	for (var i=0; i<s.length; i++){
		var c = s.charAt(i);
		if (c == '"' && prev != '\\'){
			quoted = !quoted;
		} else if (c == wordSeparator){
			if (!quoted) {
				words[words.length] = s.substring(startIx, i);
				startIx = i + 1;
			}
		}
		prev = c;
	}
	if (startIx <= s.length) words[words.length] = s.substring(startIx);
	return words;
}
Sahi.prototype._resolvePath = function(path){
	if (this.currentScriptPath == null) this.currentScriptPath = this._scriptPath(); 
	var thisPath = this.currentScriptPath.replace(/\\/g, "/");
	return "" + net.sf.sahi.util.Utils.concatPaths(thisPath, path);
}
Sahi.CSV_NEWLINE = "\r\n";
Sahi.prototype._writeCSVFile = function(array2d, filePath, overwrite, separator) {
	filePath = this._resolvePath(filePath);
	if (!separator) separator = ",";
	var s = [];
	for (var i=0; i < array2d.length; i++) {
		var row = array2d[i];
		for (var j=0; j < row.length; j++) {
			cell = row[j] ? "" + row[j] : "";
			s[s.length] = this.escapeForCSV(cell);
			if (j != row.length - 1) s[s.length] = separator;
		}
		if (i < array2d.length - 1)
			s[s.length] = Sahi.CSV_NEWLINE;
	}
	var str = s.join("");
	if(!overwrite) {
		str += "\n";
	}
	var existingStr = "";
	if(this.doesFileExist(filePath)){
		existingStr = this._readFile(filePath);
	}
	if(!overwrite){
		var newLineCheck = existingStr.charAt(existingStr.length - 1);
		if(newLineCheck != '\n' && existingStr.length != 0) str = "\n" + str;
	}
	this._writeFile(str, filePath, overwrite);
};
Sahi.prototype._getExcel = function(fileName,sheetName){
	fileName = this._resolvePath(fileName);
	return new Packages.net.sf.sahi.util.ExcelPOI(fileName,sheetName);
};
Sahi.prototype.doesFileExist = function(filePath){
	var file = new java.io.File(filePath);
	if(file.exists()) return true;
	return false;
};
Sahi.prototype._readExcelFile = function(fileName, sheetName, includeHeader){
	fileName = this._resolvePath(fileName);
	if (!sheetName) sheetName = "Sheet1";
	var poi=new Packages.net.sf.sahi.util.ExcelPOI(fileName,sheetName);
	var javaAr = poi.getData(true);
	return this.associativeArray(this.convertJavaArrayToJS(javaAr), includeHeader);
};
Sahi.prototype.convertJavaArrayToJS = function(javaAr){
	var jsAr = [];
	for (var i=0; i<javaAr.length; i++){
		var row = javaAr[i];
		jsAr[i] = [];
		for (var j=0; j<row.length; j++) {
			jsAr[i][j] = row[j];
		}
	}
	return jsAr;
}
Sahi.prototype._userDataDir = function(){
	return "" + net.sf.sahi.config.Configuration.getUserDataDir();
}
Sahi.prototype._userDataPath = function(relPath){
	return "" +  net.sf.sahi.config.Configuration.getAbsoluteUserPath(relPath);
}
Sahi.prototype._isDataPassed = function(){
	return (typeof $isDataPassed != "undefined");
}
Sahi.prototype._collect = function (apiType, id, inEl) {
	var count = this._count.apply(this, arguments);
	var els = [];
	for (var j=0; j<count; j++){
		if (typeof id == "object" && !(id instanceof RegExp)) {
			var id2 = id;
			id2.sahiIndex = j;
			var s = this.toJSON(id2);
		} else {
			var s = '"' + id + "[" + j + "]\"";
		}
		for (var i=2; i<arguments.length; i++){
			s += ", ";
			s += s_v(arguments[i]);
		}
		els.push(new Stub("_sahi." + apiType + "(" + s + ")"));		
	}
	return els;
}
Sahi.prototype._sendHTMLResponseAfterFileDownload = function(b){
	ScriptRunner.getSession().setSendHTMLResponseAfterFileDownload(b);
}
/*close open browser start*/
Sahi.prototype._closeBrowser = function() {
	ScriptRunner.closeBrowser();
}
Sahi.prototype._openBrowser = function() {
	ScriptRunner.reopenBrowser();
}
Sahi.prototype._launchNewBrowser = function(url) {
	try {
		if(url == null){
			return ScriptRunner.launchNewBrowser();
		} else { 
			return ScriptRunner.launchNewBrowser(url);
		}
	} catch (e) {
		throw "_launchNewBrowser failed: " + e.message;
	}
}
Sahi.prototype._selectBrowser = function(sessionId) {
	if(sessionId == null){
		return ScriptRunner.selectBrowser();
	} else {
		return ScriptRunner.selectBrowser(sessionId);
	}
}
Sahi.prototype._compareImages = function(f1, f2, differenceThreshold){
	if (_sahi.SKIP_ASSERT_SNAPSHOTS) return;
	
	if (differenceThreshold == null) {
		differenceThreshold = this.DEFAULT_IMAGE_COMPARISON_THRESHOLD;
	}
	
	f1 = this._resolvePath(f1);
	f2 = this._resolvePath(f2);
	var score = this.compareImages(f1, f2);
	if (isNaN(score) || differenceThreshold < score) {
		return false;
	}
	return true;
}
Sahi.prototype._imageCompareScoreExtractorFn = function(s){
	var ar = s.split(" ");
	return parseFloat(ar[ar.length-1]);	
}
/*close open browser end*/
/*snapshot start*/
Sahi.prototype.compareImages = function(f1, f2){
	try {
		//f1 = "" + net.sf.sahi.config.Configuration.appendLogsRoot("images/" + f1);
		this.print(f1);
		this.print(f2);
		var res = "" + Packages.inco.sahi.util.ImageUtils.compareImages(f1, f2);
	}catch(e){
		this.print(e);
	}
	this.print(res);
	return this._imageCompareScoreExtractorFn(res);
	// Do any code that may be needed for selecting size
}
/*snapshot end*/
/* Header manipulation start */
Sahi.prototype._setHttpHeader = function(k, v){
	ScriptRunner.getSession().setHTTPHeader(k, v);
}
Sahi.prototype._addHttpHeader = function(k, v){
	ScriptRunner.getSession().addHTTPHeader(k, v);
}
Sahi.prototype._removeHttpHeader = function(k){
	ScriptRunner.getSession().removeHTTPHeader(k);
}
Sahi.prototype._resetHttpHeader = function(k){
	ScriptRunner.getSession().resetHTTPHeader(k);
}

/* Header manipulation end */


/* Unit test style start */
_sahi.global = this; 

Sahi.prototype.showFunctions = function(){
	var done = [];
	for(var [$n, $v] in Iterator(_sahi.global)){
		if (typeof $v == 'function' && $n.indexOf("Sahi") == -1 && $n != "s_v" && $n != "Stub" && $n != "stubBinder" && $n != "indexBinder") {
			_sahi.global[$n] = this.getWrapped($n, $v);
		}
	}	
}

Sahi.prototype.getWrapped = function($n, $v){
	return function () {
		//_log("Enter " + $n, "custom2");
		$v(arguments);
		//_log("Exit " + $n, "custom2");
	}
}

Sahi.prototype._runUnitTests = function(testAr){
	if (!testAr){
		testAr = [];
		for(var [$n, v] in Iterator(_sahi.global)){
			if (typeof v == 'function' && $n.indexOf("test") == 0 && $n.indexOf("_sahiorig") == -1) {
				testAr[testAr.length] = $n;
			}
		}
	}
	var abortNoTeardown = false;
	for(var i=0; i<testAr.length; i++){
		var fnName = testAr[i];
		var $status = "success";
		var $testcase = this._testcase(fnName, fnName).start();
		if (abortNoTeardown) {
			this._fail("Testcase aborted due to browser not responding.");
			$testcase.end();
		}
		if (typeof setUp != "undefined") setUp();
		try {
			eval(testAr[i])();
		} catch (e) {
			$status = "failure";
			if (e.isBrowserNotResponding) abortNoTeardown = true; 
		}
		finally {
			if (abortNoTeardown) {
				$testcase.end();
			} else {
				if (typeof tearDown != "undefined") tearDown();
				$testcase.end();
			}
		}
	}
}

Sahi.prototype.clubFunctionsLogging = function(scope, prefix){
	var fnAr = [];
	for(var [n, v] in Iterator(scope)){
		if (typeof v == 'function') {
			fnAr.push(n);
		}
	}
	for(var i=0; i<fnAr.length; i++){
		var fnName = fnAr[i];
		if (fnName.indexOf("Sahi") == 0 || fnName.indexOf("ignoregroup_") == 0 || fnName == "indexBinder" 
			|| fnName == "stubBinder" || fnName == "Stub" || fnName == "SahiHashMap" || fnName == "s_v" 
			|| fnName.indexOf("_sahiorig") != -1) continue;
		if (!scope[fnName]._sahiprocessed) {
			scope[fnName+"_sahiorig"]=scope[fnName];
			scope[fnName] = this.getWrappedFunctionWithLogging(scope, fnName, prefix);
			scope[fnName]._sahiprocessed = true; 
		}
	}
}
/*
 * http://stackoverflow.com/questions/367768/how-to-detect-if-a-function-is-called-as-constructor
 * http://stackoverflow.com/questions/3871731/dynamic-object-construction-in-javascript?lq=1
 */
Sahi.prototype.getWrappedFunctionWithLogging = function (scope, fnName, prefix){
	return function (){
		if (this instanceof arguments.callee) {
			var origfn = scope[fnName+"_sahiorig"];
	        var obj = Object.create(origfn.prototype);
	        obj.constructor = origfn;
	        var newobj = origfn.apply(obj, arguments);
	        if (typeof newobj === "object") {
	            obj = newobj;
	        }
	    	if (net.sf.sahi.config.Configuration.isReportCodeFoldingEnabled()) {
	    		_sahi.clubFunctionsLogging(obj, fnName); // fnName is constructor name
	    	}
	        return obj;
		} else {
			var prefix1 = prefix ? (prefix + '.') : '';
			var $testcase = _sahi.grouper('+', prefix1 + fnName + '(' + _sahi.formArgString.apply(_sahi, arguments) + ')').start();
			try {
				return scope[fnName+"_sahiorig"].apply(scope, arguments);
			} finally {$testcase.end();}
		}
	}
	
} 
Sahi.prototype.fnStart = function(fnName, o, args) {
	if ((fnName.indexOf("SahiFrameWork")==0)  || (o && args && o instanceof args.callee)) return null; 
	return _sahi.grouper('+', fnName + '(' + _sahi.formArgString.apply(_sahi, args) + ')').start();
}
Sahi.prototype.fnEnd = function(t) {
	if (t) t.end();
}
Sahi.prototype.formArgString = function(){
	var s = "";
	for (var i=0; i<arguments.length; i++){
		if (arguments[i] == null) {
			s += 'null';
		} else {
			var v = arguments[i];
			var t = typeof v;
			if (t == "number" || t == "boolean") {
				s += v;
			} else if (t == "string") {
				if (v.length > 400) v = v.substring(0, 400) + "...";
				s += s_v(v);
			} else {
				s += "[object]";
			}
		}
		if (i != arguments.length-1) s += ", ";
	}			
	return s;
}
Sahi.prototype.trim = function (s) {
	return s.replace(/^\s*|\s*$/g, '');
};

Sahi.prototype.trim1DArray = function (s) {
	if(!(s instanceof Array)) return s;
	var arrStartIx = -1;
	var arrEndIx = s.length;
	for(var i=0; i<s.length; i++){
		if(s[i] == null || s[i] == ""){
			arrStartIx = i;
		}
		else{
			break;
		}
	}
	for(var j=s.length; j>0; j--){
		if(s[j-1] == null || s[j-1] == ""){
			arrEndIx = j-1;
		}
		else{
			break;
		}
	}
	var diff = Math.abs((arrStartIx + 1) - arrEndIx);
	return s.splice(arrStartIx + 1, diff);
};
Sahi.prototype.arrayNullOrBlank = function (s) {
	if(!(s instanceof Array)) return true;
	for(var i=0; i<s.length; i++){
		if(s[i] != null && s[i] != "" ){
			return false;
		}
	}
	return true;
}
Sahi.prototype.trim2DArray = function (s) {
	var arrStartIx = -1;
	var arrEndIx = s.length;
	for(var i=0; i<s.length; i++){
		if(this.arrayNullOrBlank(s[i])){
			arrStartIx = i;
		}
		else{
			break;
		}
	}
	for(var j=s.length; j>0; j--){
		if(this.arrayNullOrBlank(s[j-1])){
			arrEndIx = j-1;
		}
		else{
			break;
		}
	}
	var diff = Math.abs((arrStartIx + 1) - arrEndIx);
	return s.splice(arrStartIx + 1, diff);
};
Sahi.prototype._trim = function(s){
	if ((typeof s) == "string"){
		return this.trim(s);
	}
	else if (s instanceof Array) {
		if (s[0] instanceof Array){
			return this.trim2DArray(s);
		}
		else{
			return this.trim1DArray(s);
		}
	}	
};
Sahi.prototype._fail = function(message){
	this._log("<!--SAHI_TESTCASE_FAIL_MARKER--><!--_FAIL-->", "RAW");
	throw new SahiException("Fail" + (message ? (": " + message) : ""), "FORCED_FAIL");
}
Sahi.prototype._stackTrace = function(){
	return this.getSahiScriptStackTrace();
}
/* Unit test style end */ 
/* Data driven start */
Sahi.prototype._dataDrive = function(func, array2D, preFn, postFn){
	for (var i=0; i<array2D.length; i++){
		var args = array2D[i];
		if (preFn) preFn();
		try{
			func.apply(_sahi.global, args);
		}catch(e){
	        this.logExceptionAsError(e);
	    }
		finally {
			if (postFn) postFn();
		}
	}	
}
/* Data driven end */

/* RegExp toString Fix start */
if (new RegExp("/").toString() == "///"){
	RegExp.prototype.toString = function(){
		var s = this.source;
		if (s.indexOf("/") != -1 && s.indexOf("\\/") == -1){
			s = s.replace(/\//g, '\\/');
		}
		return "/" + s + "/" + (this.global?'g':'') + (this.ignoreCase?'i':'') + (this.multiline?'m':'');
	}
}
/* RegExp toString Fix end */

/* fetch APIs start */
Sahi.prototype._fetch = function(stub){
	var d = java.lang.System.currentTimeMillis();
	var key = "___lastValue___" + d.toString(); 
	this.scheduleNoLog("_sahi.setServerVarForFetch('" +key+ "', " + stub + ");");
	return this.getServerVar(key);	
};
Sahi.prototype.makeFetchAPIs = function(){
	var apis = ["_getValue", "_getAttribute", "_containsText", "_getTableContents","_getScreenSize",
	            "_containsHTML", "_getText", "_getOptions", "_getCellText", "_getSelectedText", 
	            "_lastAlert", "_lastPrompt", "_lastConfirm", "_style", "_cookie", 
	            "_position", "_rteHTML", "_rteText", "_isVisible", 
	            "_contains", "_title", "_exists", "_isIE", "_isIE6", "_isIE7", "_isIE8", "_isIE9", "_isIE10", "_isIE11", "_isIE11Plus", "_isFF", "_isFF3", "_isFF4", "_isChrome", "_isSafari", "_isOpera",
	            "_lastDownloadedFileName", "_prompt", "_confirm", "_count", "_extract", "_getSelectionText", "_collectAttributes"];
	for (var i=0; i<apis.length; i++){
		var api = apis[i];
		Sahi.prototype[api] = this.fetchFn(api);
	}
}
Sahi.prototype.fetchFn = function (name){
	return function(){
		var fnName = name;
		var s = "";
		for (var i=0; i<arguments.length; i++){
			s += s_v(arguments[i]);
			if (i != arguments.length-1) s += ", ";
		}			
		return this._fetch("_sahi." + fnName + "(" + s + ")");
	}
};
_sahi.makeFetchAPIs();
/* fetch APIs end */

/*selectWindow selectDomain start*/
Sahi.prototype._selectWindow = function(windowName){
	this.windowContext = windowName;
}
Sahi.prototype._selectDomain = function(domain){
	this.domainContext = domain;
}
/*selectWindow selectDomain end*/

/* callbacks start */
Sahi.prototype.callOnScriptEnd = function (){
	try{
		var rt = java.lang.Runtime.getRuntime();
//		_sahi._log("Total Memory in JVM (Xmx) is: " + rt.maxMemory()/(1024*1024) + " MB;<br/>" +
//				"Memory currently in use is: " + rt.totalMemory()/(1024*1024) + " MB;<br/>" +
//				"Memory increment during this test is: " + ((rt.totalMemory() - this.initialMemory)/(1024*1024)) + " MB", "CUSTOM2");
		if (typeof onScriptEnd == "function"){
			onScriptEnd();
		}
	} catch(e){
		this.logExceptionAsError(e);
	} finally {
		this.end();
	}
};
Sahi.prototype.callOnScriptError = function (e){
	if (typeof onScriptError != "function") return;
	this.inOnScriptErrorFn = true;
	try {
		return onScriptError(e);
	}catch(e){
		this.logExceptionAsError(e);
	}finally {
		this.inOnScriptErrorFn = false
	}
};
Sahi.prototype._isPhantomJS = Sahi.prototype.isPhantomJS; 
Sahi.prototype.isPhantomJS = function () {
	return /PhantomJS/.test(ScriptRunner.getSession().getUserAgent());
};
Sahi.prototype.callOnScriptFailure = function (e){
	if (typeof onScriptFailure != "function") return;
	this.inOnScriptFailureFn = true;
	try {
		return onScriptFailure(e);
	}catch(e){
		this.logExceptionAsError(e);
	}finally {
		this.inOnScriptFailureFn = false;
	}
};
Sahi.prototype.callOnJSError = function (e){
	try {
		if (typeof onJSError == "function") {
			return onJSError(e);
		} else {
			this._log(e, "custom1");
		}
	}catch(e){
		this.print(e);
	}
	return true;
};
/* callbacks end */
Sahi.prototype.getExtraInfo = function (){
	 return ScriptRunner.getSession().getSuiteInfo().extraInfo();
}
Sahi.prototype.getInitJS = function(){
	if(ScriptRunner.getSession() != null && ScriptRunner.getSession().getSuiteInfo() != null)
		return "" + ScriptRunner.getSession().getSuiteInfo().initJS();
}
/* TestCase Start */
Sahi.TestCase = function(id, msg){
	this.id = id;
	this.msg = msg;
	this.ecBef = 0;
	this.ecAft = 0;
	this.ended = false;
	this.status = "RUNNING";
} 
Sahi.TestCase.prototype.start = function(){
	var $s = "[" + this.id + "] " + this.msg;
	this.ecBef = ScriptRunner.errorCount();
	this.startTime = new Date();
	_sahi._log($s, this.isGroup ? "GROUP_START" : "TESTCASE_START");
	return this;
}
Sahi.TestCase.prototype.end = function(){
	this.ecAft = ScriptRunner.errorCount();
	this.endTime = new Date();
	this.ended = true;
	if (this.ecAft > this.ecBef) {
		this.status = "FAILURE";
		_sahi._log("<!--SAHI_TESTCASE_FAIL_MARKER--><!--TESTCASE_END-->", "RAW");
	} else {
		this.status = "SUCCESS"
	}
	try {
		// this works only for non distributed runs.
		var summary = ScriptRunner.getSession().getSuite().getTestCaseResultSummary();
		summary.update(this.id, this.status, "" + (this.endTime.getTime() - this.startTime.getTime()));
	}catch(e){}
	_sahi._log("", this.isGroup ? "GROUP_END" : "TESTCASE_END");
}
Sahi.TestCase.prototype.getStatus = function(){
	return this.status;
}
Sahi.prototype._testcase = function(id, msg){
	return new Sahi.TestCase(id, msg);
} 
Sahi.prototype.grouper = function(id, msg){
	var t = new Sahi.TestCase(id, msg);
	t.isGroup = true;
	return t;
} 
/* TestCase End */

//_sahi.print("initJS: " + _sahi.getInitJS());
if(_sahi.getInitJS() && _sahi.getInitJS() != "null"){
	eval(_sahi.getInitJS());	
}
/*
function onScriptError(e){
	_sahi.schedule("_sahi._focusWindow();", "");
	_sahi.schedule("_sahi._takeScreenShot();", "");	
} 
*/

Sahi.prototype.nlstart = function(){}
Sahi.prototype.nlend = function(){}
Sahi.prototype.nl = null;

/* Native start */
Sahi.prototype._typeNative = function(str){
	if(this.isPhantomJS()){
		this.scheduleNoLog("_sahi.typeNativePhantomJS(" + this.quoted(str) + ")");
		return;
	}
	var robot = new java.awt.Robot();  
	for (var i=0; i<str.length; i++){
		var c = str.charAt(i);
		var keyCode = str.charCodeAt(i);
		var shiftKey = false;
		switch (c){
			case "~":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_BACK_QUOTE;
				break;
			}
			case "`":{
				keyCode = java.awt.event.KeyEvent.VK_BACK_QUOTE;
				break;
			}
			case "!":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_1;
				break;
			}
			case "@":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_2;
				break;
			}
			case "#":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_3;
				break;
			}
			case "$":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_4;
				break;
			}
			case "%":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_5;
				break;
			}
			case "^":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_6;
				break;
			}
			case "&":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_7;
				break;
			}
			case "*":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_8;
				break;
			}
			case "(":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_9;
				break;
			}
			case ")":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_0;
				break;
			}
			case "_":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_MINUS;
				break;
			}
			case "+":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_EQUALS;
				break;
			}
			case "{":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_OPEN_BRACKET;
				break;
			}
			case "}":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_CLOSE_BRACKET;
				break;
			}
			case ":":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_SEMICOLON;
				break;
			}
			case "\"":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_QUOTE;
				break;
			}
			case "\'":{
				keyCode = java.awt.event.KeyEvent.VK_QUOTE;
				break;
			}
			case "<":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_COMMA;
				break;
			}
			case ">":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_PERIOD;
				break;
			}
			case "?":{
				shiftKey = true;
				keyCode = java.awt.event.KeyEvent.VK_SLASH;
				break;
			}
			case "\\":{
				keyCode = java.awt.event.KeyEvent.VK_BACK_SLASH;
				break;
			}
		}
		if ((keyCode >= 97 && keyCode <= 122) || (keyCode >= 65 && keyCode <= 90)) {
			shiftKey = (keyCode >= 65 && keyCode <= 90); 
			keyCode = eval("java.awt.event.KeyEvent.VK_" + (""+c).toUpperCase());
		}
		
		if (shiftKey) robot.keyPress(java.awt.event.KeyEvent.VK_SHIFT);
		try{
			robot.keyPress(keyCode);
			robot.keyRelease(keyCode)
			this.wait(net.sf.sahi.config.Configuration.getSafariTypeNativeWaitTime());	//fix for Safari capitalization issue. Try Ram on demo login name
		}catch(e){
			this.print(c + " " + e);
		}finally{
			if (shiftKey) robot.keyRelease(java.awt.event.KeyEvent.VK_SHIFT);
		}
	}
};
Sahi.prototype._typeKeyCodeNative = function(keyCode){
	if(this.isPhantomJS()){
		if(keyCode == java.awt.event.KeyEvent.VK_ENTER){
			keyCode = 16777221;
		}
		this.scheduleNoLog("_sahi.typeNativePhantomJS(" + keyCode + ")");
		return;
	}
	var robot = new java.awt.Robot();
	robot.keyPress(keyCode);
	robot.keyRelease(keyCode);
};
Sahi.prototype._rightClickNative = function(el, combo) {
	this._clickNative(el, combo, true, false);
};
Sahi.prototype._doubleClickNative = function(el, combo) {
	this._clickNative(el, combo, false, true);
}

Sahi.prototype.getXYNative = function(el){
	this.scheduleNoLog("_sahi.placePattern(_sahi.getWindow("+el+"));");
	for(var i = 0; i< 20; i++){
		this.wait(30);
		var pagePos = Packages["in"].co.sahi.util.ImagePatternFinder.findBrowserTopXY(null);
		if(pagePos[0] != -1 && pagePos[1] != -1) break;
	}
	if(pagePos[0] == -1 && pagePos[1] == -1 ){
		var error = new Error("Could not locate window top.")
		throw error;
	}
	this.print("pagePos = " + pagePos[0] + "," + pagePos[1]);
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(true, "");
	this.scheduleNoLog("_sahi.removePatternAndScroll("+el+");");
	var elPos = this._fetch("_sahi.findClientPosWithOffset(" + el + ")");
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(false, null);
	this.print("elPos = " + elPos[0] + "," + elPos[1]);
	
	var x = parseInt(pagePos[0]) + parseInt(elPos[0]);
	var y = parseInt(pagePos[1]) + parseInt(elPos[1]);
	var xyArray = [x, y, parseInt(pagePos[0]), parseInt(pagePos[1])];
	return xyArray;
	
}

Sahi.prototype._clickNative = function(el, combo, isRight, isDouble){
	if(!isRight) isRight = false;
	if(!isDouble) isDouble = false;
		ScriptRunner.getReport().setMaskLogsAndMaskMessage(true, "_clickNative(" + el + ", " + this.quoted(combo) + ", " + isRight + ", " + isDouble + ")");
	var xyArr = this.getXYNative(el);
	this._clickNativeXY(xyArr[0], xyArr[1], combo, isRight, isDouble)
};

Sahi.prototype._mouseOverNative = function(el, combo){
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(true, "_mouseOverNative(" + el + ", " + this.quoted(combo) + ")");
	var xyArr = this.getXYNative(el);
	var robot = new java.awt.Robot();
	if (combo) {
		if(combo.indexOf("ALT")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_ALT);
		}
		if(combo.indexOf("SHIFT")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_SHIFT);
		}
		if(combo.indexOf("CTRL")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_CONTROL);
		}
		if(combo.indexOf("META")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_META);
		}
		if(combo.indexOf("WINDOWS")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_WINDOWS);
		}		
	}
	robot.mouseMove(xyArr[0], xyArr[1]);
	if (combo) {
		if(combo.indexOf("ALT")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);
		}
		if(combo.indexOf("SHIFT")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_SHIFT);
		}
		if(combo.indexOf("CTRL")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL);
		}
		if(combo.indexOf("META")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_META);
		}
		if(combo.indexOf("WINDOWS")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_WINDOWS);
		}
	}
}

Sahi.prototype._clickNativeXY = function(x, y, combo, isRight, isDouble) {
	var robot = new java.awt.Robot();
	robot.mouseMove(x, y);
	if (combo) {
		if(combo.indexOf("ALT")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_ALT);
		}
		if(combo.indexOf("SHIFT")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_SHIFT);
		}
		if(combo.indexOf("CTRL")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_CONTROL);
		}
		if(combo.indexOf("META")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_META);
		}
		if(combo.indexOf("WINDOWS")!= -1) {
			robot.keyPress(java.awt.event.KeyEvent.VK_WINDOWS);
		}		
	}
	if(isRight){
		robot.mousePress(java.awt.event.InputEvent.BUTTON3_MASK);
		robot.mouseRelease(java.awt.event.InputEvent.BUTTON3_MASK);
	}else if(isDouble) {
		robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
		robot.delay(50);
		robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
		robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
		robot.delay(50);
		robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
	}else{
		robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
		robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
	}
	
	if (combo) {
		if(combo.indexOf("ALT")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);
		}
		if(combo.indexOf("SHIFT")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_SHIFT);
		}
		if(combo.indexOf("CTRL")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL);
		}
		if(combo.indexOf("META")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_META);
		}
		if(combo.indexOf("WINDOWS")!= -1) {
			robot.keyRelease(java.awt.event.KeyEvent.VK_WINDOWS);
		}
	}
	
}

Sahi.prototype.placePatternAndGetElementPositionRelativeToScreen = function(el){
	this.scheduleNoLog("_sahi.placePattern(_sahi.getWindow("+el+"));");
	this.wait(this.stepInterval*4);
	for(var i = 0; i< 10; i++){
		this.wait(30);
		var pagePos = Packages["in"].co.sahi.util.ImagePatternFinder.findBrowserTopXY(null);
		if(pagePos[0] != -1 && pagePos[1] != -1) break;
	}
	if(pagePos[0] == -1 && pagePos[1] == -1 ){
		var error = new Error("Could not locate window top.")
		throw error;
	}
	this.scheduleNoLog("_sahi.removePatternAndScroll("+el+");");
	this.wait(this.stepInterval*2);
	var elPos = this._fetch("_sahi.findClientPosWithOffset(" + el + ")");
	var x = parseInt(pagePos[0]) + parseInt(elPos[0]);
	var y = parseInt(pagePos[1]) + parseInt(elPos[1]);
	return new Array(x,y);
};

Sahi.prototype._dragDropNative = function(el, el2){
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(true, "_dragDropNative(" + el + ", " + el2 + ")");
	this.scheduleNoLog(el + ".scrollIntoView()");
	this.wait(this.stepInterval*2);
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(true, "");
	var isDraggableInViewPort = this._fetch("_sahi.isElementCompletelyVisibleInCurrentViewport(" + el + ")");
	var isDroppableInViewPort = this._fetch("_sahi.isElementCompletelyVisibleInCurrentViewport(" + el2 + ")");
	if(isDraggableInViewPort && isDroppableInViewPort){
		var pos = this.placePatternAndGetElementPositionRelativeToScreen(el);
		var x = pos[0];
		var y = pos[1];
		
		this.scheduleNoLog(el + ".scrollIntoView()");
		this.wait(this.stepInterval*2);
		var pos2 = this.placePatternAndGetElementPositionRelativeToScreen(el2);
		var x2 = pos2[0];
		var y2 = pos2[1];
		this._dragDropNativeXY(x, y, x2, y2);
	}
	else {
		var el1ScrollPosX = this._fetch("document.body.scrollLeft");
		var el1ScrollPosY = this._fetch("document.body.scrollTop");
		var pos = this.placePatternAndGetElementPositionRelativeToScreen(el);
		var x = pos[0];
		var y = pos[1];
		this.wait(this.stepInterval*2);
		this.scheduleNoLog(el2 + ".scrollIntoView()");
		this.wait(this.stepInterval*2);
		var el2ScrollPosX = this._fetch("document.body.scrollLeft");
		var el2ScrollPosY = this._fetch("document.body.scrollTop");
		
		var pos2 = this.placePatternAndGetElementPositionRelativeToScreen(el2);
		var x2 = pos2[0];
		var y2 = pos2[1];
			
		this.scheduleNoLog(el + ".scrollIntoView()");
		this.wait(this.stepInterval*2);
		var scrolledX = el2ScrollPosX - el1ScrollPosX;
		var scrolledY = el2ScrollPosY - el1ScrollPosY;
		
		this._dragDropNativeXY(x, y, x2, y2, scrolledX, scrolledY);
	}
	ScriptRunner.getReport().setMaskLogsAndMaskMessage(false, null);
};

Sahi.prototype._dragDropNativeXY = function(x, y, x2, y2, scrolledX, scrolledY) {
	if(!scrolledX) scrolledX = 0;
	if(!scrolledY) scrolledY = 0;
	var robot = new java.awt.Robot();
	robot.mouseMove(x, y);
	this.wait(this.stepInterval*2);
	robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
	this.wait(this.stepInterval*2);
	var stepCount = 20;
	var deltaX = (x2-x + scrolledX)/stepCount;
	var deltaY = (y2-y + scrolledY)/stepCount;
	for(var i= 0; i<=stepCount; i++){
		robot.mouseMove(x + i*deltaX, y + i*deltaY);
		this.wait(10);
	}
	this.wait(this.stepInterval*2);
	robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
}

/* Native end */
Sahi.prototype._include = function(src){
	this._includeCommon(src, false);
}

Sahi.prototype._includeOnce = function(src){
	this._includeCommon(src, true);
}

Sahi.prototype._includeCommon = function(src, isIncludeOnce){
	var lastScriptPath = this.currentScriptPath;
	if (!this.currentParents) this.currentParents = [this._scriptPath()];
	var lastParents = this.currentParents.slice(0);
//	this.print(">> In " + this.currentScriptPath);
//	this.print(">> For " + src);
	this.currentScriptPath = this._resolvePath(src);
	if (this.currentParents.indexOf(this.currentScriptPath) != -1) {
		this.print(this.currentScriptPath + " already included.");
		this.currentScriptPath = lastScriptPath;;
		return;
	}
	this.currentParents.push(this.currentScriptPath);
//	this.print("---" + this.currentParents);
//	this.print("---" + this.currentScriptPath);
	ScriptRunner.processInclude(this.currentScriptPath, isIncludeOnce);
	this.currentScriptPath = lastScriptPath;
	this.currentParents = lastParents;
}

var RESTRequest = function(){
	this.$header = new java.util.HashMap();
	this.$body = "";
	this.$url = "";
	this.$queryString = "";
}
RESTRequest.prototype.addToQueryString = function($k,$v){
	if(this.$queryString == "")
		this.$queryString = this.createQueryString($k,$v);
	else 
		this.$queryString = this.$queryString + "&" + this.createQueryString($k,$v);
}
RESTRequest.prototype.addToBody = function($k,$v){
	if(this.$body == "")
		this.$body = this.createQueryString($k,$v);
	else 
		this.$body = this.$body + "&" + this.createQueryString($k,$v);
}
RESTRequest.prototype.setBody = function($b) {
	this.$body = $b;
}
RESTRequest.prototype.createQueryString = function($k,$v){
	if($k instanceof Parameter){
		var $params = $k.$params;
		var $qs = "";
		for(var $key in $params){
			$qs = $qs +  $key + "=" + encodeURIComponent($params[$key]) + "&";
		}
		return $qs.substring(0,$qs.length-1);
	} else if(typeof $k == "string" && typeof $v == "string"){
		return ($k + "=" + encodeURIComponent($v));
	} else if(typeof $k == "string") {
		return $k;
	}
	return "";
}
RESTRequest.prototype.setHeader = function($k,$v){
	this.$header.put($k,$v)
}
RESTRequest.prototype.setURL = function($url){
	this.$url = $url;
}
RESTRequest.prototype.setCredentials = function($u, $p) {
	var $session = ScriptRunner.getSession();
	Packages.net.sf.sahi.util.ThreadLocalMap.put("session", $session);
	var $credentialKey = this.getCredentialKey(this.$url);
	$session.addRequestCredentials($credentialKey, $u, $p);
}
RESTRequest.prototype.submit = function($methodName){
	$request = new Packages.in.co.sahi.rest.REST();
	this.addQueryStringToUrl();
	if(this.$url == "") return; 
	return new RESTResponse($request.readURL(this.$header, this.$body, this.$url, $methodName));
}
RESTRequest.prototype.addQueryStringToUrl = function(){
	if(this.$url == "") return;
	if(this.$url.indexOf("?") != -1){
		var $urlWithoutQS = this.$url.substring(0,this.$url.indexOf("?")+1);
		var $previousQS = this.$url.substring(this.$url.indexOf("?")+1);
		this.$url = $urlWithoutQS + this.$queryString + "&" + $previousQS;
	} else {
		this.$url = this.$url + "?" + this.$queryString;
	}
}
RESTRequest.prototype.getCredentialKey = function($url) {
	var $tokens = $url.split("://");
	var $protocol = $tokens[0];
	var $secHalf = $tokens[1];
	var $tokens2 = $secHalf.split("/");
	var $host = $tokens2[0];
	var $port;
	if($host.indexOf(":") != -1){
		var $tokens3 = $host.split(":");
		$host = $tokens3[0];
		$port = $tokens3[1];
	}else{
		$port=($protocol=="http")?"80":"443";
	}
	var $returnVar = $protocol + "://" + $host + ":" + $port;
	return $returnVar;
}
var Parameter = function(){
	this.$params = {};
}
Parameter.prototype.add = function($k, $v){
	this.$params[$k] = $v;
}
Parameter.prototype.remove = function($k){
	delete this.$params[$k];
}

Parameter.prototype.getQueryString = function(){
	var $qs = "";
	for(var $key in this.$params){
		$qs = $qs +  $key + "=" + encodeURIComponent(this.$params[$key]) + "&";
	}
	$qs = $qs.substring(0,$qs.length-1);
	return $qs;
}
var RESTResponse = function($response){
	this.$response = $response;
}
RESTResponse.prototype.getResponseCode = function(){
	return this.$response.status();
}
RESTResponse.prototype.getHeader = function($k){
	return this.$response.getHeader($k);
}
RESTResponse.prototype.getHeaders = function(){
	return this.$response.headersAsString();
}
RESTResponse.prototype.getBody = function(){
	return this.$response.data();
}
RESTResponse.prototype.getBodyAsString = function(){
	return this.$response.dataAsString();
}
