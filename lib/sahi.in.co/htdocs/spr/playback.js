/**
 * Copyright Tyto Software Pvt. Ltd.
 */
__sahiDebug__("playback.js: start");
try {
_sahi.removeEvent(window, "load", Sahi.onWindowLoad);
_sahi.removeEvent(window, "beforeunload", Sahi.onBeforeUnLoad);
_sahi.addEvent(window, "load", Sahi.onWindowLoad);
_sahi.addEvent(window, "beforeunload", Sahi.onBeforeUnLoad);
_sahi.initTimer = window.setTimeout("Sahi.onWindowLoad()", (_sahi.waitForLoad) * _sahi.INTERVAL);
}catch(e){}
if (_sahi.isXHRWrappingEnabled) _sahi.wrapXHRs();
_sahi.ping();

__sahiDebug__("playback.js: end");