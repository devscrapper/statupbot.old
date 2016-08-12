/**
 * Copyright Tyto Software Pvt. Ltd.
 */
sahisid = "$sahisid";
var _showSuites = false;
var _logsteps = [];
function showSteps(s, isRecorded) {
	setDebugValue(s);
};
function showPosition(value) {
	if($("checkbox_position").checked){
		$("taResult").value = value;
	}
};
function addToSteps(s) {
	if (s && s!=null) {
		setEditorValue("taSteps", getEditorValue("taSteps") + s + "\n");
		scrollDown($("taSteps"));
	}
}
function enterEvent(e) {
	if(e.keyCode==13){
		$("setUrlBtn").click();
	}
}
var currentActiveTab = null;
TabGroup = function(name, ids, defaultId) {
	this.name = name;
	this.ids = [];
	this.defaultId = defaultId;
	this.addAll(ids);
	var activeTab = getTabVar(this.name);
	if (activeTab != null)
		this.show(activeTab);
	else
		this.show(this.defaultId);
	TabGroup.instances[TabGroup.instances.length] = this;
};
TabGroup.instances = [];
TabGroup.prototype.addAll = function(ids) {
	for ( var i = 0; i < ids.length; i++) {
		this.add(ids[i]);
	}
};
TabGroup.prototype.add = function(id) {
	this.ids[this.ids.length] = id;
	$(id).onclick_ = $(id).onclick;
	$(id).onclick = null;
	this.addEvent($(id), "click", this.wrap(this.onclick, this));
};
TabGroup.prototype.addEvent = function(el, ev, fn) {
	if (!el)
		return;
	if (el.attachEvent) {
		el.attachEvent("on" + ev, fn);
	} else if (el.addEventListener) {
		el.addEventListener(ev, fn, false);
	}
};
TabGroup.prototype.wrap = function(fn, el) {
	if (!el)
		el = this;
	return function() {
		fn.apply(el, arguments);
	};
};
TabGroup.prototype.onclick = function(e) {
	var el = getTarget(e);
	var thisId = el.id;
	this.show(thisId, true);
};
TabGroup.prototype.show = function(thisId, isEvent) {
	if (!thisId || !$(thisId))
		thisId = this.defaultId;
	if (!thisId)
		return;

	for ( var i = 0; i < this.ids.length; i++) {
		var id = this.ids[i];
		if (!$(id))
			continue;
		$(id + "box").style.display = (id == thisId) ? "block" : "none";
		$(id).className = "dimTab";
	}

	var el = $(thisId);
	el.className = "hiTab";
	// if (el.onclick && !isEvent) el.onclick();
	if (el.onclick_)
		el.onclick_();
	this.selectedTab = thisId;
	currentActiveTab = this.selectedTab;
};
var wasRecLoaded = false;
var wasPlaybackLoaded = false;
var wasClipLoaded = false;
function recOnClick() {
	if (wasPlaybackLoaded)
		doOnPlaybackUnLoad();
	if (wasClipLoaded)
		doOnClipUnload();

	doOnRecLoad();
	wasRecLoaded = true;
}
function playbackOnClick() {
	if (wasRecLoaded)
		doOnRecUnLoad();
	if (wasClipLoaded)
		doOnClipUnload();
	doOnPlaybackLoad();
	wasPlaybackLoaded = true;
}
/*
 * Added for clipboard click
 */
function clipOnClick() {
	if (wasPlaybackLoaded)
		doOnPlaybackUnLoad();
	if (wasRecLoaded)
		doOnRecUnLoad();
	doOnClipLoad();
	wasClipLoaded = true;
}
function infoOnClick() {
	diagnostics.storeDiagnostics();
	displayInfoTab();
	if (wasPlaybackLoaded)
		doOnPlaybackUnLoad();
	if (wasRecLoaded)
		doOnRecUnLoad();
	if (wasClipLoaded)
		doOnClipUnload();
}
function docsOnClick(){
	if (wasPlaybackLoaded)
		doOnPlaybackUnLoad();
	if (wasRecLoaded)
		doOnRecUnLoad();
	if (wasClipLoaded)
		doOnClipUnload();
}
function getURLBase() {
	return "http://localhost:" + sahiSendToServer("/_s_/dyn/Configuration_getPort");
}
function loadOREditor() {
	var dir = $("recdir").value;
	var file = $("fileOR").value;
	if(file != "" && file.indexOf(".") == -1) file = file + ".sah";
	sahiSendToServer("/_s_/dyn/ControllerUI_openEditor?dir="+encodeURIComponent(dir) + "&file=" + encodeURIComponent(file));
}
function loadEditor() {
	var dir = $("recdir").value;
	var file = $("recfile").value;
	if(file != "" && file.indexOf(".") == -1) file = file + ".sah";
	sahiSendToServer("/_s_/dyn/ControllerUI_openEditor?dir="+encodeURIComponent(dir) + "&file=" + encodeURIComponent(file));
}
function loadPlaybackScriptEditor() {
	if ($("seturl").style.display == "none") {
		var dir = $("pbdir").value;
		var file = $("filebox").value;
		if(file != "" && file.indexOf(".") == -1) file = file + ".sah";
		sahiSendToServer("/_s_/dyn/ControllerUI_openEditor?dir="+encodeURIComponent(dir) + "&file=" + encodeURIComponent(file));
	} else {
		window.open("/_s_/dyn/Player_currentScript/");
	}
}
function loadLogs() {
	sahiSendToServer("/_s_/dyn/ControllerUI_openLogs");
}
var getTarget = function(e) {
	var targ;
	if (!e)
		e = window.event;
	if (e.target)
		targ = e.target;
	else if (e.srcElement)
		targ = e.srcElement;
	if (targ.nodeType == 3) // defeat Safari bug
		targ = targ.parentNode;
	return targ;
};
TabGroup.prototype.getSelectedTab = function(e) {
	return this.selectedTab;
};
TabGroup.prototype.showDefault = function(force) {
	if (force || this.selectedTab == null)
		this.show();
};
TabGroup.getStateVars = function() {
	var s = "";
	for ( var i = 0; i < TabGroup.instances.length; i++) {
		var tg = TabGroup.instances[i];
		s += addVar(tg.name, tg.getSelectedTab());
	}
	return s;
};
TabGroup.getState = function() {
	var s = [];
	for ( var i = 0; i < TabGroup.instances.length; i++) {
		var tg = TabGroup.instances[i];
		s[s.length] = {
			id : tg.name,
			value : tg.getSelectedTab(),
			type : "tab"
		};
	}
	return s;
};
TabGroup.showDefaults = function() {
	for ( var i = 0; i < TabGroup.instances.length; i++) {
		TabGroup.instances[i].showDefault();
	}
};
function $(id) {
	return document.getElementById(id);
}
function checkOpener() {
	try {
		var x = window.top.opener.document;
	} catch (e) {
	}
}
function sahiOpener() {
	return window.top.opener._sahi.top();
}
window.onerror = checkOpener;
function trim(s) {
	s = s.replace(/^[ \t]/, "", "g");
	return s.replace(/[ \t]$/, "", "g");
}

