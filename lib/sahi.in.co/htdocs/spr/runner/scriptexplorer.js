//var scriptDir = "";
var counter = 1;
var qsParm = new Array();
function s$(id){return document.getElementById(id);}
function getScriptListDir(){
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptDirsListJSON") + ")");
}

function getScriptListFile(dir){
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptsListJSON?suites=true&dir="+dir) + ")");
}

function showAll(){
	qs();
	var search = (typeof qsParm["search"] == "undefined") ? "all" : qsParm["search"];
	showSearch(search);
}

function showSearch(search){
	s$("scriptsList").innerHTML = "";
	var dirs = getScriptListDir();
	for (var i=0; i<dirs.length; i++) {
		var scriptDir = dirs[i];
		var treeObj = {id:1, name:'Scripts', leaf: false, path:scriptDir, children:[], leafNames:{}};
		var scripts = getScriptListFile(scriptDir);
//		alert(scripts);
		for (var j=0; j<scripts.length; j++) {
			if(scripts[j].indexOf(search) != -1 || search == "all")
				addToTree(scripts[j].replace(scriptDir, ""), treeObj, scriptDir);
		}
		s$("scriptsList").innerHTML += "<br><b>Script Path:</b>&nbsp;&nbsp;" + scriptDir + "&nbsp;&nbsp;&nbsp;&nbsp;"+
		"<a title='Create new script' target='_blank' href='/_s_/spr/refactor.htm'>New script</a>" + "&nbsp;&nbsp;"+ "<a title='Create new scenario' target='_blank' href='/_s_/spr/spreadsheet/spreadsheet.html'>New scenario</a>" +"<br><br>" + showTree(treeObj);
	}
}

function formURL(path){
	var browser = s$("browserTxt").value;
	var baseURL = s$("startURLTxt").value;
	var threads = s$("threads").value;
	var extraParamValue = s$("extraParams").value;
	if (extraParamValue.charAt(0) != '&') extraParamValue = '&' + extraParamValue;
	if (browser!=null && browser!="" && baseURL!=null && baseURL!=""){
		var url = "/_s_/dyn/Suite_start?a=a&port=9999&useSingleSession=false&browserPath=null&host=localhost&"
			 + "test=" + encodeURIComponent(path) + "&threads=" + threads + "&logsInfo=&suitePath=" + encodeURIComponent(path) + "&isSingleSessionS=false&"
			 + "baseURL=" + encodeURIComponent(baseURL) + "&browserType=" + browser + extraParamValue;
		sendToServer(url);	 
	} else {
		alert("Browser and Start URL cannot be blank");
		s$("browserTxt").focus();
	}
}

function sendToServer(url){
	var scr = document.createElement('script');
    scr.setAttribute("type", "text/javascript");
    scr.setAttribute("src", url);
    document.getElementsByTagName("head")[0].appendChild(scr);
}

function qs() {
	var query = window.location.search.substring(1);
	var parms = query.split('&');
	for (var i=0; i<parms.length; i++) {
		var pos = parms[i].indexOf('=');
		if (pos > 0) {
			var key = parms[i].substring(0,pos);
			var val = parms[i].substring(pos+1);
			qsParm[key] = val;
		}
	}
}
function addToTree(s, treeObj, dir){
	s = s.replace(/\\/g, "/");
	var ar = s.split("/");
	var parent = treeObj;
	for (var i=0; i<ar.length; i++) {
		var leaf = addLeaf(parent, ar[i],(i == ar.length - 1), s, dir);
		parent = leaf;
	}
}
function addLeaf(parent, s, isLeafNode, path, dir){
	var leaf = parent.leafNames[s];
	if (!leaf) {
		leaf = {id:counter++, name:s, path: path, leaf: isLeafNode, children:[], leafNames:{}, scriptDir: dir};
		parent.children.push(leaf);
		parent.leafNames[s] = leaf;
	}	
	return leaf;
}
var checkedNodes = [];
function showTree(node){
	 var s = attachIcons(node);
	 for (var i=0; i<node.children.length; i++) {
		 s += "<div style='margin-left:10px;padding-left:20px;xborder-left:1px solid red;'>" + showTree(node.children[i]) + "</div>";
	 }
	 return s;
}
function selectedCheckboxes(){
	var scriptListDiv = document.getElementById("scriptsList");
	var checkboxes = scriptListDiv.getElementsByTagName("input");
	for (var i=0, n=checkboxes.length;i<n;i++) {
		if(checkboxes[i].type == 'checkbox'){
			if (checkboxes[i].checked){
				checkedNodes.push(checkboxes[i].id);
			}
		}
	}
}

