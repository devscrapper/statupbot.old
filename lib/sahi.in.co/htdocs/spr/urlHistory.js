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
function loadURLs() {
	return eval("("
			+ sahiSendToServer("/_s_/dyn/ControllerUI_getURLHistory")
			+ ")");
}
function shouldAdd(url) {
	if (url == "" || url.value == "http://") return false;
	for ( var i = 0; i < _historyURLs.length; i++) {
		if (url == _historyURLs[i])
			return false;
	}
	return true;
}
function saveURL(url) {
	if (shouldAdd(url)) {
		_historyURLs.push(url);
		sahiSendToServer("/_s_/dyn/ControllerUI_addURLHistory?url="+ encodeURIComponent(url));
	}
	sahiSendToServer("/_s_/dyn/ControllerUI_addURLHistoryForSslHostPortUrlsIfNotExists?url="+ encodeURIComponent(url));
}