function checkURL(url) {
	if (url == null || sahiTrim(url) == "")
		return "";
	if (url.indexOf("://") == -1)
		return "http://" + url;
	return url;
}
function resetIfNeeded() {
//	var nextStep = parseInt($("nextStep").value);
//	var currentStep = parseInt($("currentStep").innerHTML);
//	if (nextStep <= currentStep) {
	resetScript();
//	}
}
var isPaused = false;
function play() {
	if (isPaused) {
		sahiSetServerVar("sahi_paused", 0);
		isPaused = false;
	} else {
		onScriptFormSubmit();
	}
	return true;
}
function stepWisePlay() {
	// resetIfNeeded();
	// var i = parseInt($("nextStep").value);
	// sahiOpener().eval("_sahi.skipTill("+i+")");
	// sahiOpener().eval("_sahi.ex(true)");
	// sendMessage("_sahi.ex(true)");
	isPaused = true;
	sahiSendToServer("/_s_/dyn/Player_setSingleStep");
}
function sendMessage(o, returnResult, addSahi) {
	if (typeof o == 'string') {
		o = {
			command : 'eval',
			value : o
		};
	}
	o.returnResult = returnResult;
	var s = util.toJSON(o);
	var context = $("prefix").value;
	if (context != "")
		context = "_sahi." + context;
	sahiSendToServer("/_s_/dyn/ControllerUI_setMessageFromController?msg="
			+ encodeURIComponent(s) + "&addSahi=" + addSahi + "&context="
			+ encodeURIComponent(context));
}
function pause() {
	isPaused = true;
	sahiSetServerVar("sahi_paused", 1);
}
function stopPlay() {
	isPaused = false;
	sahiSendToServer("/_s_/dyn/Player_stop");
}
function resetStep() {
	return;
//	$("currentStep").innerHTML = "0";
//	$("nextStep").value = 1;
//	sahiSetServerVar("sahiIx", 0);
//	sahiSetServerVar("sahiLocalIx", 0);
}
function clearLogs() {
	$("talogs").value = "";
	_logsteps = [];
}
function stopRec() {
	sahiSendToServer("/_s_/dyn/Recorder_stop");
	enableRecordButton();
}
//window.top.isWinOpen = true;
function pageUnLoad(s) {
	sendPlaybackSnapshot();
	sendRecorderSnapshot();
	sendClipSnapshot();
	sahiSetVarRemember("tab_state", TabGroup.getStateVars());
//	sahiSendToServer('/_s_/dyn/ControllerUI_closed');
//	try {
//		window.top.isWinOpen = false;
//	} catch (ex) {
//		sahiHandleException(ex);
//	}
}
function pageOnLoad() {
	loadAPIs();
	Suggest.hideAll();
	resizeTAs();
}
function doOnRecUnLoad(s) {
	sendRecorderSnapshot();
}
function doOnPlaybackUnLoad(s) {
	sendPlaybackSnapshot();
}
/*
 * Added for clipboard
 */
function doOnClipUnload(s) {
	sendClipSnapshot();
}
function sendPlaybackSnapshot() {
	var s = "";
	s += addVar("controller_url", $("url").value);
	s += addVar("controller_logs", $("talogs").value);
//	s += addVar("controller_step", $("nextStep").value);
	s += addVar("controller_url_starturl", $("url_starturl").value);
	s += addVar("controller_pb_dir", $("pbdir").value);
	s += addVar("controller_file_starturl", $("script_starturl").value);
	s += addVar("controller_file_scriptname", $("filebox").value);
	var showUrl = "" + ($("seturl").style.display == "block");
	s += addVar("controller_show_url", showUrl);
	s += addVar("controller_use_startURL",$("script_usestarturl").checked);
	s += addVar("controller_use_startURL_forscripturl",$("script_usestarturl_forscripturl").checked);
	sahiSetVarRemember("sahi_persist_playback_state", s);
	// sahiSetServerVarStatic("sahi_persist_playback_state", s);
	// sahiSetServerVar("sahi_persist_playback_state", s);
}
function sendRecorderSnapshot() {
	var s = "";
	s += addVar("controller_recorder_file", $("recfile").value);
	s += addVar("controller_el_value", $("elValue").value);
	// s += addVar("controller_comment", $("comment").value);
	s += addVar("controller_accessor", $("accessor").value);
	// s += addVar("controller_alternative",
	// window.document.currentForm.alternative.value);
	s += addVar("controller_debug", getEditorValue("taDebug"));
	s += addVar("controller_steps", $("taSteps").value);
	s += addVar("controller_history", $("history").value);
	// s += addVar("controller_waitTime", $("waitTime").value);
	s += addVar("controller_result", $("taResult").value);
	s += addVar("controller_rec_dir", $("recdir").value);
	s += addVar("object_repository_filename", $("fileOR").value);
	s += addVar("use_object_repository", $("isOREnabled").checked);
	s += addVar("use_enabled_screenshots", $("screenshot").checked);
	s += addVar("use_checkbox_position", $("checkbox_position").checked);
	sahiSetVarRemember("sahi_persist_recorder_state", s);
	// sahiSetServerVarStatic("sahi_persist_recorder_state", s);
	// sahiSetServerVar("sahi_persist_recorder_state", s);
}

/*
 * Added for clipboard
 */
function sendClipSnapshot() {
	var s = "";
	s += addVar("clip_text", $("clipTextArea").value);
	sahiSetVarRemember("sahi_persist_clip_state", s);
}
function addVar(n, v) {
	return n + "=" + v + "_$sahi$_";
}
_recVars = null;
function getRecVar(name) {
	if (_recVars == null || _recVars == "") {
		_recVars = loadVars("sahi_persist_recorder_state");
	}
	return blankIfNull(_recVars[name]);
}
_clipVars = null;
function getClipVar(name) {
	if (_clipVars == null || _clipVars == "") {
		_clipVars = loadVars("sahi_persist_clip_state");
	}
	return blankIfNull(_clipVars[name]);
}
_tabVars = null;
function getTabVar(name) {
	if (_tabVars == null || _tabVars == "") {
		_tabVars = loadVars("tab_state");
	}
	return blankIfNull(_tabVars[name]);
}

function loadVars(serverVarName) {
	var s = sahiGetVarRemember(serverVarName);

	var a = new Array();
	if (s) {
		var nv = s.split("_$sahi$_");
		for ( var i = 0; i < nv.length; i++) {
			var ix = nv[i].indexOf("=");
			var n = nv[i].substring(0, ix);
			var v = nv[i].substring(ix + 1);
			a[n] = blankIfNull(v);
		}
	}
	return a;
}
_pbVars = null;
function getPbVar(name) {
	if (_pbVars == null || _pbVars == "") {
		_pbVars = loadVars("sahi_persist_playback_state");
	}
	return blankIfNull(_pbVars[name]);
}
var _selectedScriptDir = null;
var _selectedScript = null;
var _scriptDirList = null;
var _scriptFileList = null;

function doOnRecLoad() {
	_scriptDirList = refreshScriptListDir();
	populateOptions($("recdir"), _scriptDirList, _selectedScriptDir);
	initRecorderTab();
	setORFilePath($("fileOR").value);
}

// Returns the number of characters of the longest element in a list
function getLongestListElementSize(p_list) {
	var longestSize = 0;
	var len = p_list.length;
	for ( var i = 0; i < len; ++i) {
		if (p_list[i].length > longestSize) {
			longestSize = p_list[i].length;
		}
	}
	return longestSize;
}

// Changes the width of an element. If more than 1 element has the same name, we
// resize
// the first one.
function resizeElementWidth(p_elementName, p_size) {
	var el = $(p_elementName);
	if (!el) {
		el = window.document.getElementsByName(p_elementName)[0];
	}
	if (parseInt(el.style.width) < p_size)
		el.style.width = p_size;
}

// Resize a dropdown list so we can see its entire content.
function resizeDropdown(p_dropdownContent, p_dropdownName, p_prefix) {
	var longest = getLongestListElementSize(p_dropdownContent);
	// A caracter is about 7 pixel long
	var newDropdownSize = (longest - p_prefix) * 6.2 + 20;
	resizeElementWidth(p_dropdownName, newDropdownSize);
}