function runSelectedFilesSuite(){
	selectedCheckboxes();
	if(checkedNodes.length>1){
		var retVal = sahiSendToServer("/_s_/dyn/ControllerUI_getSuiteFile?checkedNodes="+checkedNodes);
		formURL(retVal);
	} else {
		alert("Please more than one script/suite.\n" +
				"If you want to run one script, Click on the play icon near the script/suite name.");
	}
	checkedNodes = [];
}

function attachIcons(node){
	var query = "select * from SUITEREPORTS where suiteName like '" + node.name + "' order by startTime desc limit 50";
	 var logsUrl = "/_s_/dyn/pro/DBReports?sql=" + encodeURIComponent(query);
	 if(node.path.match(".s.csv$") == ".s.csv" || node.path.match(".xls$") == ".xls" || node.path.match(".xlsx$") == ".xlsx"){
		 var editURL = "../spreadsheet/spreadsheet.html?dir=" + encodeURIComponent(node.scriptDir) + "&file=" + encodeURIComponent(node.path);
	 }
	 else if(node.path.match(".dd.csv$") == ".dd.csv"){
		 var editURL = "../spreadsheet/ddcsv_spreadsheet.html?dir=" + encodeURIComponent(node.scriptDir) + "&file=" + encodeURIComponent(node.path);
	 }
	 else{
		 var editURL = "../refactor.htm?dir=" + encodeURIComponent(node.scriptDir) + "&file=" + encodeURIComponent(node.path);
	 }
	 var docsUrl = "/_s_/spr/docview/docviewer.htm?dir=" + encodeURIComponent(node.scriptDir) + "&file=" + encodeURIComponent(node.path);
	 var editIcon = "<a class='edit-link' href='" + editURL + "' target='_blank'><img src='../images/icon_edit.gif'/></a>";
	 var playIcon = ((typeof node.path != "undefined") ? "<img style='margin-right:10px;cursor:pointer;' src='../images/media-playback-start.png'" +
	 		        " onclick='formURL(\"" + (node.scriptDir + "/" + node.path).replace(/\\/g, "/") + "\")'>" : "");
	 var logsIcon = "<a href=\"" + logsUrl + "\" target='_blank'>View Logs</a>";
	 if(node.path.indexOf('.sah', node.path.length - '.sah'.length) == -1)
		 var docsIcon = "<a href=\"" + "javascript: void(0)" + "\" style='pointer-events:none; background-color:lightgray;'>View Docs</a>";
	 else
		 var docsIcon = "<a href=\"" + docsUrl + "\" target='_blank'>View Docs</a>";
	 var treeStyle = (node.leaf) ? "tree-file" : "tree-expanded";
	 var folderIcon = (node.leaf) ? "" : "<span class='tree-folder'></span>"; 
	 var checkboxFile = (node.leaf) ? "<input type='checkbox' id='"+ node.scriptDir + node.path +"'>" : "";
	 var iconList = (node.leaf) ? "<div style='float:right'>&nbsp;&nbsp;" +  playIcon + "&nbsp;&nbsp;" +
	         		 editIcon + "&nbsp;&nbsp;" + logsIcon + "&nbsp;&nbsp;" + docsIcon + "</div>" : "";
	 return "<div style='border-bottom:1px solid #ccc;line-height:20px;'>" + checkboxFile + iconList + "<span class='" + treeStyle + "'></span>" + folderIcon + "&nbsp;" +
	 node.name  + "</div>";
}
var _historyURLs = null;
function getURLs(s) {
	if (!_historyURLs) _historyURLs  = loadURLs(); // ["aa", "bb"]; 
	var urls = _historyURLs;
	var options = new Array();
	for (var i = 0; i < urls.length; i++) {
		if (urls[i].indexOf(s) != -1)
			options[options.length] = new Option(urls[i], urls[i]);
	}
	return options;
}
var _browsers = null;
function getBrowsers(s) {
	if (!_browsers) _browsers = loadBrowsers(); 
	var browsers = _browsers;
	var options = new Array();
	for (var i = 0; i < browsers.length; i++) {
		if (browsers[i].indexOf(s) != -1)
			options[options.length] = new Option(browsers[i], browsers[i]);
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
	for (var i = 0; i < _historyURLs.length; i++) {
		if (url == _historyURLs[i])
			return false;
	}
	return true;
}
function saveURL(url) {
	if (shouldAdd(url)){
		_historyURLs.push(url);
		sahiSendToServer("/_s_/dyn/ControllerUI_addURLHistory?url=" + encodeURIComponent(url));
	}
}

function loadBrowsers() {
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_getBrowserList")
			+ ")");
}