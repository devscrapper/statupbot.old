/**
 * Copyright Tyto Software Pvt. Ltd.
 */
__sahiDebug__("state.js: start");
try {
    _sahi.sid = '$sessionId';
    _sahi.setSahiCookieOnAllPages = $setSahiCookieOnAllPages;
    _sahi.isWinOpen = $isWindowOpen;
    _sahi.createSahiCookie();
    _sahi.setState({isPlaying:$isSahiPlaying, isPaused:$isSahiPaused, isRecording:$isSahiRecording});
    
    _sahi.hotKey = '$hotkey';

    _sahi.INTERVAL = $interval;
    _sahi.ONERROR_INTERVAL = $onErrorInterval;
    _sahi.MAX_RETRIES = $maxRetries;
    _sahi.SAHI_MAX_WAIT_FOR_LOAD = $maxWaitForLoad;

    _sahi.waitForLoad = _sahi.SAHI_MAX_WAIT_FOR_LOAD;
    _sahi.interval = _sahi.INTERVAL;

    _sahi.__scriptName =  "$scriptName";
    _sahi.__scriptPath =  "$scriptPath";

    _sahi.strictVisibilityCheck = $strictVisibilityCheck;
    _sahi.STABILITY_INDEX = $stabilityIndex;
    _sahi.controllerMode = "$controllerMode";
    _sahi.setWaitForXHRReadyStates("$waitReadyStates");
    _sahi.escapeUnicode = $escapeUnicode;
    _sahi.commonDomain = "$commonDomain";
    _sahi.ignorableIdsPattern = new RegExp('$ignorableIdsPattern');
    _sahi.chromeExplicitCheckboxRadioToggle = $chromeExplicitCheckboxRadioToggle;
    _sahi.strictVisibilityCheck = $strictVisibilityCheck;
    _sahi.isSingleSession = $isSingleSession;
    var o_fn1 = function(o){try{return o._sahi_getFlexId();}catch(e){}};
	var o_fn2 = function(o){try{return o._sahi_getUID();}catch(e){}};
    _sahi.accessors_metadata = $accessors_metadata;
    _sahi.init();
    // Pro start
    _sahi.accessors_applet_metadata = $accessors_applet_metadata;
    _sahi.accessors_flex_metadata = $accessors_flex_metadata;
    _sahi.isOREnabled = true;//$isOREnabled;
    _sahi.browserType = '$browserType';
    _sahi.isXHRWrappingEnabled = $isXHRWrappingEnabled;
    
    _sahi.orFileContentStr = '$orFileContentStr';
    if (window == _sahi.top()) {
    	_sahi.orFileContentAr = _sahi.extractORFileContent(_sahi.orFileContentStr);
    }
    _sahi.displayAttrType = '$displayAttrType';
    
} catch(e) {
	__sahiDebug__("exception occured: " + e);
}
__sahiDebug__("state.js: end");