function populateScripts(dir) {
	_scriptFileList = refreshScriptListFile(dir);
	setSelectedScriptDir(dir);
	$('filebox').value = "";
}

function populateScenarios(dir) {
	_scriptFileList = refreshScenarioListFile(dir);
	setSelectedScriptDir(dir);
	$('filebox').value = "";
}

function refreshScriptListDir() {
	return eval("("
			+ sahiSendToServer("/_s_/dyn/ControllerUI_scriptDirsListJSON")
			+ ")");
}

function refreshScriptListFile(dir) {
	return eval("("
			+ sahiSendToServer("/_s_/dyn/ControllerUI_scriptsListJSON?dir="
					+ dir + "&suites=" + _showSuites) + ")");
}

function refreshScenarioListFile(dir) {
	return eval("("
			+ sahiSendToServer("/_s_/dyn/ControllerUI_scenariosListJSON?dir="
					+ dir) + ")");
}

function populateOptions(el, opts, selectedOpt, defaultOpt, prefix) {
	el.options.length = 0;
	if (defaultOpt) {
		el.options[0] = new Option(defaultOpt, "");
	}
	var len = opts.length;
	for ( var i = 0; i < len; i++) {
		var ix = el.options.length;
		if (prefix) {
			if (opts[i].indexOf(prefix) == 0) {
				el.options[ix] = new Option(opts[i].substring(prefix.length),
						opts[i]);
				if (opts[i] == selectedOpt)
					el.options[ix].selected = true;
			}
		} else {
			el.options[ix] = new Option(opts[i], opts[i]);
			if (opts[i] == selectedOpt)
				el.options[ix].selected = true;
		}
	}
	// alert(el.options.length)
}

function doOnPlaybackLoad() {
	initPlaybackTab();
//
//	var ix = sahiGetCurrentIndex();
//	if (ix != null) {
//		displayStepNum(ix);
//	}
}
function doOnClipLoad() {
	initClipTab();

}
//function isSameStep(ix) {
//	try {
//		return ($("nextStep").value == "" + ix);
//	} catch (e) {
//		return false;
//	}
//}

//function displayStepNum(ix) {
//	try {
//		if (window.document.playform)
//			$("currentStep").innerHTML = "" + ix;
//		$("nextStep").value = "" + (ix + 1);
//	} catch (e) {
//		sahiHandleException(e);
//	}
//}
//function sahiGetCurrentIndex() {
//	try {
//		var i = parseInt(sahiGetServerVar("sahiIx"));
//		return ("" + i != "NaN") ? i : 0;
//	} catch (e) {
//		sahiHandleException(e);
//	}
//}
function displayQuery(s) {
	// document.currentForm.query.value = forceWrap(s);
}
//function displayLogs(s, i) {
//	if (i == null) { // for stop PlayBack messages
//		if ($("talogs").value.match(s + "[\r\n]*$"))
//			return;
//	}
//	if (("" + i) != $("currentStep").innerHTML) {
//		if (s == "\n")
//			return;
//		if (_logsteps.length > 100)
//			_logsteps.shift();
//		_logsteps.push(s);
//		$("talogs").value = _logsteps.join("\n");
//		scrollDown($("talogs"));
//	}
//}
function scrollDown(el) {
	el.scrollTop = el.scrollHeight;
}
function forceWrap(s1) {
	var ix = s1.indexOf("\n");
	var s = s1;
	var rest = "";
	if (ix != -1) {
		s = s1.substring(0, ix);
		rest = s1.substring(ix);
	}
	var start = 0;
	var BR_LEN = 51;
	var len = s.length;
	var broken = "";
	while (true) {
		if (start + BR_LEN >= len) {
			broken += s.substring(start);
			break;
		} else {
			broken += s.substring(start, start + BR_LEN) + "\n";
			start += BR_LEN;
		}
	}
	return broken + rest;
}
function setSelectedScriptDir(s) {
	_selectedScriptDir = s;
}
function setSelectedScript(s) {
	_selectedScript = s;
}
var isRecordAll = true;
function recordAll() {
	isRecordAll = !isRecordAll;
}
function disableRecordButton() {
	$("record").disabled = true;
}
function enableRecordButton() {
	$("record").disabled = false;
}
function onRecordStartFormSubmit(f) {
	//changeObjectRepositoryEnable();
	setEditorValue("taSteps","");
	var scriptPath = sahiTrim($('recfile').value.split('.')[0]);
	if (scriptPath == "") {
		alert("Please enter a name for the script");
		$("recfile").focus();
		return false;
	}
	var ORPath = sahiTrim($('fileOR').value.split('.')[0]);
	if ($('isOREnabled').checked && ORPath == "") {
		alert("Please enter a name for the Accessor Repository file");
		$("fileOR").focus();
		return false;
	}
	if (scriptPath == ORPath) {
		alert("Script name and AR file name are same.\nIt should be different.");
		return false;
	}
	if(scriptPath.indexOf(".sah") == -1) scriptPath = scriptPath + ".sah";
	if(ORPath.indexOf(".sah") == -1) ORPath = ORPath + ".sah";
	var el1 = $("recdir");
	var value1 = el1.options[el1.selectedIndex].value.replace(/:/g, '%3A');
	var el3 = $("screenshot");
	var value3 = el3.checked;

	var filePath = value1+scriptPath;
	var fileExist = sahiSendToServer("/_s_/dyn/Driver_isFileExists?filePath="+ filePath);
	if(fileExist == "true"){
		var r = confirm("Script already exists.\nDo you want to append to this script?");
	 	if(!r)return false;
	}
	if ($('isOREnabled').checked) {
		var orFilePath = value1+ORPath;
		var orFileExist = sahiSendToServer("/_s_/dyn/Driver_isFileExists?filePath="+ orFilePath);
		if(orFileExist == "true"){
			var res = confirm("AR File already exists.\nDo you want to append to this file?");
		 	if(!res)return false;
		}
	}
	var url = "/_s_/dyn/Recorder_start?dir=" + value1 + "&file="
			+ scriptPath + "&enableScreenshot=" + value3 
			+ "&isOREnabled=" + $('isOREnabled').checked 
			+ "&fileOR=" + encodeURIComponent(ORPath);
	sahiSendToServer(url);
	// sahi().startRecording(recordAll);
	disableRecordButton();
	// window.setTimeout("top.location.reload();", 1000);
	// }
	return true;
}

