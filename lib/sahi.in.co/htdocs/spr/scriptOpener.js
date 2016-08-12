function $(id){
	return document.getElementById(id);
};

ScriptOpener = function() {
	var so = this;
	this.attachSuggestionBox = function(textboxId, ddId){
	  	var fileboxSuggest = new Suggest($(textboxId), $(ddId), textboxId, true, $('loadDialog'));
		fileboxSuggest.getOptions = this.getScriptFiles;
		fileboxSuggest.onchange = this.wrap(function(){
			$(textboxId).value = $(ddId).value;
			this.setSelectedScript($(ddId).value);
		});
		fileboxSuggest.suggestOnClick();
	};
	
	this.refreshScriptListDir = function(){
		return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptDirsListJSON") + ")");
	};
	
	this.populateOptions = function(el, opts, selectedOpt, defaultOpt, prefix) {
	    el.options.length = 0;
	    if (defaultOpt) {
	        el.options[0] = new Option(defaultOpt, "");
	    }
	    var len = opts.length;
	    for (var i = 0; i < len; i++) {
	        var ix = el.options.length;
	        if (prefix) {
	            if (opts[i].indexOf(prefix) == 0) {
	                el.options[ix] = new Option(opts[i].substring(prefix.length), opts[i]);
	                if (opts[i] == selectedOpt) el.options[ix].selected = true;
	            }
	        } else {
	            el.options[ix] = new Option(opts[i], opts[i]);
	            if (opts[i] == selectedOpt) el.options[ix].selected = true;
	        }
	    }
	};
	
	this.populateScenarios = function(dir) {
		_scriptFileList = this.refreshScenarioListFile(dir);
		this.setSelectedScriptDir(dir);
		$('filebox').value = "";
	};
	
	this.populateScripts = function(dir) {
		_scriptFileList = this.refreshScriptListFile(dir);
		this.setSelectedScriptDir(dir);
		$('filebox').value = "";
	}
	
	this.populateSheet = function(dir) {
		_scriptFileList = this.refreshSheetListFile(dir);
		this.setSelectedScriptDir(dir);
		$('filebox').value = "";
	};
	
	this.getScriptFiles = function(str){
	    var options = [];
	    var fileList = null;
	    fileList = _scriptFileList;
	    if(!str) str="";
	    var strLC = str.toLowerCase(); 
	    var fileName = "";
	    if(fileList){
	    	for (var i=0; i<fileList.length; i++){
	    		fileName = fileList[i].replace(_selectedScriptDir, ""); 
	    		var fileNameLC = fileName.toLowerCase();
	        	if (fileNameLC.indexOf(strLC) != -1)
	            	options[options.length] = new Option(fileName, fileName);
	    	}
	    }
	    return options;
	};
	
	this.refreshScenarioListFile = function(dir){
		return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scenariosListJSON?dir="+dir) + ")");
	}
	
	this.refreshSheetListFile = function(dir){
		return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_sheetListJSON?dir="+dir) + ")");
	}
	
	this.setSelectedScriptDir = function(s) {
	    _selectedScriptDir = s;
	}
	
	this.setSelectedScript = function(s) {
	    _selectedScript = s;
	}
	
	this.refreshScriptListFile = function(dir){
		return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptsListJSON?dir="+dir+"&suites=" + _showSuites) + ")");
	}
	
	this.wrap = function (fn) {
		var el = this;
		return function(){return fn.apply(el, arguments);};
	}
	
}