function initRecorderTab() {
	$("recfile").value = getRecVar("controller_recorder_file");
	$("elValue").value = getRecVar("controller_el_value");
	$("accessor").value = getRecVar("controller_accessor");
	// window.document.currentForm.alternative.value =
	// getRecVar("controller_alternative");
	// $("comment").value = getRecVar("controller_comment");
	$("history").value = getRecVar("controller_history");
	setDebugValue(getRecVar("controller_debug"), true);
	// $("taDebug").value = getRecVar("controller_debug");
	setEditorValue("taSteps", getRecVar("controller_steps"));
	// $("taSteps").value = getRecVar("controller_steps");
	// $("waitTime").value = getRecVar("controller_waitTime");
	$("taResult").value = getRecVar("controller_result");
	$("fileOR").value = getRecVar("object_repository_filename");	
	$("isOREnabled").checked = (getRecVar("use_object_repository") == "true");
	toggleOR($("isOREnabled"));
	$("screenshot").checked = (getRecVar("use_enabled_screenshots") == "true");
	$("checkbox_position").checked = (getRecVar("use_checkbox_position") == "true");
	var dir = getRecVar("controller_rec_dir");
	if (dir && dir != null)
		$("recdir").value = getRecVar("controller_rec_dir");
	// if (sahi().isRecording()) disableRecordButton();
}
function showTab(s) {
	if (window.top.main.location.href.indexOf(s + '.htm') != -1)
		return;
	hilightTab(s);
	window.top.main.location.href = s + '.htm'
}
function initPlaybackTab() {
	// var f = window.document.scriptfileform;
	var dir = getPbVar("controller_pb_dir");
	_scriptDirList = refreshScriptListDir();
	populateOptions($("pbdir"), _scriptDirList, dir);
	setSelectedScriptDir($("pbdir").value);
	_scriptFileList = refreshScriptListFile($("pbdir").value);
	$("filebox").value = getPbVar("controller_file_scriptname");
	$("url").value = getPbVar("controller_url");
	$("talogs").value = getPbVar("controller_logs");
	$("url_starturl").value = getPbVar("controller_url_starturl");
	$("script_usestarturl").checked = (getPbVar("controller_use_startURL") == "true");
	$("script_usestarturl_forscripturl").checked = (getPbVar("controller_use_startURL_forscripturl") == "true");
	$("script_starturl").value = getPbVar("controller_file_starturl");
//	$("nextStep").value = getPbVar("controller_step");
	byFile(getPbVar("controller_show_url") != "true");
	_historyURLs = loadURLs();
	_logsteps = $("talogs").value.split("\n");
}
function initClipTab() {
	// to be added
	$("clipTextArea").value = getClipVar("clip_text");
}
function displayInfo(accessors, escapedAccessor, escapedValue, popupName) {
	var f = window.document.currentForm;
	if (f) {
		f.elValue.value = escapedValue ? escapedValue : "";
		f.accessor.value = escapedAccessor;
		populateOptions(f.alternative, accessors);
		// f.alternative.value = info.accessor;
		f.winName.value = popupName;
	}
}
function showCoords(x, y) {
	$("coords").innerHTML = "(" + x + ", " + y + ")";
}
function resetValue() {
	try {
		var prop = getAccessorAndProperty()[1];
		$("elValue").value = __lastProps && __lastProps[prop];
	} catch (e) {
	}
}

function setAPI() {
	var el = $("apiTextbox");
	// try{
	el.value = $("apiSelect").value;
	// }catch(e){}
}

function handleEnterKey(e, el) {
	if (!e)
		e = window.event;
	if (e.keyCode && e.keyCode == 26) {
		resetValue();
		return false;
	}
}

function xaddWait() {
	try {
		sahi().addWait($("waitTime").value);
	} catch (ex) {
		alert("Please enter the number of milliseconds to wait (should be >= 200)");
		$("waitTime").value = 3000;
	}
}

function xmark() {
	sahi().mark($("comment").value);
	// sahiSendToServer('/_s_/dyn/Recorder_record?event=mark&value='+escape(document.currentForm.comment.value));
}
function evaluateExpr(showErr) {
	if (!showErr)
		showErr = false;
	$("history").value += "\n" + getEditorValue("taDebug");
	var txt = getText();
	$("taResult").value = "Evaluating ...";
	sendMessage(txt, "taResult", true);
}
function isSaveORDisabled() {
	if ($("isOREnabled").checked) {
		if($("orKey").value == "") $("SaveOR").disabled=true;
		else $("SaveOR").disabled=false;
	} else $("SaveOR").disabled=true;
}
function saveORValue() {
	var r = confirm("Do you really want to change the AR Entry?");
 	if (!r) return false;
 	if ($("fileOR").value == "") {
 		$("taResult").value = "Enter File Name in the Accessor Repository File Path.";
 		$("fileOR").focus();
 		return false;
 	} 
 	else if ($('orKey').value == "" || $('orKey').value.indexOf("$") != 0) {
 		$("taResult").value = "Enter key(starting with '$') in the AR Key.";
 		$('orKey').focus();
 		return false;
 	}
 	else if ($('accessor').value == "") {
 		$("taResult").value = "Enter value in the Accessor.";
 		$('accessor').focus();
 		return false;
 	}
 	var filePath = getORFilePath($("fileOR").value);
	var fileExist = sahiSendToServer("/_s_/dyn/Driver_isFileExists?filePath="+ filePath);
	var oldValue = "OR key-value pair is not in the file.";
	if (fileExist == "true") {
		var orKey = $('orKey').value;
		oldValue = sahiSendToServer("/_s_/dyn/Recorder_getORValue?filepath="+filePath+"&orkey="+orKey).toString();
		if (oldValue != "OR key-value pair is not in the file.") {
			var res = confirm("AR Key already exists.\nDo you want to update its value?");
		 	if (!res) return false;
		}
	}
	sendMessage({
		command : 'saveORValue',
		oldValue: oldValue,
		newValue : $('orKey').value + " = " + $('accessor').value
	});
}
function demoClick() {
	var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
	setDebugValue("_click(" + acc + ");");
	evaluateExpr();
}
function diagnoseTest() {
	setDebugValue("' _sahi.areWindowsLoaded()='+_sahi.areWindowsLoaded() + '\\n' + \n" +
			"'_sahi.areXHRsDone()='+_sahi.areXHRsDone() + '\\n' + \n" +
			"'_sahi.showOpenXHRs()='+_sahi.showOpenXHRs() + '\\n' + \n" +
			"'_sahi.areFlexAppsLoaded(_sahi.top())='+_sahi.areFlexAppsLoaded(_sahi.top()) + '\\n\\n' + \n" +
			"'--\\nIf you see a lot of XHRs open in readyState 1, add \\n' +  \n" +
			"'_setXHRReadyStatesToWaitFor(\"2,3\") \\n at the start of your script or *before* the step after which Sahi hangs.'.replace(/_sahi[.]_/g, '_')");
	evaluateExpr();
}
function demoHighlight() {
	var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
	setDebugValue("_highlight(" + acc + ");");
	evaluateExpr();
}
function demoHover() {
	var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
	setDebugValue("_mouseOver(" + acc + ");");
	evaluateExpr();
}
function demoAction(el) {
	if (el.value == "comment1") {
		setDebugValue("// Single line comment");
	} else if (el.value == "comment2") {
		setDebugValue("/* Multiline \n Comment */");
	} else if (el.value == "svon") {
		setDebugValue("_setStrictVisibilityCheck(true);");
		evaluateExpr();
	} else if (el.value == "svoff") {
		setDebugValue("_setStrictVisibilityCheck(false);");
		evaluateExpr();
	} else {
		var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
		setDebugValue(el.value + "(" + acc + ")");
		evaluateExpr();
	}
	el.options[0].selected = true;
}
var focusedID;
function focusedElement() {
	focusedID = document.activeElement.id;
}
function copyPaste(){
	var acc = $("accessor").value;
	
	if (!$("isOREnabled").checked) {
		acc = $("accessor").value;
	} else {
		if (focusedID != "accessor" && $("orKey").value != "") acc = $("orKey").value;
	}
	focusedID = "";
	replaceEditorSelection("taDebug", acc);
	//setDebugValue($("accessor").value);
}
function performAction(el) {
	if (el.value == "click") {
		demoClick2();
	}
	else if(el.value== "getValue") {
		demoGetValue2();
	}
	else if(el.value== "getORValue") {
		demoGetORValue();
	}
	else if(el.value== "getText") {
		demoGetText2();
	}
	else if(el.value== "toJSON") {
		demoToJSON();
	}
	else if(el.value== "exists") {
		demoExists2();
	}
	else if(el.value== "isVisible") {
		demoIsVisible2();
	}
	else if(el.value== "position") {
		demoPosition2();
	}
	el.options[0].selected = true;
}
function getSelectedText(id, defaultToFull) {
	try {
		if (_isIE())
			return getSel();
		var textarea = $(id);
		var len = textarea.value.length;
		var start = textarea.selectionStart;
		var end = textarea.selectionEnd;
		var sel = textarea.value.substring(start, end);
		if (!sel && defaultToFull)
			sel = $(id).value;
		return sel;
	} catch (e) {
		return "";
	}
}
function getText() {
	return getEditorSelectionValue("taDebug", true);
}
function getTrimmedText() {
	return sahiTrim(getEditorSelectionValue("taDebug", true).replace(/\n/g, ''));
}
function demoHighlight2() {
	sendMessage("_highlight(" + getTrimmedText() + ")", false, true);
}
function demoClick2() {
	sendMessage("_click(" + getTrimmedText() + ")", false, true);
}
function demoGetValue2() {
	showCommandAndResult("_getValue(" + getTrimmedText() + ")");
}
function demoGetORValue() {
	if ($("fileOR").value == "") {
		$("taResult").value = "Enter File Name in the Accessor Repository File Path.";
		$("fileOR").focus();
	} else {
		var filePath = getORFilePath($("fileOR").value);
		var fileExist = sahiSendToServer("/_s_/dyn/Driver_isFileExists?filePath="+ filePath);
		if (fileExist == "true") {
			var orKey = getTrimmedText();
			if(orKey == "") return;
			var orValue = sahiSendToServer("/_s_/dyn/Recorder_getORValue?filepath="+filePath+"&orkey="+orKey).toString();
			if (orValue == "OR key-value pair is not in the file.")
				$("taResult").value = "ERROR: AR key-value pair is not in the file.";
			else
				$("taResult").value = orValue;
		} else {
			$("taResult").value = "ERROR: Accessor Repository File does not exist.";
			$("fileOR").focus();
		}
	}
}
function demoGetText2() {
	showCommandAndResult("_getText(" + getTrimmedText() + ")");
}
function demoToJSON() {
	showCommandAndResult("_toJSON(" + getTrimmedText() + ")");
}
function demoExists2() {
	showCommandAndResult("_exists(" + getTrimmedText() + ")");
}
function demoIsVisible2() {
	showCommandAndResult("_isVisible(" + getTrimmedText() + ")");
}
function demoPosition2() {
	showCommandAndResult("_position(" + getTrimmedText() + ")");
}
function showCommandAndResult(cmd) {
	var s = "\"" + cmd.replace(/"/g, '\\"') + "=\\n\".replace(/_sahi[.]_/g, '_') + " + cmd;
	sendMessage(s, "taResult", true);
}
function demoSetValue() {
	var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
	if (acc.indexOf("_select") == 0 || acc.indexOf('e("select")') != -1
			|| acc.indexOf("combobox") != -1 || acc.indexOf("dropdown") != -1) {
		setDebugValue("_setSelected(" + acc + ", \"" + $('elValue').value
				+ "\");");
	} else
		setDebugValue("_setValue(" + acc + ", \"" + $('elValue').value + "\");");
	evaluateExpr();
}
function setDebugValue(s, noHistory) {
	if (!noHistory)
		$("history").value += "\n" + getEditorValue("taDebug");
	setEditorValue("taDebug", s);
}
function append() {
	var s = getText();
//	addToSteps(s);
	// sahi().recordStep(s, sahi().lastOREntry, true);
	sendMessage({
		command : 'recordStep',
		accessor: $("accessor").value,
		value : s
	});
	// sahiSendToServer('/_s_/dyn/Recorder_record?step=' +
	// fixedEncodeURIComponent(s));
}

function addSahi(s) {
	var msg = sahiSendToServer("/_s_/dyn/ControllerUI_getSahiScript?code="
			+ fixedEncodeURIComponent(s));
	// alert(decodeURIComponent(msg))
	return fixedDecodeURIComponent(msg);
}

function blankIfNull(s) {
	return (s == null || s == "null") ? "" : s;
}
function byFile(showFile) {
	$("seturl").style.display = showFile ? "none" : "block";
	$("setfile").style.display = showFile ? "block" : "none";
	resizeTAs();
}
function checkScript(f) {
	if (f.filebox && f.filebox.value == "") {
		alert("Please choose a script file");
		return false;
	}
	if (f.url && f.url.value == "") {
		alert("Please specify the url to script file");
		return false;
	}
	return true;

}
function getORFilePath(ORPath) {
	var el1 = $("recdir");
	if(ORPath.indexOf(".sah") == -1) ORPath = ORPath + ".sah";
	var value1 = el1.options[el1.selectedIndex].value.replace(/:/g, '%3A');
	return value1+ORPath;
}
function setORFilePath(ORPath) {
	var filePath = getORFilePath(ORPath);
	sahiSendToServer("/_s_/dyn/ControllerUI_setORFilePathFromController?orfilepath=" + filePath);
}
function toggleOR(el) {
	var isChecked = el.checked;
	$("ORTable").style.display = isChecked ? "block" :  "none";
	$("OR").style.display = isChecked ? "" : "none";
	$("orEditor").style.display = isChecked ? "" : "none";
	$("blankSpace").style.display = isChecked ? "" : "none";
	$("getORValue").style.display = isChecked ? "" : "none";
	isSaveORDisabled();
	resizeTAs();
	var isOR = el.checked ? "true" : "false";
	sahiSendToServer("/_s_/dyn/ControllerUI_setIsORFromController?isOR=" + isOR);
}
function replay() {
	resetStep();
	clearLogs();
	resetScript();
}
function resetScript() {
	sahiSendToServer("/_s_/dyn/Player_resetScript");
}
function resetUrl() {
	$('script_starturl').value = "";
}
function onScriptFormSubmit() {
	var usestarturl;
	if ($('seturl').style.display == "none"){
		f = window.document.scriptfileform;
		usestarturl = $("script_usestarturl");
	}
	else{
		f = window.document.scripturlform;
		usestarturl = $("script_usestarturl_forscripturl");
	}
	if (!checkScript(f))
		return false;
	if (usestarturl.checked) {
		
		var startURL = $('script_starturl').value;
		if (startURL.indexOf("http://") != 0 && startURL.indexOf("https://") != 0) startURL = "http://" + startURL;
		if (startURL.indexOf("http://localhost:") != -1 || startURL.indexOf("https://localhost:") != -1 || startURL.indexOf("http://localhost/") != -1 || startURL.indexOf("https://localhost/") != -1) {
			var confirm= window.confirm("Proxy is bypassed for localhost so Sahi may not work on this URL. Please use the machine name or IP address if localhost does not work. Proceed with localhost?");
			if(confirm != true) return;
		}
		var url = checkURL(f.starturl.value);
		if (url != '') {
			sendMessage("top.location.href = '" + url + "'");
		} else {
			sendMessage("window.setTimeout('top.location.reload()', 200);top.location.href", f.starturl.id);
		}
	} else {
		sendMessage("top.location.href", f.starturl.id);
	}
	resetStep();
	clearLogs();
	sendPlaybackSnapshot();
	// window.setTimeout("reloadPage('" + url + "')", 100);
	var starturl = f.starturl.value.replace(/:/g, '%3A');
	// var browser = (sahi().browserType != 'null') ? sahi().browserType :
	// getBrowserType();
	var browser = getBrowserType();
	if ($('seturl').style.display == "none") {
		var dirPath = f.dir.options[f.dir.selectedIndex].value.replace(/:/g,
				'%3A');
		var file = sahiTrim(f.filebox.value);
		sahiSendToServer("_s_/dyn/Player_setScriptFile?dir=" + dirPath
				+ "&file=" + file + "&starturl=" + starturl
				+ "&manual=1&browserType=" + browser);
	} else {
		var url = f.url.value.replace(/:/g, '%3A');
		sahiSendToServer("_s_/dyn/Player_setScriptUrl?url=" + url
				+ "&starturl=" + starturl + "&manual=1&browserType=" + browser);
	}
}
function reloadPage(u) {
	if (u == "" || sahiOpener().location.href == u) {
		sahiOpener().location.reload();
	} else {
		sahiOpener().location.href = u;
	}
}
function getSel() {
	var txt = '';
	if (window.getSelection) {
		txt = window.getSelection();
	} else if (window.document.getSelection) {
		txt = window.document.getSelection();
	} else if (window.document.selection) {
		txt = window.document.selection.createRange().text;
	}
	return txt;
}
function showHistory() {
	var histWin = window.open("history.htm", "sahi_history",
			"height=500px,width=450px,resizable");
}
function findPos(obj) {
	var x = 0, y = 0;
	if (obj.offsetParent) {
		while (obj.offsetParent) {
			// var wasStatic = null;
			x += obj.offsetLeft;
			y += obj.offsetTop;
			// if (wasStatic != null) obj.style.position = wasStatic;
			obj = obj.offsetParent;
		}
	} else if (obj.x) {
		x = obj.x;
		y = obj.y;
	}
	return [ x, y ];
};
function resizeTA2(el, minusRight, minusTop, percent) {
	var winH, winW;
	if (window.innerWidth) {
		winW = window.innerWidth;
		winH = window.innerHeight;
	} else if (document.documentElement && document.documentElement.clientWidth) {
		winW = document.documentElement.clientWidth;
		winH = document.documentElement.clientHeight;
	} else if (document.body.offsetWidth) {
		winW = document.body.offsetWidth;
		winH = document.body.offsetHeight;
	}
	if (minusRight != null)
		el.style.width = winW - minusRight + 'px';
	el.style.height = (winH - minusTop) * (percent / 100) + 'px';
}
function resizeTAs() {
	var t = findPos(getScroller('taDebug'))[1];
	var delta = 40;
	if (t > 10) {
		resizeTA2(getScroller('taDebug'), 35, t + delta, 50);
		resizeTA2(getScroller('taResult'), 32, t + delta, 50);
	}
	var taY = findPos(getScroller('talogs'))[1];
	if (taY > 10)
		resizeTA2(getScroller('talogs'), 41, taY + 30, 95);
	var taY = findPos(getScroller('taSteps'))[1];
	if (taY > 10)
		resizeTA2(getScroller('taSteps'), 28, taY + 18, 100);
	var taY = findPos(getScroller('taResult'))[1];
	if (taY > 10)
		resizeTA2(getScroller('taResult'), 28, taY + 18, 100);
	var dY = findPos(getScroller('infoDiv'))[1];
	if (dY > 0)
		resizeTA2(getScroller('infoDiv'), null, dY + 40, 100);
	var t = findPos(getScroller('clipTextArea'))[1];
	var delta = 20;
	if (t > 10) {
		resizeTA2(getScroller('clipTextArea'), 42, t + delta, 100);
	}
}

function appendToAccessor() {
	var accessor = $("accessor").value;
	if (accessor.indexOf('.') != -1) {
		var dot = accessor.lastIndexOf('.');
		var elStr = accessor.substring(0, dot);
		var prop = accessor.substring(dot + 1);
		$("accessor").value = elStr + "." + $("suggestDD").value;
	}
}

// Suggest List start
var stripSahi = function(s) {
	return s.replace(/sahi_/g, "_");
}
var __lastAccessorForProps = null;
var __lastProps = [];
function getAccessorAndProperty(){
	var str = $("accessor").value;
	var dot = -1;
	var elStr = str == "" ? "window" : ""; // when empty use window.
	if (str.indexOf('.') != -1) {
		dot = str.lastIndexOf('.');
		elStr = str.substring(0, dot);
	}
	var prop = str.substring(dot + 1);
	return [elStr, prop];
}
function getAccessorProps(str) {
	var elp = getAccessorAndProperty();
	var elStr = elp[0];
	var prop = elp[1];
	if (elStr != __lastAccessorForProps) {
		fetchAccessorProps(elStr);
	} else {
		return populateSuggestOptions("accessor", __lastProps, prop);
	} 
}
function fetchAccessorProps(elStr) {
	sendMessage({command: "getAccessorPropsMap", value:elStr}, false, true);
	__lastAccessorForProps = elStr;
}
function setAccessorProps(o){
	__lastProps = o;
	populateSuggestOptions("accessor", __lastProps, "");
}
function populateSuggestOptions(suggestId, optionStrs, prop) {
	optionStrs = sortMap(optionStrs);
	var options = [];
	for (var i in optionStrs) {
		if (i.indexOf(prop) == 0 && i != "sahiAccessorProps") {
			var truncated = i.length > 30 ? i.substring(0, 30) : i;
			options[options.length] = new Option(truncated, i);
		}
	}
	if (options) {
		var s = Suggest.suggests[suggestId];
		if (s && options.length > 0) {
			s.showSuggestions(options);
		}
	}
}

function sortMap(o){
	var keys = [];
    for (var key in o) {
      if (o.hasOwnProperty(key)) {
        keys.push(key);
      }
    }
    keys.sort();
    var sortedO = {};
    for (var i=0;i<keys.length;i++) {
      var key = keys[i];
      var value = o[key];
      sortedO[key] = value;
    }
    return sortedO;
}

function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function getORScriptFiles(str) {
	var options = [];
	var fileList = null;
	fileList = refreshScriptListFile($("recdir").value);
	if (!str)
		str = "";
	var strLC = str.toLowerCase();
	var fileName = "";
	if (fileList) {
		var orFileExtension = sahiSendToServer("/_s_/dyn/Configuration_getORFileExtension").toLowerCase();
		for ( var i = 0; i < fileList.length; i++) {
			fileName = fileList[i].replace($("recdir").value, "");
			var fileNameLC = fileName.toLowerCase();
			if (fileNameLC.indexOf(strLC) != -1 && endsWith(fileNameLC, orFileExtension))
				options[options.length] = new Option(fileName, fileName);
		}
	}
	return options;
}

function getScriptFiles(str) {
	var options = [];
	var fileList = null;
	fileList = _scriptFileList;
	if (!str)
		str = "";
	var strLC = str.toLowerCase();
	var fileName = "";
	if (fileList) {
		for ( var i = 0; i < fileList.length; i++) {
			fileName = fileList[i].replace(_selectedScriptDir, "");
			var fileNameLC = fileName.toLowerCase();
			if (fileNameLC.indexOf(strLC) != -1)
				options[options.length] = new Option(fileName, fileName);
		}
	}
	return options;
}
__apis = [];

function loadAPIs() {
	sendMessage("_sahi.getAPIs()", "apis");
}

function getAPIs(str) {
	var apis = $("apis").value.split(";");
	if (str == null || str == "")
		str = "_";
	var options = [];
	for (var i=0; i<apis.length; i++) {
		var api = apis[i];
		if (api.indexOf(str) != -1) {
			options.push(new Option(api, api));
		}
	}
	return options;
}
// Suggest List end
function _isIE() {
	return this.navigator.appName == "Microsoft Internet Explorer" || (this.navigator.appVersion && this.navigator.appVersion.indexOf("Trident") != -1);
}
function _isFF() {
	return /Firefox|Iceweasel|Shiretoko/.test(this.navigator.userAgent);
}
function _isChrome() {
	return ( /Chrome/.test(this.navigator.userAgent) && !_isOpera() );
}
function _isSafari() {
	return /Safari/.test(this.navigator.userAgent)
			&& !(/Chrome/.test(this.navigator.userAgent));
}
function _isOpera() {
	return ( /Opera/.test(this.navigator.userAgent) || /OPR/.test(this.navigator.userAgent) );
}

function getBrowserType() {
	if (_isIE())
		return "ie";
	else if (_isFF())
		return "firefox";
	else if (_isSafari())
		return "safari";
	else if (_isChrome())
		return "chrome";
	else if (_isOpera())
		return "opera";
	else
		return navigator.appName;
}
function getBrowserName() {
	if (_isIE())
		return "Microsoft Internet Explorer";
	else if (_isFF())
		return "Mozilla Firefox";
	else if (_isSafari())
		return "Safari";
	else if (_isChrome())
		return "Google Chrome";
	else
		return navigator.appName;
}
function getDiagnostics(name) {
	return diagnostics.getDiagnostics(name);
}
function displayInfoTab() {
	$("userAgent").innerHTML = getDiagnostics("UserAgent");
	// $("browserName").innerHTML = getDiagnostics("Browser Name");
	$("browserName").innerHTML = getBrowserName();
	$("browserVersion").innerHTML = getDiagnostics("Browser Version");
	$("xmlHttpRequest").innerHTML = getDiagnostics("Native XMLHttpRequest");
	$("javaEnabled").innerHTML = getDiagnostics("Java Enabled");
	$("cookieEnabled").innerHTML = getDiagnostics("Cookie Enabled");
	$("osName").innerHTML = getDiagnostics("osname");
	$("osVersion").innerHTML = getDiagnostics("osversion");
	$("osArchitecture").innerHTML = getDiagnostics("osarch");
	$("isTasklistAvailable").innerHTML = getDiagnostics("istasklistavailable");
	$("isCertUtilAvailable").innerHTML = getDiagnostics("iscertutilavailable");
	$("javaDirectory").innerHTML = getDiagnostics("javadir");
	$("javaVersion").innerHTML = getDiagnostics("javaversion");
	$("isKeytoolAvailable").innerHTML = getDiagnostics("iskeytoolavailable");
	$("isJarsignerAvailable").innerHTML = getDiagnostics("isjarsigneravailable");
}
var _version;
function getVersion() {
	if (!_version) {
		_version = sahiSendToServer("/_s_/dyn/ControllerUI_getSahiVersion");
	}
	return _version;
}
function getVersionDate() {
	return getVersion().split(" ")[0];
}
function updateVersion() {
	var currentVersion = getVersion();
	window.open("http://sahipro.com/w/version-check-pro?v=" + currentVersion,
			"_blank");
}
function sahiHandleException(e) {
}
function showProperties() {
	sendMessage({
		command : 'listProperties',
		value : $("accessor").value
	}, "taResult", true);
	// sendMessage({command:'listProperties', value: $("accessor").value}, true,
	// true);
	// setDebugValue(sahi().list(sahi()._eval(addSahi($('accessor').value))));
}
var anchorOn = false;
function setAnchor() {
	if (!anchorOn) {
		anchorOn = true;
		$("anchor").className = "anchorOn";
		sendMessage({
			command : 'setAnchor',
			value : $("accessor").value
		});
		// sahi().setAnchor($("accessor").value);
	} else {
		anchorOn = false;
		$("anchor").className = "anchorOff";
		sendMessage({
			command : 'removeAnchor'
		});
		// sahi().removeAnchor();
	}
}

function setAccessor(val) {
	var seperator = "] ";
	var ix = val.indexOf(seperator);
	var accessorVal = ix<0 ? val : val.substring(ix + seperator.length);
	$('accessor').value = accessorVal;
}

var upDownHistory = new Array();
function callUp() {
	var el = document.getElementById("accessor").value;
	upDownHistory.push(el);
	if (isFlex(el) || isApplet(el)) {
		sendMessage("_sahi." + el + ".identifyParent()");
		// sahiOpener().eval("_sahi." + el+ ".identifyParent()");
	} else {
		sendMessage("_sahi.identifyAndDisplay(_sahi." + el
				+ ".parentNode);_sahi._highlight(_sahi." + el + ".parentNode)");
		// sahiOpener().eval("_sahi.identifyAndDisplay(_sahi."+el+".parentNode)");
		// sahiOpener().eval("_sahi._highlight(_sahi."+el+".parentNode)");
	}

}
function callDown() {
	var el = upDownHistory.pop();
	if (isFlex(el) || isApplet(el)) {
		sendMessage("_sahi." + el + ".identifySelf()");
		// sahiOpener().eval("_sahi." + el + ".identifySelf()");
	} else {
		sendMessage("_sahi.identifyAndDisplay(_sahi." + el
				+ ");_sahi._highlight(_sahi." + el + ")");
		// sahiOpener().eval();
		// sahiOpener().eval("_sahi._highlight(_sahi."+el+")");
	}
}

function isFlex(el) {
	return (el.indexOf("_f(") == 0);
}
function isApplet(el) {
	return (el.indexOf("_a(") == 0 || el.indexOf("_applet(") == 0);
}
function clearUpDownHistory() {
	upDownHistory = new Array();
}

/* Pro code start */
function attachSuggestionBox(textboxId, ddId) {
	var fileboxSuggest = new Suggest($(textboxId), $(ddId), textboxId, true);
	fileboxSuggest.getOptions = getScriptFiles;
	fileboxSuggest.onchange = function() {
		$(textboxId).value = $(ddId).value;
		setSelectedScript($(ddId).value);
	}
	fileboxSuggest.suggestOnClick();
}
function attachORSuggestionBox(textboxId, ddId) {
	var fileboxSuggest = new Suggest($(textboxId), $(ddId), textboxId, true);
	fileboxSuggest.getOptions = getORScriptFiles;
	fileboxSuggest.onchange = function() {
		$(textboxId).value = $(ddId).value;
		setORFilePath($(ddId).value);
	}
	fileboxSuggest.suggestOnClick();
}
/* Pro code end */

/* URL history start */
var _historyURLs = null;
function getURLs(s) {
	if (!_historyURLs)
		_historyURLs = loadURLs(); // ["aa", "bb"];
	var urls = _historyURLs;
	var options = new Array();
	for ( var i = 0; i < urls.length; i++) {
		if (urls[i].indexOf(s) != -1)
			options[options.length] = new Option(urls[i], urls[i]);
	}
	return options;
}
function loadURLs() {
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_getURLHistory")
			+ ")");
}
function shouldAdd(url) {
	if (url == "" || url.value == "http://")
		return false;
	for ( var i = 0; i < _historyURLs.length; i++) {
		if (url == _historyURLs[i])
			return false;
	}
	return true;
}
function saveURL(url) {
	if (shouldAdd(url)) {
		_historyURLs.push(url);
		sahiSendToServer("/_s_/dyn/ControllerUI_addURLHistory?url="
				+ encodeURIComponent(url));
	}
}
function doAssert() {
	var acc = ($("isOREnabled").checked && $("orKey").value != "") ? $("orKey").value : $("accessor").value;
	sendMessage({
		command : 'assert',
		accessor : acc,
		value : $('elValue').value
	});
}
function quoted(s) {
	return '"' + s.replace(/"/g, '\\"') + '"';
}
function changeControllerMode(){
	var mode= "";
	if(document.getElementById("javaradio").checked){
		var mode= "java";
		//sendMessage("_sahi.noRefresh(" + mode + ")");
	}
	else if(document.getElementById("sahiradio").checked){
		var mode= "sahi";
		//sendMessage("_sahi.noRefresh(" + mode + ")");
	}
	else if(document.getElementById("rubyradio").checked){
		var mode= "ruby";
	}
	else {
		alert("Please select a controller mode from Sahi, Java or Ruby!");
		return;
	}
	sahiSendToServer("/_s_/dyn/Configuration_setControllerMode?mode=" + mode);
	alert("Controller mode set to " + mode + ". Please refresh your browser and restart your Controller.");
}
function changeObjectRepositoryEnable(){
	if(document.getElementById("isOREnabled").checked){
		sahiSendToServer("/_s_/dyn/Configuration_setObjectRepositoryEnable?flag=" + "true");
		if(document.getElementById("fileOR").value != ""){
			var filePath = document.getElementById("fileOR").value;
			sahiSendToServer("/_s_/dyn/Configuration_setObjectRepositoryFile?filePath=" + filePath);
		}
	}	
	else{
		sahiSendToServer("/_s_/dyn/Configuration_setObjectRepositoryEnable?flag=" + "false");
	}
}
function poll() {
	try {
		var json = sahiSendToServer("/_s_/dyn/ControllerUI_getMessageToController");
		// var json =
		// sahiSendToServer("/_s_/dyn/Driver_getLastIdentifiedElement");
		if (json != "") {
			var res = eval("(" + json + ")");
			if (res) {
				if (res.command == "showAccessor") {
					var o = res.value;
					$("orKey").value = o.accessor;
					var seperator = "] ";
					var ix = o.accessors[0].indexOf(seperator);
					var accessorVal = ix<0 ? o.accessors[0] : o.accessors[0].substring(ix + seperator.length);
					displayInfo(o.accessors, accessorVal, o.value, o.popupName);
					isSaveORDisabled();
				} else if (res.command == "showResult") {
					$(res.target).value = "" + res.value;
				} else if (res.command == "showSteps") {
					showSteps(res.value, res.isRecorded);
				} else if (res.command == "setAccessorProps") {
					setAccessorProps(res.value);
				} else if (res.command == "showPosition") {
					showPosition(res.value);
				}
				
				// logs
				if (res.logs) {
					var taLogsValue = $("talogs").value;
					taLogsValue = taLogsValue.replace(/\r/g, '\n').replace(/\n\n/g, '\n');
					if (taLogsValue != res.logs) {
						$("talogs").value = res.logs;
							scrollDown($("talogs"));
					}
				}
				//recorded steps
				if(res.recordedSteps){
					if($("taSteps").value != res.recordedSteps){
						$("taSteps").value = res.recordedSteps;
					}
				}
				if (res.isRecording) {
					disableRecordButton();
				}
			}
		}
	} catch (e) {
		//alert(e);
	}
	window.setTimeout("poll()", 500);
}
/* URL history end */
SahiHashMap = function() {
	this.keys = new Array();
	this.values = new Array();
	this.put = function(k, v) {
		var i = this.getIndex(this.keys, k);
		if (i == -1)
			i = this.keys.length;
		this.keys[i] = k;
		this.values[i] = v;
	}
	this.get = function(k) {
		var i = this.getIndex(this.keys, k);
		return this.values[i];
	}
	this.getIndex = function(ar, k) {
		for ( var i = 0; i < ar.length; i++) {
			if (k === ar[i])
				return i;
		}
		return -1;
	}
}
function Util() {
}
Util.escapeMap = {
	'\b' : '\\b',
	'\t' : '\\t',
	'\n' : '\\n',
	'\f' : '\\f',
	'\r' : '\\r',
	'"' : '\\"',
	'\\' : '\\\\'
};
Util.prototype.toJSON = function(el, map) {
	// try {
	if (!map)
		map = new SahiHashMap();
	var j = map.get(el);
	if (j && j == "___in_progress___") {
		return '"recursive_access"';
	}
	map.put(el, '___in_progress___');
	var v = this.toJSON2(el, map);
	map.put(el, v);
	return v;
	// } catch (e) {
	// return "error during toJSON conversion";
	// }
}
Util.prototype.toJSON2 = function(el, map) {
	if (el == null || el == undefined)
		return 'null';
	if (el instanceof RegExp)
		return el.toString();
	if (el instanceof Date) {
		return String(el);
	} else if (typeof el == 'string') {
		if (/["\\\x00-\x1f]/.test(el)) {
			return '"'
					+ el.replace(/([\x00-\x1f\\"])/g, function(a, b) {
						var c = Util.escapeMap[b];
						if (c) {
							return c;
						}
						c = b.charCodeAt();
						return '\\u00' + Math.floor(c / 16).toString(16)
								+ (c % 16).toString(16);
					}) + '"';
		}
		return '"' + el + '"';
	} else if (el instanceof Array) {
		var ar = [];
		for ( var i = 0; i < el.length; i++) {
			ar[i] = this.toJSON(el[i], map);
		}
		return '[' + ar.join(',') + ']';
	} else if (typeof el == 'number') {
		return new String(el);
	} else if (typeof el == 'boolean') {
		return String(el);
	} else if (el instanceof Object) {
		// if (el.tagName) {
		// var elInfo = this.identify(el, true);
		// if (elInfo == null || elInfo.apis == null) return null;
		// return (elInfo.apis.length > 0) ? "_sahi." +
		// this.escapeDollar(this.getAccessor1(elInfo.apis[0])) : null;
		// } else {
		var ar = [];
		for ( var k in el) {
			var v = el[k];
			if (typeof v != 'function') {
				ar[ar.length] = this.toJSON(k, map) + ':' + this.toJSON(v, map);
			}
		}
		return '{' + ar.join(',') + '}';
		// }
	}
};
function Diagnostics(){}
Diagnostics.prototype.storeDiagnostics = function(){
	if (this.diagnostics) return;
    this.diagnostics = new Object();
    var d = this.diagnostics;
    d["UserAgent"] = navigator.userAgent;
    d["Browser Name"] = navigator.appName;
    d["Browser Version"] = navigator.appVersion.substring(0, navigator.appVersion.indexOf(")")+1);
    d["Native XMLHttpRequest"] = typeof XMLHttpRequest != "undefined";
    d["Java Enabled"] = navigator.javaEnabled();
    d["Cookie Enabled"] =  ("" + document.cookie).indexOf("sahisid") != -1 // navigator.cookieEnabled throws an exception on IE on showModalDialogs.
	this.addDiagnostics("OS");
	this.addDiagnostics("Java");
};
Diagnostics.prototype.addDiagnostics = function(type){
	var s = sahiSendToServer("/_s_/dyn/ControllerUI_get"+type+"Info");		
    if(s){
    	var properties = s.split("_$sahi$_;");
    	for (var i=0; i<properties.length; i++){
    		var prop = properties[i].split("_$sahi$_:");
    		if(prop.length == 2) this.diagnostics[prop[0]] = prop[1];
    	}	
    }	 
};
Diagnostics.prototype.getDiagnostics = function(name){
	if (!this.diagnostics) this.storeDiagnostics();
    if(name){
     	var v = this.diagnostics[name];
     	return (v != null) ? v : "";
    }
    var s = "";
 	for (var key in this.diagnostics){
    	s += key +": "+ this.diagnostics[key]+"\n";
 	}
    return s;
};
var util = new Util();
var diagnostics = new Diagnostics();
