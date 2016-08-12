__sahiDebug__("concat.js: start");
"undefined" == typeof console && (console = {
    log: function (a) {
    }
});
var Sahi = function () {
    this.triggerType = "mouseup";
    this.mouseDownEl = null;
    this.cmds = [];
    this.cmdDebugInfo = [];
    this.cmdsLocal = [];
    this.cmdDebugInfoLocal = [];
    this.promptReturnValue = [];
    this.locals = [];
    this.INTERVAL = 100;
    this.IDLE_PING_INTERVAL = 800;
    this.ONERROR_INTERVAL = 1E3;
    this.MAX_RETRIES = 5;
    this.SAHI_MAX_WAIT_FOR_LOAD = 30;
    this.STABILITY_INDEX = 5;
    this.waitForLoad = this.SAHI_MAX_WAIT_FOR_LOAD;
    this.interval = this.INTERVAL;
    this.localIx = 0;
    this.buffer = "";
    this.execSteps = this.lastAccessedInfo = this.controller = null;
    this.sahiBuffer =
        "";
    this.real_alert = window.alert;
    this.real_confirm = window.confirm;
    this.real_prompt = window.prompt;
    this.real_print = window.print;
    this.wrapped = [];
    this.mockDialogs(window);
    this.lastQs = "";
    this.lastTime = 0;
    this.lastRecEl = null;
    this.XHRs = [];
    this.XHRTimes = [];
    this.escapeMap = {"\b": "\\b", "\t": "\\t", "\n": "\\n", "\f": "\\f", "\r": "\\r", '"': '\\"', "\\": "\\\\"};
    this.lastStepId = 0;
    this.isSingleSession = this.strictVisibilityCheck = !1;
    this.ADs = [];
    this.controllerURL = "/_s_/dyn/ControllerUI";
    this.controllerHeight = 550;
    this.controllerWidth =
        480;
    this.recorderClass = "Recorder";
    this.stabilityIndex = this.STABILITY_INDEX;
    this.xyoffsets = new Sahi.Dict;
    this.escapeUnicode = !1;
    this.CHECK_REGEXP = /^\/.*\/i?$/;
    this.navigator = {userAgent: navigator.userAgent, appName: navigator.appName, appVersion: navigator.appVersion};
    this.textboxTypes = "text number password textarea date datetime datetime-local email month number range search tel time url week".split(" ");
    this.newTextboxTypes = "text number date datetime datetime-local email month number range search tel time url week".split(" ");
    this.isOREnabled = !1;
    this.browserType = "";
    this.lookInside = null;
    this._isRecording = this._isPlaying = !1;
    this.orFilePath = "";
    this._isOR = !1;
    this.DEFAULT_IMAGE_COMPARISON_THRESHOLD = 20
};
Sahi.prototype.isBlankOrNull = function (a) {
    return "" == a || null == a
};
Sahi.Dict = function () {
    this.keys = [];
    this.values = [];
    this.put = function (a, b) {
        this.keys.push(a);
        this.values.push(b)
    };
    this.get = function (a) {
        for (var b = 0; b < this.keys.length; b++)if (this.keys[b] === a)return this.values[b]
    }
};
Sahi.BLUR_TIMEOUT = 5E3;
Sahi.DRAG_DROP_SPEED = 1;
Sahi.DRAG_DROP_SEGMENTS = 200;
Sahi.DRAG_DROP_WAVER = 1;
Sahi.DRAG_DROP_MAX_HOVER_AT_END = 5;
Sahi.prototype.storeDiagnostics = function () {
    if (!this.diagnostics) {
        var a = this.diagnostics = {};
        a.UserAgent = navigator.userAgent;
        a["Browser Name"] = navigator.appName;
        a["Browser Version"] = navigator.appVersion.substring(0, navigator.appVersion.indexOf(")") + 1);
        a["Native XMLHttpRequest"] = "undefined" != typeof XMLHttpRequest;
        a["Java Enabled"] = navigator.javaEnabled();
        a["Cookie Enabled"] = -1 != ("" + document.cookie).indexOf("sahisid");
        this.addDiagnostics("OS");
        this.addDiagnostics("Java")
    }
};
Sahi.prototype.addDiagnostics = function (a) {
    if (a = this.sendToServer("/_s_/dyn/ControllerUI_get" + a + "Info")) {
        a = a.split("_$sahi$_;");
        for (var b = 0; b < a.length; b++) {
            var c = a[b].split("_$sahi$_:");
            2 == c.length && (this.diagnostics[c[0]] = c[1])
        }
    }
};
Sahi.prototype.getDiagnostics = function (a) {
    this.diagnostics || this.storeDiagnostics();
    if (a) {
        var b = this.diagnostics[a];
        return null != b ? b : ""
    }
    a = "";
    for (b in this.diagnostics)a += b + ": " + this.diagnostics[b] + "\n";
    return a
};
Sahi.prototype.wrap = function (a) {
    var b = this;
    null == this.wrapped[a] && (this.wrapped[a] = function () {
        return a.apply(b, arguments)
    });
    return this.wrapped[a]
};
Sahi.prototype.isLogJsPopups = function () {
    return "true" == this.sendToServer("/_s_/dyn/Configuration_logJsPopups") ? !0 : !1
};
Sahi.prototype.getLogJsPopupsColor = function () {
    var a = this.sendToServer("/_s_/dyn/Configuration_getLogJsPopupColor");
    return "" == a ? !1 : a
};
Sahi.prototype.alertMock = function (a) {
    if (this.isPlaying())this.sendToServer("/_s_/dyn/SessionState_setSessionAlert?value\x3d" + this.encode(this.toJSON(a))), this.isLogJsPopups() && this.log("alert: " + a, this.getLogJsPopupsColor()); else return this.isRecording() && this.recordStep(this.getAlertAssert(a), !1, void 0, void 0, void 0, !1), this._alert(a)
};
Sahi.prototype.confirmMock = function (a) {
    if (this.isPlaying()) {
        var b = this.sendToServer("/_s_/dyn/SessionState_getExpectConfirm?text\x3d" + this.encode(a)), b = "false" != b;
        this.sendToServer("/_s_/dyn/SessionState_setSessionConfirm?value\x3d" + this.encode(this.toJSON(a)));
        this.isLogJsPopups() && this.log("confirm: " + a, this.getLogJsPopupsColor())
    } else b = this.callFunction(this.real_confirm, window, a), this.isRecording() && ("java" == _sahi.controllerMode || "ruby" == _sahi.controllerMode ? this.recordStep(this.getExpectConfirmScript(a,
            b) + " \n\x3cbr\x3e\n" + this.getExpectConfirmAssert(a), !1, void 0, void 0, void 0, !0) : (this.recordStep(this.getExpectConfirmScript(a, b), !1, void 0, void 0, void 0, !0), this.recordStep(this.getExpectConfirmAssert(a), !1, void 0, void 0, void 0, !1)));
    return b
};
Sahi.prototype.getExpectPromptAssert = function (a) {
    return "_assertEqual(" + this.quotedEscapeValue(a) + ", _lastPrompt());"
};
Sahi.prototype.getExpectPromptScript = function (a, b) {
    return null === b ? "_expectPrompt(" + this.quotedEscapeValue(a) + ", " + b + ")" : "_expectPrompt(" + this.quotedEscapeValue(a) + ", " + this.quotedEscapeValue(b) + ")"
};
Sahi.prototype.getExpectConfirmAssert = function (a) {
    return "_assertEqual(" + this.quotedEscapeValue(a) + ", _lastConfirm());"
};
Sahi.prototype.getExpectConfirmScript = function (a, b) {
    return "_expectConfirm(" + this.quotedEscapeValue(a) + ", " + b + ");"
};
Sahi.prototype.getAlertAssert = function (a) {
    return "_assertEqual(" + this.quotedEscapeValue(a) + ", _lastAlert());"
};
Sahi.prototype.getNavigateToScript = function (a) {
    return "_navigateTo(" + this.quotedEscapeValue(a) + ");"
};
Sahi.prototype.getUserAgentScript = function (a) {
    return '_setHttpHeader("User-Agent", ' + this.quotedEscapeValue(a) + ");"
};
Sahi.prototype.getNavigateToWithSizeScript = function (a, b, c) {
    return "_openWindow(" + this.quotedEscapeValue(a) + "," + this.quotedEscapeValue(b) + ",[" + c + "]);\n_selectWindow(" + this.quotedEscapeValue(b) + ");"
};
Sahi.prototype.promptMock = function (a, b) {
    if (this.isPlaying()) {
        var c = this.sendToServer("/_s_/dyn/SessionState_getExpectPrompt?text\x3d" + this.encode(a));
        null == c && (c = "");
        this.sendToServer("/_s_/dyn/SessionState_setSessionPrompt?value\x3d" + this.encode(this.toJSON(a)));
        this.isLogJsPopups() && this.log("prompt: " + a, this.getLogJsPopupsColor());
        return "sahi__null__prompt" == c ? null : c
    }
    c = [];
    c.push(a);
    null != b && "undefined" != b && c.push(b);
    c = this.callFunction(this.real_prompt, window, c);
    "java" == _sahi.controllerMode || "ruby" ==
    _sahi.controllerMode ? this.recordStep(this.getExpectPromptScript(a, c) + " \n\x3cbr\x3e\n" + this.getExpectPromptAssert(a), void 0, void 0, void 0, void 0, !0) : (this.recordStep(this.getExpectPromptScript(a, c), void 0, void 0, void 0, void 0, !0), this.recordStep(this.getExpectPromptAssert(a), void 0, void 0, void 0, void 0, !1));
    return c
};
Sahi.prototype.printMock = function () {
    return this.isPlaying() ? (this.setServerVar("printCalled", !0), null) : this.callFunction(this.real_print, window)
};
Sahi.prototype.mockDialogs = function (a) {
    a.alert = this.wrap(this.alertMock);
    a.confirm = this.wrap(this.confirmMock);
    a.prompt = this.wrap(this.promptMock);
    a.print = this.wrap(this.printMock)
};
var _sahi = new Sahi, tried = !1;
_sahi.oldDocDomain = document.domain;
_sahi.__top = window.top;
_sahi.selfWin = window;
_sahi.windowWin = window;
_sahi.parentWin = window.parent;
Sahi.prototype.self = function () {
    return _sahi.selfWin
};
Sahi.prototype.parent = function () {
    return _sahi.parentWin
};
Sahi.prototype.top = function () {
    return this.findFirstAccessibleFrame(this.absoluteTop())
};
Sahi.prototype.absoluteTop = function () {
    return document.domain == this.oldDocDomain ? this.__top : window.top
};
Sahi.prototype.isWindowAccessible = function (a) {
    if (window == a)return !0;
    try {
        if (a.location.protocol)return !0
    } catch (b) {
        b = null
    }
    return !1
};
Sahi.prototype.findFirstAccessibleFrame = function (a) {
    if (this.isWindowAccessible(a))return a;
    for (var b = 0; b < a.frames.length; b++) {
        var c = this.findFirstAccessibleFrame(a.frames[b]);
        if (c)return c
    }
    return null
};
Sahi.prototype.getKnownTags = function (a) {
    for (; ;) {
        if (!a)return a;
        if (!a.tagName)return null;
        var b = a.tagName.toLowerCase();
        if ("html" == b || "body" == b)return null;
        for (var c = 0; c < this.ADs.length; c++)if (this.ADs[c].tag.toLowerCase() == b)return a;
        a = a.parentNode
    }
};
Sahi.prototype.byId = function (a) {
    a = a.id;
    return this.isBlankOrNull(a) ? "" : "getElementById('" + a + "')"
};
Sahi.prototype.getLink = function (a) {
    for (var b = this.getElementsByTagName("A", window.document), c = 0; c < b.length; c++)if (b[c] == a)return "links[" + c + "]";
    return null
};
Sahi.prototype.getElementsByTagName = function (a, b) {
    return b.getElementsByTagName(a.toLowerCase())
};
Sahi.prototype.areTagNamesEqual = function (a, b) {
    return a == b ? !0 : null == a || null == b ? !1 : a.toLowerCase() == b.toLowerCase()
};
Sahi.prototype.getImg = function (a) {
    for (var b = window.document.images, c = 0; c < b.length; c++)if (b[c] == a)return "images[" + c + "]";
    return null
};
Sahi.prototype.getForm = function (a) {
    if (!this.isBlankOrNull(a.name) && this.nameNotAnInputElement(a))return "forms['" + a.name + "']";
    for (var b = window.document.forms, c = 0; c < b.length; c++)if (b[c] == a)return "forms[" + c + "]";
    return null
};
Sahi.prototype.nameNotAnInputElement = function (a) {
    return "object" != typeof a.name
};
Sahi.prototype._getScreenSize = function () {
    var a = [];
    a[0] = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    a[1] = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    return a
};
Sahi.prototype._getTableContents = function (a, b, c, d) {
    if (null == a)return null;
    var e = [], f = a.rows;
    for (a = 0; a < f.length; a++) {
        e[a] = [];
        for (var h = f[a].cells, g = 0; g < h.length; g++)e[a][g] = this._getText(h[g])
    }
    if (null == b)return e;
    var h = e[0], f = [], k = 0;
    for (a = 0; a < b.length; a++)if (!1 == isNaN(b[a]))f[k] = b[a], k++; else for (g = 0; g < h.length; g++)this.areEqualParams(h[g], this.checkRegex(b[a])) && -1 == this.findInArray(f, g) && (f[k] = g, k++);
    if (null == c || void 0 === c) {
        b = [];
        c = e.length;
        for (a = 0; a < c; a++)for (b[a] = [], g = 0; g < f.length; g++)b[a][g] = e[a][f[g]];
        return b
    }
    b = [];
    if (!1 == isNaN(c) && null != d && void 0 !== d) {
        var l = 0;
        for (a = c; a < d && a < e.length; a++) {
            b[l] = [];
            for (g = 0; g < f.length; g++)b[l][g] = e[a][f[g]];
            l++
        }
        return b
    }
    if (this.checkRegex(c)instanceof RegExp || "string" == typeof this.checkRegex(c))for (l = [], a = b = 0; a < e.length; a++) {
        h = e[a];
        for (g = 0; g < h.length; g++)if (this.areEqualParams(e[a][g], this.checkRegex(c))) {
            l[b] = a;
            b++;
            break
        }
        if (null != d && void 0 !== d && b >= parseInt(d))break
    } else c instanceof Array && (l = c);
    b = [];
    for (a = 0; a < l.length; a++)for (b[a] = [], g = 0; g < f.length; g++)b[a][g] =
        e[l[a]][f[g]];
    return b
};
Sahi.prototype.getTableContentsArray = function (a, b, c, d) {
    a = this._getTableContents(a, b, c, d);
    b = [];
    for (c = 0; c < a.length; c++)b[c] = a[c].join("_column_");
    return b
};
Sahi.prototype.getArrayElement = function (a, b) {
    var c = b.tagName.toLowerCase();
    if ("input" == c || "textarea" == c || -1 != c.indexOf("select")) {
        c = eval(a);
        if (c == b)return a;
        var d = -1;
        if (c && c.length)return d = this.findInArray(c, b), a + "[" + d + "]"
    }
    return a
};
Sahi.prototype.getEncapsulatingLink = function (a) {
    return this.areTagNamesEqual(a.tagName, "A") || this.areTagNamesEqual(a.tagName, "AREA") ? a : this._parentNode(a, "A")
};
Sahi.prototype.linkClick = function (a) {
    a || (a = window.event);
    var b = !0, c = this.getTarget(a);
    this.lastLink = this.getEncapsulatingLink(c);
    if (this.lastLink.__sahi__prevClick)try {
        b = this.lastLink.__sahi__prevClick.apply(this.lastLink, arguments)
    } catch (d) {
    }
    this.lastLinkEvent = a;
    if (!1 != b && null != this.lastLink.getAttribute("href"))window.setTimeout(function () {
        _sahi.navigateLink()
    }, 0); else return !1
};
Sahi.prototype._dragDrop = function (a, b, c, d) {
    if (this.isFlexObj(a))return b.setAsDroppable(), a.dragDrop();
    this.fork(3E4);
    this.checkNull(a, "_dragDrop", 1, "draggable");
    this.checkNull(b, "_dragDrop", 2, "droppable");
    this.dragDropXYCommon(a, b, c, d, "DROP_RELATIVE")
};
Sahi.prototype.addBorder = function (a) {
    a.style.border = "1px solid red"
};
Sahi.prototype.getScrollOffsetY = function () {
    return document.body.scrollTop ? document.body.scrollTop : document.documentElement && document.documentElement.scrollTop ? document.documentElement.scrollTop : window.pageYOffset ? window.pageYOffset : window.scrollY ? window.scrollY : 0
};
Sahi.prototype.getScrollOffsetX = function () {
    return document.body.scrollLeft ? document.body.scrollLeft : document.documentElement && document.documentElement.scrollLeft ? document.documentElement.scrollLeft : window.pageXOffset ? window.pageXOffset : window.scrollX ? window.scrollX : 0
};
Sahi.prototype._dragDropXY = function (a, b, c, d) {
    this.fork(3E4);
    if (this.isFlexObj(a))return a.dragDropXY(b, c);
    this.checkNull(a, "_dragDropXY", 1, "draggable");
    return this.dragDropXYCommon(a, null, b, c, d ? "DRAG_RELATIVE" : !1)
};
var SahiDTProxy = function () {
    this.data = {}
};
SahiDTProxy.prototype.setData = function (a, b) {
    this.data[a] = b;
    return !0
};
SahiDTProxy.prototype.getData = function (a) {
    return this.data[a]
};
SahiDTProxy.prototype.clearData = function (a) {
    a ? delete this.data[a] : this.data = {}
};
Sahi.DragDropper = function (a, b, c, d, e) {
    this.draggable = a;
    this.droppable = b;
    this.offsetX = c;
    this.offsetY = d;
    this.isRelative = e;
    this.start = function () {
        this.dataTransfer = new SahiDTProxy;
        _sahi.simulateMouseEvent(this.draggable, "mouseover");
        _sahi.simulateMouseEvent(this.draggable, "mousemove");
        _sahi.simulateMouseEvent(this.draggable, "mousedown");
        _sahi.simulateMouseEvent(this.draggable, "mousemove");
        _sahi.simulateDragEvent(this.draggable, "dragstart", this.dataTransfer);
        _sahi.simulateDragEvent(this.draggable, "drag",
            this.dataTransfer);
        var a = _sahi.findClientPosWithOffset(this.draggable);
        this.initPos = a;
        this.initX = a[0];
        this.initY = a[1];
        this.stage = this.destY = this.destX = 0;
        this.segments = Sahi.DRAG_DROP_SEGMENTS;
        this.endHoverCount = 0;
        this.lastMovedEl = null
    };
    this.execute = function () {
        this.start();
        this.proceed()
    };
    this.proceed = function () {
        if (this.stage < this.segments) {
            this.stage++;
            this.move(this.stage);
            var a = this;
            window.setTimeout(function () {
                a.proceed()
            }, Sahi.DRAG_DROP_SPEED)
        } else this.endHoverCount++ < Sahi.DRAG_DROP_MAX_HOVER_AT_END ?
            (this.move(this.stage), a = this, window.setTimeout(function () {
                a.proceed()
            }, Sahi.DRAG_DROP_SPEED)) : (this.finish(), _sahi.afterEval())
    };
    this.move = function (a) {
        var b = [0, 0];
        "DRAG_RELATIVE" == this.isRelative ? b = this.initPos : "DROP_RELATIVE" == this.isRelative && (b = _sahi.findClientPosWithOffset(this.droppable));
        this.destX = b[0] + (this.offsetX ? this.offsetX : 0);
        this.destY = b[1] + (this.offsetY ? this.offsetY : 0);
        b = Math.floor(this.initX + a * (this.destX - this.initX) / this.segments);
        a = Math.floor(this.initY + a * (this.destY - this.initY) /
            this.segments + (0 == a % 2 ? Sahi.DRAG_DROP_WAVER : 0));
        var c = document.elementFromPoint(b, a);
        if (null != c)try {
            this.lastMovedEl != c && (this.lastMovedEl && (_sahi.simulateMouseEventXY(this.lastMovedEl, "mouseout", b, a), _sahi.simulateDragEventXY(this.lastMovedEl, "dragleave", b, a, this.dataTransfer)), _sahi.simulateMouseEventXY(c, "mouseenter", b, a), _sahi.simulateMouseEventXY(c, "mousemove", b, a), _sahi.simulateMouseEventXY(c, "mouseover", b, a), _sahi.simulateMouseEventXY(c, "mousemove", b, a), _sahi.simulateDragEventXY(c, "dragenter",
                b, a, this.dataTransfer), this.lastMovedEl = c);
            try {
                _sahi.simulateMouseEventXY(this.draggable, "mousemove", b, a), _sahi.simulateMouseEventXY(c, "mousemove", b, a)
            } catch (d) {
                _sahi._debug(d)
            }
            _sahi.simulateDragEventXY(this.draggable, "drag", b, a, this.dataTransfer);
            _sahi.simulateDragEventXY(c, "dragover", b, a, this.dataTransfer)
        } catch (e) {
            _sahi._debug(e)
        }
    };
    this.finish = function () {
        var a = this.destX, b = this.destY;
        this.droppable && _sahi.simulateMouseEventXY(this.droppable, "mousemove", a, b);
        _sahi.simulateMouseEventXY(this.draggable,
            "mousemove", a, b);
        _sahi.simulateDragEventXY(this.draggable, "drag", a, b, this.dataTransfer);
        this.droppable && this.lastMovedEl != this.droppable && (_sahi.simulateMouseEventXY(this.lastMovedEl, "mouseout", a, b), _sahi.simulateDragEventXY(this.lastMovedEl, "dragleave", a, b, this.dataTransfer), _sahi.simulateDragEventXY(this.droppable, "dragenter", a, b, this.dataTransfer), _sahi.simulateMouseEventXY(this.droppable, "mouseover", a, b));
        _sahi.simulateDragEventXY(this.draggable, "drag", a, b, this.dataTransfer);
        this.droppable && (_sahi.simulateDragEventXY(this.droppable,
            "dragover", a, b, this.dataTransfer), _sahi.simulateMouseEventXY(this.droppable, "mouseup", a, b));
        _sahi.simulateMouseEventXY(this.draggable, "mouseup", a, b);
        this.droppable && _sahi.simulateDragEventXY(this.droppable, "drop", a, b, this.dataTransfer);
        try {
            _sahi.simulateDragEventXY(this.draggable, "dragend", a, b, this.dataTransfer), _sahi.simulateMouseEventXY(this.draggable, "click", a, b), _sahi.simulateMouseEventXY(this.draggable, "mousemove", a, b), _sahi.simulateMouseEventXY(this.draggable, "mouseout", a, b)
        } catch (c) {
            _sahi._debug(c)
        }
    }
};
Sahi.prototype.dragDropXYCommon = function (a, b, c, d, e) {
    (new Sahi.DragDropper(a, b, c, d, e)).execute()
};
Sahi.prototype.checkNull = function (a, b, c, d) {
    if (null == a || !this._exists(a))throw a = Error("The " + (1 == c ? "first " : 2 == c ? "second " : 3 == c ? "third " : "") + "parameter passed to " + b + " was not found on the browser"), a.isSahiError = !0, a;
};
Sahi.prototype.checkVisible = function (a) {
    if (this.topSahi().strictVisibilityCheck && !this._isVisible(a))throw"" + a + " is not visible";
};
Sahi.prototype.checkElementVisible = function (a) {
    return !this.topSahi().strictVisibilityCheck || a.type && "hidden" == a.type ? !0 : this._isVisible(a)
};
Sahi.prototype._setStrictVisibilityCheck = function (a, b) {
    this.isFlexObj(b) ? b.setStrictVisibility(a) : (this.setServerVar("strictVisibilityCheck", a), this.topSahi().strictVisibilityCheck = a)
};
Sahi.prototype._isVisible = function (a, b, c) {
    if (null == b || void 0 == b)b = !1;
    if (null == c || void 0 == c)c = !1;
    if (this.isFlexObj(a))return a.isVisible();
    try {
        if (b)var d = this.getWindow(a), e = this.isElementOnTop(a, d, c);
        if (null == a)return !1;
        c = a;
        for (d = !0; null != a;) {
            d = d && this.isStyleDisplay(a);
            if (!d || a.parentNode == a || this.areTagNamesEqual(a.tagName, "BODY") || this.areTagNamesEqual(a.tagName, "FRAMESET"))break;
            a = a.parentNode
        }
        a = c;
        return b ? d && this.isStyleVisible(a) && e : d && this.isStyleVisible(a)
    } catch (f) {
        return !1
    }
};
Sahi.prototype._exists = function (a) {
    return this.isFlexObj(a) || this.isApplet(a) ? a.exists() : null != a
};
Sahi.prototype.isStyleDisplay = function (a) {
    a = this._style(a, "display");
    return null == a || "none" != a
};
Sahi.prototype.isElementOnTop = function (a, b, c) {
    c && a.scrollIntoView();
    c = _sahi._position(a, !0);
    endWidth = a.offsetWidth + c[0];
    endHeight = a.offsetHeight + c[1];
    for (var d = c[0]; d < endWidth; d++)for (var e = c[1]; e < endHeight; e++) {
        var f = b.document.elementFromPoint(d, e);
        if (this._contains(a, f))return !0
    }
    return !1
};
Sahi.prototype.getCenterElement = function (a, b) {
    return a.document.elementFromPoint(p[0] + (0 == b.offsetWidth % 2 ? b.offsetWidth / 2 : (b.offsetWidth - 1) / 2), p[1] + (0 == b.offsetHeight % 2 ? b.offsetHeight / 2 : (b.offsetHeight - 1) / 2) + 0.5)
};
Sahi.prototype.isStyleVisible = function (a) {
    for (; null != a;) {
        var b = this._style(a, "visibility");
        if ("hidden" == b)return !1;
        if ("visible" == b)break;
        if (a.parentNode == a || this.areTagNamesEqual(a.tagName, "BODY") || this.areTagNamesEqual(a.tagName, "FRAMESET"))break;
        a = a.parentNode
    }
    return !0
};
Sahi.prototype.invokeLastBlur = function () {
    return this.lastBlurFn ? (window.clearTimeout(this.lastBlurTimeout), this.doNotRecord = !0, this.lastBlurFn(), this.doNotRecord = !1, this.lastBlurFn = null, !0) : !1
};
Sahi.prototype.setLastBlurFn = function (a) {
    this.lastBlurTimeout && window.clearTimeout(this.lastBlurTimeout);
    this.lastBlurFn = a;
    this.lastBlurTimeout = window.setTimeout(this.wrap(this.invokeLastBlur), Sahi.BLUR_TIMEOUT)
};
Sahi.prototype._startLookInside = function (a) {
    this.lookInside = a
};
Sahi.prototype._stopLookInside = function () {
    this.lookInside = null
};
Sahi.prototype._activeElement = function (a) {
    a || (a = this.top());
    a = a.document.activeElement;
    var b = a.tagName.toLowerCase();
    return "iframe" == b || "frame" == b ? this._activeElement(a.contentWindow) : a
};
Sahi.prototype._getDB = function (a, b, c, d) {
    return new Sahi.dB(a, b, c, d, this)
};
Sahi.dB = function (a, b, c, d, e) {
    this.driver = a;
    this.jdbcurl = b;
    this.username = c;
    this.password = d;
    this.select = function (a) {
        return eval(e._callServer("net.sf.sahi.plugin.DBClient_select", "driver\x3d" + this.driver + "\x26jdbcurl\x3d" + this.jdbcurl + "\x26username\x3d" + this.username + "\x26password\x3d" + this.password + "\x26sql\x3d" + a))
    };
    this.update = function (a) {
        return eval(e._callServer("net.sf.sahi.plugin.DBClient_execute", "driver\x3d" + this.driver + "\x26jdbcurl\x3d" + this.jdbcurl + "\x26username\x3d" + this.username + "\x26password\x3d" +
            this.password + "\x26sql\x3d" + a))
    }
};
Sahi.prototype.getWebkitVersion = function () {
    /AppleWebKit\/(.*) \(/.test(this.navigator.userAgent);
    return RegExp.$1
};
Sahi.prototype.getChromeBrowserVersion = function () {
    /Chrome\/(.*) /.test(this.navigator.userAgent);
    return RegExp.$1
};
Sahi.prototype.addOffset = function (a, b) {
    var c = b[0], d = b[1], e = this.xyoffsets.get(a);
    e || (e = [2, 2]);
    if (e) {
        var f = e[0];
        if (0 > f) {
            var h = parseInt(this._style(a, "width"));
            "NaN" != "" + h && (f = h + f)
        }
        c += f;
        e = e[1];
        0 > e && (f = parseInt(this._style(a, "height")), "NaN" != "" + f && (e = f + e));
        d += e
    }
    return [c, d]
};
Sahi.prototype._position = function (a, b) {
    if (this.isFlexObj(a)) {
        var c = a.getGlobalXY(), d = this.findClientPos(a.object);
        return [c[0] + d[0], c[1] + d[1]]
    }
    return b ? this.findClientPos(a) : this.findPos(a)
};
Sahi.prototype.findClientPos = function (a) {
    if ("function" == typeof a.getBoundingClientRect)return a = a.getBoundingClientRect(), [Math.round(a.left), Math.round(a.top)];
    a = this.findPos(a);
    return [a[0] - this.getScrollOffsetX(), a[1] - this.getScrollOffsetY()]
};
Sahi.prototype.findClientPosWithOffset = function (a) {
    return this.addOffset(a, this._position(a, !0))
};
Sahi.prototype.findPos = function (a, b) {
    var c = a, d = 0, e = 0;
    if (c.offsetParent)for (; c;) {
        if (this.areTagNamesEqual(c.tagName, "MAP")) {
            var f = this.getBlankResult(), c = this.findTagHelper("#" + c.name, this.getDomRelAr(this.getWindow(c)), "IMG", f, "useMap").element;
            if (null == c)break
        }
        d += c.offsetLeft;
        e += c.offsetTop;
        c = c.offsetParent
    } else c.x && (d = c.x, e = c.y);
    return [d, e]
};
Sahi.prototype.getWindow = function (a) {
    var b = a;
    this.isFlexObj(b) && (b = a.object);
    if (this.isWindow(b))return b;
    this.isSafariLike() ? a = this.getWin(b) : (a = b.ownerDocument.defaultView, a || (a = b.ownerDocument.parentWindow));
    return a
};
Sahi.prototype.getNamedWindow = function (a, b) {
    return this.getNamedAncestor(a, b) || this.getNamedFrame(a, b)
};
Sahi.prototype.getNamedAncestor = function (a, b) {
    try {
        var c = a;
        if ("_self" == b)return c;
        if ("_parent" == b)return a.parent;
        if ("_top" == b)return a.top;
        for (var d = 0; 100 > d; d++) {
            if (c.name == b)return c;
            if (c == c.parent)return null;
            c = c.parent
        }
    } catch (e) {
    }
};
Sahi.prototype.getNamedFrame = function (a, b) {
    try {
        var c = this.getBlankResult(), d = this.findTagHelper(b, a, "iframe", c, "name").element;
        if (null != d)return d.contentWindow ? d.contentWindow : d;
        c = this.getBlankResult();
        d = this.findTagHelper(b, a, "frame", c, "name").element;
        if (null != d)return d
    } catch (e) {
    }
};
Sahi.prototype.getBaseTarget = function (a) {
    a = this.getElementsByTagName("BASE", a.document);
    for (var b = a.length - 1; 0 <= b; b--) {
        var c = a[b].target;
        if (c && "" != c)return c
    }
};
Sahi.prototype.getClickEv = function (a) {
    var b = {};
    this._isIE() ? a.srcElement = b : b.target = a;
    b.stopPropagation = this.noop;
    return b
};
Sahi.prototype.noop = function () {
};
Sahi.prototype._accessor = function (a) {
    return eval(a)
};
Sahi.prototype._byId = function (a) {
    return this.findElementById(this.top(), a)
};
Sahi.prototype._byText = function (a, b) {
    var c = this.getBlankResult();
    return this.tagByText({relations: [], window: this.top(), positionals: []}, a, b, c).element
};
Sahi.prototype._byXPath = function (a) {
    var b = this.lookInside ? this.handleIframe(this.lookInside) : this.top().document;
    a = b.evaluate(a, b, null, 0, null);
    switch (a.resultType) {
        case 1:
            return a.numberValue;
        case 2:
            return a.stringValue;
        case 3:
            return a.booleanValue
    }
    return a.iterateNext()
};
Sahi.prototype._byClassName = function (a, b, c) {
    c = this.getDomRelAr(arguments);
    var d = this.getBlankResult();
    return this.findTagHelper(a, c, b, d, "className").element
};
Sahi.prototype.byName = function (a, b, c) {
    c = this.getDomRelAr(arguments);
    var d = this.getBlankResult();
    return this.findTagHelper(a, c, b, d, "name").element
};
Sahi.prototype._spandiv = function (a, b) {
    var c = this._span.apply(this, arguments);
    null == c && (c = this._div.apply(this, arguments));
    return c
};
Sahi.prototype.tagByText = function (a, b, c, d) {
    for (var e = this.getArrayNameAndIndex(b), f = e.index, e = e.name, h = this.getElementsByTagName(c, this.getDoc(a)), g = 0; g < h.length; g++) {
        var k = h[g], l = this._getText(k);
        if (this.isTextMatch(l, e) && (d.cnt++, d.cnt == f || -1 == f))return d.element = this.innerMost(k, b, c), d.found = !0, d
    }
    return this.recurseInFrames(this.tagByText, a, d, arguments)
};
Sahi.prototype.isTextMatch = function (a, b) {
    return b instanceof RegExp ? a.match(b) : a == b
};
Sahi.prototype.innerMost = function (a, b, c) {
    for (var d = 0; d < a.childNodes.length; d++) {
        var e = a.childNodes[d], f = this._getText(e);
        if (f && this.contains(f, b) && (e = this.innerMost(e, b, c), this.areTagNamesEqual(e.nodeName, c)))return e
    }
    return a
};
Sahi.prototype._simulateEvent = function (a, b) {
    if (this._isIE()) {
        var c = eval("el.on" + b.type).toString(), c = c.replace("anonymous()", "s_anon(s_ev)", "g").replace("event", "s_ev", "g");
        eval(c);
        s_anon(b)
    } else eval("el.on" + b.type + "(ev);")
};
Sahi.prototype._setGlobal = function (a, b) {
    this.setServerVar(a, b, !0)
};
Sahi.prototype._getGlobal = function (a) {
    return this.getServerVar(a, !0)
};
Sahi.prototype._set = function (a, b) {
    this.locals[a] = b
};
Sahi.prototype._get = function (a) {
    return this.locals[a]
};
Sahi.prototype._areEqual = function (a, b) {
    return this.isArray(a) && this.isArray(b) ? "equal" == this.compareArrays(a, b) ? !0 : !1 : this.areEqualParams(this.trim(b), this.checkRegex(this.trim(a)))
};
Sahi.prototype._assertNotNull = function (a, b) {
    if (null == a)throw new SahiAssertionException(1, b);
    if (this.isFlexObj(a) && !a.exists())throw new SahiAssertionException(1, b);
    return !0
};
Sahi.prototype._assertExists = Sahi.prototype._assertNotNull;
Sahi.prototype._assertNull = function (a, b) {
    if (this.isFlexObj(a)) {
        if (a.exists())throw new SahiAssertionException(2, b);
    } else if (null != a)throw new SahiAssertionException(2, b);
    return !0
};
Sahi.prototype._assertNotExists = Sahi.prototype._assertNull;
Sahi.prototype._assertTrue = function (a, b) {
    if (!0 != a)throw new SahiAssertionException(5, b);
    return !0
};
Sahi.prototype._assert = Sahi.prototype._assertTrue;
Sahi.prototype._assertNotTrue = function (a, b) {
    if (a)throw new SahiAssertionException(6, b);
    return !0
};
Sahi.prototype._assertVisible = function (a, b) {
    if (!0 != this._isVisible(a))throw new SahiAssertionException(5, b);
    return !0
};
Sahi.prototype._assertNotVisible = function (a, b) {
    if (!1 != this._isVisible(a))throw new SahiAssertionException(5, b);
    return !0
};
Sahi.prototype._assertFalse = Sahi.prototype._assertNotTrue;
Sahi.prototype._assertEqual = function (a, b, c) {
    if (this.isArray(a) && this.isArray(b) || this.isObject(a) && this.isObject(b)) {
        a = this.compare(a, b);
        if ("equal" != a) {
            b = a.errorMsg + " at ";
            for (var d = a.stack.length - 1; 0 <= d; d--)b += a.stack[d];
            a = b
        }
        if ("equal" != a)throw new SahiAssertionException(3, (c ? c : "") + "\n" + a);
    } else if (!this.areEqualParams(this.trim(b), this.checkRegex(this.trim(a))))throw new SahiAssertionException(3, (c ? c : "") + "\nExpected:" + this.toJSON(a) + "\nActual:" + this.toJSON(b) + "");
    return !0
};
Sahi.prototype._extract = function (a, b, c) {
    a = a.match(this.checkRegex(b));
    if (null == a)return !1;
    c && a.splice(0, 1);
    return a
};
Sahi.prototype.isArray = function (a) {
    return "[object Array]" === Object.prototype.toString.call(a)
};
Sahi.prototype.isObject = function (a) {
    return a instanceof Object
};
Sahi.prototype._assertEqualArrays = function (a, b, c) {
    a = this.compareArrays(a, b);
    if ("equal" != a)throw new SahiAssertionException(3, (c ? c : "") + "\n" + a);
    return !0
};
Sahi.prototype._areEqualArrays = function (a, b) {
    return "equal" == this.compareArrays(a, b)
};
Sahi.prototype._assertNotEqualArrays = function (a, b, c) {
    if ("equal" == this.compareArrays(a, b))throw new SahiAssertionException(4, c);
    return !0
};
Sahi.prototype._assertNotEqual = function (a, b, c) {
    if (this.isArray(a) && this.isArray(b))return this._assertNotEqualArrays(a, b, c);
    if (this.areEqualParams(this.trim(b), this.checkRegex(this.trim(a))))throw new SahiAssertionException(4, c);
    return !0
};
Sahi.prototype._assertContainsText = function (a, b, c) {
    if (null == b || this.isFlexObj(b) && !b.exists())throw new SahiAssertionException(1, c ? c : "The parameter passed to _assertContainsText was not found on the browser ");
    if (!this._containsText(b, a))throw new SahiAssertionException(3, (c ? c : "") + "\nExpected:" + this.toJSON(a) + " to be part of " + this.toJSON(this._getText(b)) + "");
    return !0
};
Sahi.prototype._assertNotContainsText = function (a, b, c) {
    if (this._containsText(b, a))throw new SahiAssertionException(3, (c ? c : "") + "\nExpected:" + this.toJSON(a) + " not to be part of " + this.toJSON(this._getText(b)) + "");
    return !0
};
Sahi.prototype._assertSnapShot = function (a, b, c, d, e) {
    if (!this.SKIP_ASSERT_SNAPSHOTS) {
        var f = null, h = null, g = !0, k = null, l = null;
        e && (e.delay && (f = e.delay), e.scrollLimit && (h = e.scrollLimit), e.trim && (g = e.trim), e.format && (k = e.format), e.resizePercentage && (l = e.resizePercentage));
        null == c && (c = this.DEFAULT_IMAGE_COMPARISON_THRESHOLD);
        this.fork(6E4);
        null == b && (b = window);
        e = this.placePattern(window);
        b = new SahiScrollAndCapture(this.lastStepId + 1, e, window, b, f, h, g, null, null, k, l, this._isPhantomJS());
        b.setAssertProperties(a,
            c, d);
        b.init()
    }
};
Sahi.prototype._getSelectedText = function (a) {
    this.checkNull(a, "_getSelectedText");
    return this.getSelectBoxText(a, !0)
};
Sahi.prototype.getSelectBoxText = function (a, b) {
    if (b && "select-one" == a.type)return this._getText(a.options[a.selectedIndex]);
    for (var c = [], d = a.options, e = a.options.length, f = 0; f < e; f++) {
        var h = d[f];
        b && !h.selected || c.push(this._getText(h))
    }
    if (0 < c.length)return c
};
Sahi.prototype._getText = function (a) {
    if (this.isApplet(a))return a.getText();
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.getText();
    this.checkNull(a, "_getText");
    return a && a.type && (this.isSetValueType(a.type) || "button" == a.type && this.areTagNamesEqual(a.tagName, "INPUT") || "textarea" == a.type || "submit" == a.type) && a.value ? a.value : this.trim(this._getTextNoTrim(a))
};
Sahi.prototype._getOptions = function (a, b) {
    this.checkNull(a, "_getOptions");
    for (var c = [], d = a.options.length, e = 0; e < d; e++)c[e] = "value" == b ? a.options[e].value : this._getText(a.options[e]);
    return c
};
Sahi.prototype._getValue = function (a) {
    return this.isFlexObj(a) ? (null != this.lookInside && (a = a.inside(this.lookInside)), a.getValue()) : this.isApplet(a) ? a.getValue() : a.value
};
Sahi.prototype._getAttribute = function (a, b) {
    return this.getAttribute(a, b)
};
Sahi.prototype._getTextNoTrim = function (a) {
    this.checkNull(a, "_getTextNoTrim");
    if (a.tagName) {
        if ("option" == a.tagName.toLowerCase())return a.text.replace(/\u00A0/g, " ");
        if ("select-one" == a.type || "select-multiple" == a.type)return this.getSelectBoxText(a, !1)
    }
    if (this._isIE() || this.isSafariLike() && !this._isChrome())return a.innerText || a.textContent || "";
    var b = a.innerHTML;
    return !b || -1 == b.indexOf("\x3cbr") && -1 == b.indexOf("\x3cBR") ? a.textContent : document.createElement ? (b = document.createElement(a.tagName), b.innerHTML =
        a.innerHTML.replace(/<br[\/]*>/ig, " "), b.textContent) : a.textContent
};
Sahi.prototype._getCellText = Sahi.prototype._getText;
Sahi.prototype.getRowIndexWith = function (a, b) {
    var c = this.getRowWith(a, b);
    return null == c ? -1 : c.rowIndex
};
Sahi.prototype.getRowWith = function (a, b) {
    for (var c = 0; c < b.rows.length; c++)for (var d = b.rows[c], e = 0; e < d.cells.length; e++)if (this.areEqualParams(this._getText(d.cells[e]), this.checkRegex(a)))return d;
    return null
};
Sahi.prototype.getColIndexWith = function (a, b) {
    for (var c = 0; c < b.rows.length; c++)for (var d = b.rows[c], e = 0; e < d.cells.length; e++)if (this.areEqualParams(this._getText(d.cells[e]), this.checkRegex(a)))return e;
    return -1
};
Sahi.prototype._alert = function (a) {
    return this.callFunction(this.real_alert, window, a)
};
Sahi.prototype._lastAlert = function (a) {
    var b = this.sendToServer("/_s_/dyn/SessionState_getSessionAlert?name\x3d" + this.encode("Alerts")), b = eval("(" + this.decode(b) + ")");
    return !0 == a ? b : 0 == b.length ? null : b[b.length - 1]
};
Sahi.prototype.lastAlertJava = function () {
    var a = this.sendToServer("/_s_/dyn/SessionState_getSessionAlert?name\x3d" + this.encode("Alerts"));
    return eval("(" + this.decode(a) + ")").join("__SAHIDELIMITER__")
};
Sahi.prototype.lastConfirmJava = function () {
    var a = this.sendToServer("/_s_/dyn/SessionState_getSessionConfirm?name\x3d" + this.encode("Confirms"));
    return eval("(" + this.decode(a) + ")").join("__SAHIDELIMITER__")
};
Sahi.prototype.lastPromptJava = function () {
    var a = this.sendToServer("/_s_/dyn/SessionState_getSessionPrompt?name\x3d" + this.encode("Prompts"));
    return eval("(" + this.decode(a) + ")").join("__SAHIDELIMITER__")
};
Sahi.prototype._clearLastAlert = function () {
    this.sendToServer("/_s_/dyn/SessionState_resetSessionAlert")
};
Sahi.prototype._clearLastConfirm = function () {
    this.sendToServer("/_s_/dyn/SessionState_resetSessionConfirm")
};
Sahi.prototype._clearLastPrompt = function () {
    this.sendToServer("/_s_/dyn/SessionState_resetSessionPrompt")
};
Sahi.prototype._eval = function (a) {
    this.xyoffsets = new Sahi.Dict;
    return eval(a)
};
Sahi.prototype._call = function (a) {
    return a
};
Sahi.prototype._fetch = function (a) {
    return a
};
Sahi.prototype._random = function (a) {
    return Math.floor(Math.random() * (a + 1))
};
Sahi.prototype._savedRandom = function (a, b, c) {
    null == b && (b = 0);
    null == c && (c = 1E4);
    var d = this.getServerVar("srandom" + a);
    if (null == d || "" == d)d = b + this._random(c - b), this.setServerVar("srandom" + a, d);
    return d
};
Sahi.prototype._resetSavedRandom = function (a) {
    this.setServerVar("srandom" + a, "")
};
Sahi.prototype._expectConfirm = function (a, b, c) {
    this.sendToServer("/_s_/dyn/SessionState_setExpectConfirm?text\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(b) + "\x26isPersist\x3d" + this.encode(c))
};
Sahi.prototype._saveDownloadedAs = function (a) {
    this._callServer("SaveAs_saveLastDownloadedAs", "destination\x3d" + this.encode(a))
};
Sahi.prototype._lastDownloadedFileName = function () {
    var a = this._callServer("SaveAs_getLastDownloadedFileName");
    return "-1" == a ? null : a
};
Sahi.prototype._clearLastDownloadedFileName = function () {
    this._callServer("SaveAs_clearLastDownloadedFileName")
};
Sahi.prototype._addToSession = function (a) {
    var b = "/" != a.charAt(a.length - 1) ? "/" : "";
    a = a + b + "_s_/spr/addToSession.htm?sahisid\x3d" + _sahi.sid;
    window.open(a, "", "width\x3d250,height\x3d100")
};
Sahi.prototype._saveFileAs = function (a) {
    this._callServer("SaveAs_saveTo", a)
};
Sahi.prototype.callFunction = function (a, b, c) {
    return a.apply ? (c instanceof Array || (c = [c]), a.apply(b, c)) : a(c)
};
Sahi.prototype._lastConfirm = function (a) {
    var b = this.sendToServer("/_s_/dyn/SessionState_getSessionConfirm?name\x3d" + this.encode("Confirms")), b = eval("(" + this.decode(b) + ")");
    return !0 == a ? b : 0 == b.length ? null : b[b.length - 1]
};
Sahi.prototype._lastPrompt = function (a) {
    var b = this.sendToServer("/_s_/dyn/SessionState_getSessionPrompt?name\x3d" + this.encode("Prompts")), b = eval("(" + this.decode(b) + ")");
    return !0 == a ? b : 0 == b.length ? null : b[b.length - 1]
};
Sahi.prototype._expectPrompt = function (a, b) {
    null === b && (b = "sahi__null__prompt");
    this.sendToServer("/_s_/dyn/SessionState_setExpectPrompt?text\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(b))
};
Sahi.prototype._prompt = function (a) {
    this.fork(6E4);
    a = this.callFunction(this.real_prompt, window, a);
    this.afterEval();
    return a
};
Sahi.prototype._confirm = function (a) {
    this.fork(6E4);
    a = this.callFunction(this.real_confirm, window, a);
    this.afterEval();
    return a
};
Sahi.prototype._print = function (a) {
    return this.callFunction(this.real_print, window, a)
};
Sahi.prototype._printCalled = function () {
    return this.getServerVar("printCalled")
};
Sahi.prototype._clearPrintCalled = function () {
    return this.setServerVar("printCalled", null)
};
Sahi.prototype.arrayIndexOf = function (a, b) {
    for (var c = 0; c < a.length; c++)if (a[c] === b)return c;
    return -1
};
Sahi.prototype._cell = function (a, b, c) {
    if (null == a)return null;
    if (null == b && null == c || null != b && -1 != this.arrayIndexOf("_in _near _under _above _leftOf _rightOf _rowOf _colOf".split(" "), b.relation))return this.findCell(a, this.getDomRelAr(arguments));
    var d = b, e = c;
    if ("string" == typeof b || b instanceof RegExp)if (d = this.getRowIndexWith(b, a), -1 == d)return null;
    if ("string" == typeof c || c instanceof RegExp)if (e = this.getColIndexWith(c, a), -1 == e)return null;
    return null == a.rows[d] ? null : a.rows[d].cells[e]
};
Sahi.prototype.x_row = function (a, b) {
    return "string" == typeof b ? this.getRowWith(b, a) : "number" == typeof b ? a.rows[b] : null
};
Sahi.prototype._containsHTML = function (a, b) {
    return this.contains(a.innerHTML, b)
};
Sahi.prototype._containsText = function (a, b) {
    return this.isAccessorIgnoreCase ? this.contains(this.lowerCase(this._getText(a)), this.lowerCase(b)) : this.contains(this._getText(a), b)
};
Sahi.prototype.contains = function (a, b) {
    b = this.checkRegex(b);
    return b instanceof RegExp ? null != a.match(b) : -1 != a.indexOf(b)
};
Sahi.prototype._contains = function (a, b) {
    if (null == a)return !1;
    for (var c = b; ;) {
        if (c == a)return !0;
        if (null == c || c == c.parentNode)return !1;
        c = c.parentNode
    }
};
Sahi.prototype._popup = function (a) {
    if (this.top().name == a || this.getTitle() == a)return this.top();
    throw new SahiNotMyWindowException(a);
};
Sahi.prototype._domain = function (a) {
    if (document.domain == a)return this.top();
    throw new SahiNotMyDomainException(a);
};
Sahi.prototype._log = function (a, b, c) {
    b || (b = "info");
    var d = this.currentStepInfo ? this.currentStepInfo.debugInfo : null, e = b.toLowerCase();
    if ("failure" == e || "error" == e)this.currentType = b;
    this.logPlayBack(a, b, d, null, c)
};
Sahi.prototype._logImage = function (a, b, c) {
    c || (c = "info");
    null == b && (b = a);
    this._log(b, c, a)
};
Sahi.prototype.log = function (a, b) {
    b || (b = "info");
    this.logPlayBack(a, b, null)
};
Sahi.prototype._navigateTo = function (a, b) {
    (b || this.top().location.href != a) && window.setTimeout(function () {
        _sahi.top().location.href = a.replace(/'/g, "\\'")
    }, 0)
};
Sahi.prototype._callServer = function (a, b) {
    return this.sendToServer("/_s_/dyn/" + a + (null == b ? "" : "?" + b))
};
Sahi.prototype._removeMock = function (a) {
    return this._callServer("MockResponder_remove", "pattern\x3d" + a)
};
Sahi.prototype._addMock = function (a, b) {
    null == b && (b = "MockResponder_simple");
    return this._callServer("MockResponder_add", "pattern\x3d" + a + "\x26class\x3d" + b)
};
Sahi.prototype._mockImage = function (a, b) {
    null == b && (b = "MockResponder_mockImage");
    return this._callServer("MockResponder_add", "pattern\x3d" + a + "\x26class\x3d" + b)
};
Sahi.prototype._debug = function (a) {
    return this._callServer("Debug_toOut", "msg\x3dDebug: " + this.encode(a))
};
Sahi.prototype._debugToErr = function (a) {
    return this._callServer("Debug_toErr", "msg\x3d" + this.encode(a))
};
Sahi.prototype._debugToFile = function (a, b) {
    if (null != b)return this._callServer("Debug_toFile", "msg\x3d" + this.encode(a) + "\x26file\x3d" + this.encode(b))
};
Sahi.prototype._enableKeepAlive = function () {
    this.sendToServer("/_s_/dyn/Configuration_enableKeepAlive")
};
Sahi.prototype._disableKeepAlive = function () {
    this.sendToServer("/_s_/dyn/Configuration_disableKeepAlive")
};
Sahi.prototype.getWin = function (a) {
    return null == a ? this.self() : -1 != a.nodeName.indexOf("document") ? this.getFrame1(this.top(), a) : this.getWin(a.parentNode)
};
Sahi.prototype.getFrame1 = function (a, b) {
    if (a.document == b)return a;
    for (var c = a.frames, d = 0; d < c.length; d++) {
        var e = this.getFrame1(c[d], b);
        if (null != e)return e
    }
    return null
};
Sahi.prototype._setAccessorIgnoreCase = function (a) {
    this.sendToServer("/_s_/dyn/SessionState_setIsAccessorIgnoreCase?isIgnore\x3d" + (!0 == a))
};
Sahi.prototype.areEqual2 = function (a, b, c) {
    return "sahiText" == b ? (a = this._getTextNoTrim(a), c instanceof RegExp ? (a = this.trim(a), null != a && null != a.match(c)) : 1E3 < a.length - c.length ? !1 : this.isAccessorIgnoreCase ? this.lowerCase(this.trim(a)) == this.lowerCase(this.trim(c)) : this.trim(a) == this.trim(c)) : this.areEqualParams(this.getAttribute(a, b), c)
};
Sahi.prototype.areEqualParams = function (a, b) {
    return b instanceof RegExp ? null != a && "string" == typeof a && null != a.match(b) : this.isAccessorIgnoreCase ? this.lowerCase(a) == this.lowerCase(b) : a == b
};
Sahi.prototype.areEqual = function (a, b, c) {
    if ("associative_array" == b) {
        b = !0;
        for (var d in c)if (b = b && this.areEqual(a, d, c[d]), !b)return !1;
        return !0
    }
    if ("function" == typeof b)return this.areEqualParams(this.callFunction(b, this, a), c);
    if (null == b || -1 == b.indexOf("|"))return this.areEqual2(a, b, c);
    d = b.split("|");
    for (var e = 0; e < d.length; e++)if (b = d[e], this.areEqual2(a, b, c))return !0;
    return !1
};
Sahi.prototype.findLink = function (a, b) {
    b = b ? b : this.top();
    var c = this.getBlankResult(), c = this.findImageHelper(a, b, c, "sahiText", !1).element;
    if (null != c)return c;
    c = this.getBlankResult();
    return this.findImageHelper(a, b, c, "id", !1).element
};
Sahi.prototype.findImage = function (a, b) {
    b = b ? b : this.top();
    var c = this.getBlankResult(), d = this.findImageHelper(a, b, c, "title|alt", !0).element;
    if (null != d)return d;
    c = this.getBlankResult();
    d = this.findImageHelper(a, b, c, "id", !0).element;
    return null != d ? d : d = this.findImageHelper(a, b, c, this.getImageSrc, !0).element
};
Sahi.prototype.getImageSrc = function (a) {
    a = a.src;
    return a.substring(a.lastIndexOf("/") + 1)
};
Sahi.prototype.findImageHelper = function (a, b, c, d, e) {
    if ("number" == typeof a)return c.cnt = 0, c = this.findImageByIx(a, b, c, e);
    for (var f = this.getArrayNameAndIndex(a), h = f.index, f = f.name, g = this.getDoc(b), g = e ? this.getElementsByTagName("IMG", g) : this.getElementsByTagName("A", g), k = 0; k < g.length; k++)if (this.areEqual(g[k], d, f) && (c.cnt++, c.cnt == h || -1 == h))return c.element = g[k], c.found = !0, c;
    return this.recurseInFrames(this.findImageHelper, b, c, arguments)
};
Sahi.prototype.findImageByIx = function (a, b, c, d) {
    var e = this.getDoc(b), e = d ? this.getElementsByTagName("IMG", e) : this.getElementsByTagName("A", e);
    if (e[a - c.cnt])return c.element = e[a - c.cnt], c.found = !0, c;
    c.cnt += e.length;
    return this.recurseInFrames(this.findImageByIx, b, c, arguments)
};
Sahi.prototype.findLinkIx = function (a, b) {
    var c = this.getBlankResult();
    if (null == a || "" == a)if (c = this.findImageIxHelper(a, b, this.top(), c, null, !1).cnt, -1 != c)return c;
    c = this.getBlankResult();
    c = this.findImageIxHelper(a, b, this.top(), c, "sahiText", !1).cnt;
    if (-1 != c)return c;
    c = this.getBlankResult();
    return this.findImageIxHelper(a, b, this.top(), c, "id", !1).cnt
};
Sahi.prototype.findImageIx = function (a, b) {
    var c = this.getBlankResult();
    if (null == a || "" == a)if (c = this.findImageIxHelper(a, b, this.top(), c, null, !0).cnt, -1 != c)return c;
    c = this.getBlankResult();
    c = this.findImageIxHelper(a, b, this.top(), c, this.getImageSrc, !0).cnt;
    if (-1 != c)return c;
    c = this.getBlankResult();
    c = this.findImageIxHelper(a, b, this.top(), c, "title|alt", !0).cnt;
    if (-1 != c)return c;
    c = this.getBlankResult();
    return this.findImageIxHelper(a, b, this.top(), c, "id", !0).cnt
};
Sahi.prototype.findImageIxHelper = function (a, b, c, d, e, f) {
    if (d && d.found)return d;
    for (var h = f ? c.document.images : this.getElementsByTagName("A", c.document), g = 0; g < h.length; g++)if (null == e || this.areEqual(h[g], e, a))if (d.cnt++, h[g] == b)return d.found = !0, d;
    return this.recurseInFrames(this.findImageIxHelper, c, d, arguments)
};
Sahi.prototype.findElementById = function (a, b) {
    return null != a.document.getElementById(b) ? a.document.getElementById(b) : this.recurseInFrames(this.findElementById, a, null, arguments)
};
Sahi.prototype.findFormElementByIndex = function (a, b, c, d, e) {
    for (var f = this.getElementsByTagName(e, this.getDoc(b)), f = this.isWithinBounds(f, b), h = 0; h < f.length; h++) {
        var g = f[h];
        if (null != g && this.areEqualTypes(this.getElementType(g), c) && this.checkElementVisible(g) && (d.cnt++, d.cnt == a))return d.element = g, d.found = !0, d
    }
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findFormElementByIndex, b, d, arguments)
};
Sahi.prototype.getElementType = function (a) {
    var b = a.getAttribute("type");
    return "text" == a.type && a.type != b ? -1 == this.findInArray(this.newTextboxTypes, b) ? "text" : b : a.type
};
Sahi.prototype.findElementAttributesHelper = function (a, b, c, d, e, f, h) {
    for (var g = this.getElementsByTagName(f, this.getDoc(b)), g = this.isWithinBounds(g, b), k = 0; k < g.length; k++) {
        var l = g[k];
        this.areEqualTypes(this.getElementType(l), c) && this.areEqual(l, e, a) && this.checkElementVisible(l) && -1 == this.findInArray(d.elements, l) && (d.elements.push(l), d.attributes.push(this.getAttribute(l, h)))
    }
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findElementAttributesHelper, b, d, arguments)
};
Sahi.prototype.findTagAttributesHelper = function (a, b, c, d, e, f) {
    var h = this.getElementsByTagName(c, this.getDoc(b));
    if (h = this.isWithinBounds(h, b))for (var g = 0; g < h.length; g++) {
        var k = h[g];
        this.areEqual(k, e, a) && ("sahiText" != e || this.innerMost(k, a, c) == k) && this.checkElementVisible(k) && -1 == this.findInArray(d.elements, k) && (d.elements.push(k), d.attributes.push(this.getAttribute(k, f)))
    }
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findTagAttributesHelper, b, d, arguments)
};
Sahi.prototype.findElementHelper = function (a, b, c, d, e, f) {
    if ("number" == typeof a) {
        if (d = this.findFormElementByIndex(a, b, c, d, f), d.found)return d
    } else {
        if ("associative_array" != e)for (var h = this.getDoc(b), g = this.getElementsByTagName(f, h), g = this.isWithinBounds(g, b), k = 0; k < g.length; k++) {
            var l = g[k];
            if (this.areEqualTypes(this.getElementType(l), c) && this.areEqual(l, e, a) && this.checkElementVisible(l))return d.element = l, d.found = !0, d
        }
        for (var g = this.getArrayNameAndIndex(a), h = g.index, q = g.name, g = this.getElementsByTagName(f,
            this.getDoc(b)), g = this.isWithinBounds(g, b), k = 0; k < g.length; k++)if (l = g[k], this.areEqualTypes(this.getElementType(l), c) && this.areEqual(l, e, q) && this.checkElementVisible(l) && (d.cnt++, d.cnt == h || -1 == h))return d.element = l, d.found = !0, d
    }
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findElementHelper, b, d, arguments)
};
Sahi.prototype.findElementIxHelper = function (a, b, c, d, e, f, h) {
    if (e && e.found)return e;
    for (var g = this.getElementsByTagName(h, this.getDoc(d)), k = 0; k < g.length; k++)if (this.areEqualTypes(this.getElementType(g[k]), b) && this.areEqual(g[k], f, a) && this.checkElementVisible(g[k]) && (e.cnt++, g[k] == c))return e.found = !0, e;
    return 0 != d.relations.length ? e : this.recurseInFrames(this.findElementIxHelper, d, e, arguments)
};
Sahi.prototype.areEqualTypes = function (a, b) {
    return a == b ? !0 : -1 != a.indexOf("select") && -1 != b.indexOf("select")
};
Sahi.prototype.findCell = function (a, b) {
    var c = this.getBlankResult(), c = this.findTagHelper(a, b, "td", c, "sahiText").element;
    if (null != c)return c;
    c = this.getBlankResult();
    c = this.findTagHelper(a, b, "td", c, "id").element;
    if (null != c)return c;
    c = this.getBlankResult();
    return this.findTagHelper(a, b, "td", c, "className").element
};
Sahi.prototype.getBlankResult = function () {
    return {cnt: -1, found: !1, element: null}
};
Sahi.prototype.getArrayNameAndIndex = function (a, b) {
    var c = {};
    if (!(a instanceof RegExp)) {
        if ("object" == typeof a) {
            c.index = null != a.sahiIndex ? a.sahiIndex : -1;
            c.name = {};
            for (var d in a)"sahiIndex" != d && (c.name[d] = this.checkRegex(a[d], b, this.isAccessorIgnoreCase));
            return c
        }
        if (d = a.match(/(.*)\[([0-9]*)\]$/))return c.name = this.checkRegex(d[1], b, this.isAccessorIgnoreCase), c.index = d[2], c
    }
    c.name = this.checkRegex(a, b, this.isAccessorIgnoreCase);
    c.index = -1;
    return c
};
Sahi.prototype.checkRegex = function (a, b, c) {
    try {
        return "string" == typeof a && a.match(this.CHECK_REGEXP) ? eval(a + (!a.match(/\/i$/) && c ? "i" : "") + (b ? "g" : "")) : a
    } catch (d) {
        return a
    }
};
Sahi.prototype.findInForms = function (a, b, c) {
    b = b.document.forms;
    if (null == b)return null;
    for (var d = 0; d < b.length; d++) {
        var e = this.findInForm(a, b[d], c);
        if (null != e)return e
    }
    return null
};
Sahi.prototype.findInForm = function (a, b, c) {
    b = b.elements;
    for (var d = [], e = 0; e < b.length; e++) {
        var f = b[e];
        f.name == a && f.type && this.areEqualTypes(this.getElementType(f), c) ? d[d.length] = f : "button" != f.type && "submit" != f.type || f.value != a || f.type != c || (d[d.length] = f)
    }
    return 0 < d.length ? 1 == d.length ? d[0] : d : null
};
Sahi.prototype.findTable = function (a, b) {
    b = this.getDomRelAr(arguments);
    var c = this.getBlankResult();
    return this.findTagHelper(a, b, "table", c, "id").element
};
Sahi.prototype.x_iframe = function (a, b) {
    b = this.getDomRelAr(arguments);
    var c = this.getBlankResult(), c = this.findTagHelper(a, b, "iframe", c, "id").element;
    if (null != c)return c;
    c = this.getBlankResult();
    c = this.findTagHelper(a, b, "iframe", c, "name").element;
    if (null != c)return c
};
Sahi.prototype.getArgsAr = function (a, b, c) {
    null == b && (b = 0);
    null == c && (c = a.length);
    for (var d = []; b < c; b++)d.push(a[b]);
    return d
};
Sahi.prototype._count = function (a, b, c) {
    return this._collectAttributes(a, b, "sahiIndex", c).length
};
Sahi.prototype._collect = function (a, b, c) {
    return this.collectElementsAndAttributes(a, b, "sahiIndex", c).elements
};
Sahi.prototype.getADByAPIName = function (a) {
    for (var b = 0; b < this.ADs.length; b++) {
        var c = this.ADs[b];
        if (c.name == a)return c
    }
    return null
};
Sahi.prototype._collectAttributes = function (a, b, c, d) {
    return this.collectElementsAndAttributes(a, b, c, d).attributes
};
Sahi.prototype.collectElementsAndAttributes = function (a, b, c, d) {
    b = this.getArrayNameAndIndex(b).name;
    d = this.getDomRelAr(arguments);
    var e = {elements: [], attributes: []}, f = this.getADByAPIName(a);
    if (null == f)return b;
    var h = f.attributes;
    "object" != typeof b || b instanceof RegExp || (h = ["associative_array"]);
    for (var g = 0; g < h.length; g++)f.type ? this.findElementAttributesHelper(b, d, f.type, e, h[g], f.tag, c) : this.findTagAttributesHelper(b, d, f.tag, e, h[g], c).element;
    return e
};
Sahi.prototype.collectAttributesJava = function (a, b, c, d) {
    return this._collectAttributes(b, c, a, d).join("___sahi___")
};
Sahi.prototype.findResByIndexInList = function (a, b, c, d) {
    var e = this.getElementsByTagName(c, this.getDoc(b)), e = this.isWithinBounds(e, b);
    if (e[a - d.cnt])return d.element = e[a - d.cnt], d.found = !0, d;
    d.cnt += e.length;
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findResByIndexInList, b, d, arguments)
};
Sahi.prototype.is_defined = function (a) {
    return "undefined" !== typeof a
};
Sahi.prototype.getBoundedRectangle = function (a) {
    return {
        calcXleft: function (a) {
            this.xleft = !_sahi.is_defined(this.xleft) || a > this.xleft ? a : this.xleft
        }, calcXright: function (a) {
            this.xright = !_sahi.is_defined(this.xright) || a < this.xright ? a : this.xright
        }, calcYtop: function (a) {
            this.ytop = !_sahi.is_defined(this.ytop) || a > this.ytop ? a : this.ytop
        }, calcYbottom: function (a) {
            this.ybottom = !_sahi.is_defined(this.ybottom) || a < this.ybottom ? a : this.ybottom
        }, calculateRectangle: function (a) {
            this.isCompleteDoc = 0 == a.length;
            for (var c = 0; c <
            a.length; c++) {
                var d = a[c];
                "_under" == d.relation ? (this.calcXleft(d.alignX), this.calcXright(d.alignXOuter), this.calcYtop(d.limitY), "undefined" !== typeof d.limitUnder && this.calcYbottom(d.limitUnder)) : "_above" == d.relation ? (this.calcXleft(d.alignX), this.calcXright(d.alignXOuter), this.calcYbottom(d.limitY), "undefined" !== typeof d.limitTop && this.calcYtop(d.limitTop)) : "_leftOf" == d.relation ? (this.calcYtop(d.alignY), this.calcYbottom(d.alignYOuter), this.calcXright(d.limitX)) : "_rightOf" == d.relation ? (this.calcYtop(d.alignY),
                    this.calcYbottom(d.alignYOuter), this.calcXleft(d.limitX)) : "_rowOf" == d.relation ? (this.calcYtop(d.alignY), this.calcYbottom(d.alignYOuter)) : "_colOf" == d.relation && (this.calcXleft(d.alignX), this.calcXright(d.alignXOuter))
            }
            return this
        }, hasNoRectanlge: function () {
            return !((!_sahi.is_defined(this.xleft) || !_sahi.is_defined(this.xright) || this.xleft < this.xright) && (!_sahi.is_defined(this.ytop) || !_sahi.is_defined(this.ybottom) || this.ytop < this.ybottom))
        }, contains: function (a) {
            return (!_sahi.is_defined(this.xleft) ||
                this.xleft <= a[0]) && (!_sahi.is_defined(this.xright) || this.xright >= a[0]) && (!_sahi.is_defined(this.ytop) || this.ytop <= a[1]) && (!_sahi.is_defined(this.ybottom) || this.ybottom >= a[1])
        }
    }.calculateRectangle(a)
};
Sahi.prototype.isWithinBounds = function (a, b) {
    var c = this.getBoundedRectangle(b.positionals), d = [];
    if (c.isCompleteDoc)return a;
    if (c.hasNoRectanlge())return d;
    for (var e = 0; e < a.length; e++)c.contains(this.getLeftTop(a[e])) && c.contains(this.getRightTop(a[e])) && d.push(a[e]);
    return d
};
Sahi.prototype.withinOffset = function (a, b, c, d) {
    return a >= b - d && a < c + d
};
Sahi.prototype.findTagHelper = function (a, b, c, d, e) {
    if ("number" == typeof a)return d.cnt = 0, d = this.findResByIndexInList(a, b, c, d);
    var f = this.getArrayNameAndIndex(a), h = f.index, f = f.name, g = this.getElementsByTagName(c, this.getDoc(b));
    if (g = this.isWithinBounds(g, b))for (var k = 0; k < g.length; k++)if (this.areEqual(g[k], e, f)) {
        var l = g[k];
        if (("sahiText" != e || this.innerMost(l, f, c) == l) && this.checkElementVisible(l) && (d.cnt++, d.cnt == h || -1 == h))return d.element = l, d.found = !0, d
    }
    return 0 != b.relations.length ? d : this.recurseInFrames(this.findTagHelper,
        b, d, arguments)
};
Sahi.prototype.recurseInFrames = function (a, b, c, d) {
    d = this.getArgsAr(d);
    var e = this.findInArray(d, b);
    try {
        var f = b.window.document.getElementsByTagName("frame");
        0 == f.length && (f = b.window.document.getElementsByTagName("iframe"));
        if (f)for (var h = 0; h < f.length; h++) {
            try {
                var g = f[h];
                if (this.checkElementVisible(g)) {
                    var k = {relations: [], window: g.contentWindow, positionals: b.positionals};
                    d[e] = k;
                    c = a.apply(this, d)
                }
            } catch (l) {
            }
            if (c && c.found)return c
        }
    } catch (q) {
        if (f = b.window.frames)for (h = 0; h < f.length; h++) {
            try {
                k = {
                    relations: [],
                    window: f[h], positionals: b.positionals
                }, d[e] = k, c = a.apply(this, d)
            } catch (n) {
            }
            if (c && c.found)return c
        }
    }
    if (this._isIE() || this._isOpera())try {
        if (f = b.window.document.getElementsByTagName("object"))for (h = 0; h < f.length; h++) {
            try {
                var m = f[h];
                m && m.contentDocument && (k = {
                    relations: [],
                    window: m.contentDocument.defaultView,
                    positionals: b.positionals
                }, d[e] = k, c = a.apply(this, d))
            } catch (r) {
            }
            if (c && c.found)return c
        }
    } catch (s) {
    }
    return c
};
Sahi.prototype.findTagIxHelper = function (a, b, c, d, e, f) {
    if (e && e.found)return e;
    var h = this.getElementsByTagName(d, this.getDoc(c));
    if (h)for (var g = 0; g < h.length; g++)if ((null == f || this.areEqual(h[g], f, a)) && this.checkElementVisible(h[g])) {
        var k = h[g];
        if ("sahiText" != f || this.innerMost(k, a, d) == k)if (e.cnt++, h[g] == b)return e.found = !0, e
    }
    return 0 != c.relations.length ? e : this.recurseInFrames(this.findTagIxHelper, c, e, arguments)
};
Sahi.prototype.canSimulateClick = function (a) {
    return a.click || a.dispatchEvent
};
String.prototype.startsWith = function (a) {
    return 0 < a.length && this.substring(0, a.length) === a
};
String.prototype.endsWith = function (a) {
    return 0 < a.length && this.substring(this.length - a.length, this.length) === a
};
Sahi.prototype.extractORFileContent = function (a) {
    return a.split("__SAHIDELIMITER__")
};
Sahi.prototype.recordStep = function (a, b, c, d, e, f) {
    if (!this.isBlankOrNull(a) && "null" != a) {
        if ("sahi" == _sahi.controllerMode) {
            var h = "";
            if ("true" == this.sendToServer("/_s_/dyn/" + this.recorderClass + "_getIsOREnabled").toString() && b) {
                var g = eval(this.addSahi(b.value));
                if (void 0 != g) {
                    for (var k = !0, l = b.value.substring(0, b.value.indexOf("(")), q = this.topSahi().orFileContentAr, n = 0; n < q.length; n++) {
                        var m = q[n];
                        if (-1 != m.indexOf("\x3d")) {
                            var m = m.split("\x3d"), r = this.trim(m[0].replace("var ", "")), m = this.trim(m[1]);
                            m.endsWith(";") &&
                            (m = this.trim(m.substring(0, m.length - 1)));
                            if (m.substring(0, m.indexOf("(")) == l && (b.value == m || this.areOREntriesEqual(m, g))) {
                                k = !1;
                                break
                            }
                        }
                    }
                    k && (h = "var " + b.name + " \x3d " + b.value + ";", q.push(h), h += "\n");
                    a = this.replaceAll(a, b.value, k ? b.name : r)
                }
            }
        }
        c || this.showStepsInController(a, !0);
        a = "step\x3d" + this.encode(a) + (b ? "\x26domain\x3d" + this.encode(d) + "\x26popup\x3d" + this.encode(e) + "\x26orcontent\x3d" + this.encode(h) : "");
        f && "sahi" == _sahi.controllerMode ? this.sendToServer("/_s_/dyn/" + this.recorderClass + "_recordPrevious?" +
            a, !1) : this.sendToServer("/_s_/dyn/" + this.recorderClass + "_record?" + a, !1)
    }
};
Sahi.prototype.replaceAll = function (a, b, c) {
    return a.split(b).join(c)
};
Sahi.prototype.areOREntriesEqual = function (a, b) {
    try {
        return eval(this.addSahi(a)) == b
    } catch (c) {
    }
    return !1
};
Sahi.prototype.isRecording = function () {
    return this.topSahi()._isRecording
};
Sahi.prototype.getAPIs = function () {
    var a = [], b;
    for (b in this)if (0 == b.indexOf("_") && this[b]) {
        var c = b, c = this[b].toString();
        -1 != c.indexOf("function") && (c = this.trim(c.substring(c.indexOf("("), c.indexOf("{"))), "" != c && (c = b + c, a[a.length] = c))
    }
    a = a.sort();
    return a.join(";")
};
Sahi.prototype.createSahiCookie = function () {
    this.setSahiCookieOnAllPages && this.createCookie("sahisid", this.sid, null, null, null)
};
Sahi.prototype.createCookie = function (a, b, c, d, e, f) {
    var h = "";
    c && (h = new Date, h.setTime(h.getTime() + 864E5 * c), h = "; expires\x3d" + h.toGMTString());
    a = a + "\x3d" + b + h + ("; path\x3d" + (d ? d : "/"));
    e && (a += "; domain\x3d" + e);
    f && (a += "; secure\x3d" + f);
    window.document.cookie = a
};
Sahi.prototype._createCookie = Sahi.prototype.createCookie;
Sahi.prototype.readCookie = function (a) {
    return this.sendToServer("/_s_/dyn/Cookies_read?name\x3d" + a)
};
Sahi.prototype._cookie = Sahi.prototype.readCookie;
Sahi.prototype.eraseCookie = function (a, b) {
    return this.sendToServer("/_s_/dyn/Cookies_delete?name\x3d" + a + (b ? "\x26path\x3d" + encodeURIComponent(b) : ""))
};
Sahi.prototype._deleteCookie = Sahi.prototype.eraseCookie;
Sahi.prototype._event = function (a, b) {
    this.type = a;
    this.keyCode = b
};
var SahiAssertionException = function (a, b) {
    _sahi.lastAssertStatus = "failure";
    this.messageNumber = a;
    this.messageText = b;
    this.exceptionType = "SahiAssertionException";
    this.toString = function () {
        return "[Assertion Failed]" + (this.messageText ? this.messageText : "")
    }
}, SahiNotMyWindowException = function (a) {
    this.name = "SahiNotMyWindowException";
    this.message = a ? "Window with name [" + a + "] not found" : "Base window not found"
}, SahiNotMyDomainException = function (a) {
    this.name = "SahiNotMyDomainException";
    this.message = a ? "Window with domain [" +
    a + "] not found" : "Base domain not found!"
};
Sahi.prototype.isSetValueType = function (a) {
    for (var b = 0; b < this.ADs.length; b++) {
        var c = this.ADs[b];
        if ("_setValue" == c.action && c.type == a)return !0
    }
    return !1
};
Sahi.prototype.onMouseDownEv = function (a) {
    this.mouseDownEl = this.getKnownTags(this.getTarget(a))
};
Sahi.prototype.onEv = function (a) {
    if (!0 != a.handled && !this.doNotRecord) {
        var b = this.getKnownTags(this.getTarget(a));
        if (!b.id || -1 == b.id.indexOf("_sahi_ignore_")) {
            if ((a.type == this.triggerType || "click" == a.type) && b.type) {
                var c = b.type;
                if (this.isSetValueType(c) || "textarea" == c || "select-one" == c || "select-multiple" == c)return
            }
            var d = this.identify(b).apis;
            0 != d.length && -1 == ("" + d[0].shortHand).indexOf("_sahi_ignore_") && (c = this.isOREnabled ? this.getOREntry(d) : null, d = this.getScript(d, b, a.type, a, !0), null == d || this.hasEventBeenRecorded(d,
                b) || (a.type == this.triggerType ? b == this.mouseDownEl && this.recordStep(d, c, !1, this.getDomainContext(), this.getPopupName()) : this.recordStep(d, c, !1, this.getDomainContext(), this.getPopupName()), a.handled = !0))
        }
    }
};
Sahi.prototype.showStepsInController = function (a, b) {
    this.sendMessageToController(this.toJSON({command: "showSteps", value: a, isRecorded: b}))
};
Sahi.prototype.showInController = function (a) {
    this.showStepsInController(this.getScript([a]))
};
Sahi.prototype.hasEventBeenRecorded = function (a, b) {
    var c = (new Date).getTime(), d = !1;
    !(0 == a.indexOf("_doubleClick") && a != this.lastQs && b == this.lastRecEl || a != this.lastQs && b != this.lastRecEl) && 800 > c - this.lastTime && (d = !0);
    this.lastQs = a;
    this.lastRecEl = b;
    this.lastTime = c;
    return d
};
Sahi.prototype.getPopupName = function () {
    var a = null;
    if (this.isPopup() && (a = this.top().name, !a || "" == a))try {
        a = this.getTitle()
    } catch (b) {
    }
    return a ? a : ""
};
Sahi.prototype._title = function () {
    return this.getTitle()
};
Sahi.prototype.getTitle = function () {
    return this.trim(this.top().document.title)
};
Sahi.prototype.isPopup = function () {
    try {
        return null == this.top().opener || this.top().opener._sahi.top() == this.top() ? 0 : 1
    } catch (a) {
    }
    return !0
};
Sahi.prototype.addWait = function (a) {
    var b = parseInt(a);
    if ("NaN" == "" + b || 200 > b)throw Error();
    this.showInController(new AccessorInfo("", "", "", "wait", a))
};
Sahi.prototype.mark = function (a) {
    this.showInController(new AccessorInfo("", "", "", "mark", a))
};
Sahi.prototype.doAssert = function (a, b) {
    try {
        var c = eval(this.addSahi(a));
        if ("string" == typeof c || "boolean" == typeof c || "number" == typeof c) {
            var d = "_assertEqual(" + this.quoted(b) + ", " + a + ");";
            this.addPopupDomainPrefixes(d);
            this.showStepsInController(d)
        } else if (c)if (this.isApplet(c) && (d = [this.language.ASSERT_EXISTS, this.language.ASSERT_EQUAL_VALUE].join("\n"), d = this.replaceAll(d, "\x3caccessor\x3e", a), d = this.replaceAll(d, "\x3cvalue\x3e", this.quoted(b)), this.showStepsInController(d)), this.isFlexObj(c))d = [this.language.ASSERT_EXISTS,
            this.language.ASSERT_EQUAL_VALUE].join("\n"), d = this.replaceAll(d, "\x3caccessor\x3e", a), d = this.replaceAll(d, "\x3cvalue\x3e", this.quoted(b)), this.showStepsInController(d); else {
            var e = this.identify(c), f = e.apis;
            if (0 != f.length) {
                var h = this.isOREnabled ? this.getOREntry(f) : null, d = e.assertions.join("\n"), d = this.replaceAll(d, "\x3caccessor\x3e", a), d = this.replaceAll(d, "\x3cvalue\x3e", this.quoted(b));
                this.showStepsInController(d);
                this.lastOREntry = h
            }
        }
    } catch (g) {
        this.handleException(g)
    }
};
Sahi.prototype.getTarget = function (a) {
    var b;
    a || (a = window.event);
    a.target ? b = a.target : a.srcElement && (b = a.srcElement);
    3 == b.nodeType && (b = b.parentNode);
    return b
};
var AccessorInfo = function (a, b, c, d, e, f, h, g) {
    this.accessor = a;
    this.shortHand = b;
    this.type = c;
    this.event = d;
    this.value = e;
    this.valueType = f;
    this.relationStr = h;
    this.attr = g
};
Sahi.prototype.getAccessorInfoQS = function (a, b) {
    if (null != a && null != a.event) {
        var c = "event\x3d" + (b ? "assert" : a.event), c = c + ("\x26accessor\x3d" + this.encode(this.convertUnicode(a.accessor))), c = c + ("\x26shorthand\x3d" + this.encode(this.convertUnicode(a.shortHand))), c = c + ("\x26type\x3d" + a.type);
        a.value && (c += "\x26value\x3d" + this.encode(this.convertUnicode(a.value)));
        return c
    }
};
Sahi.prototype.addHandlersToAllFrames = function (a) {
    var b = a.frames;
    try {
        this.addHandlers(a)
    } catch (c) {
    }
    if (b && 0 < b.length)for (a = 0; a < b.length; a++)try {
        this.isWindowAccessible(b[a]) && this.addHandlersToAllFrames(b[a])
    } catch (d) {
    }
};
Sahi.prototype.docEventHandler = function (a) {
    a || (a = window.event);
    (a = this.getKnownTags(this.getTarget(a))) && this.attachEvents(a)
};
Sahi.prototype.addHandlers = function (a) {
    a || (a = this.self());
    a = a.document;
    this.addWrappedEvent(a, "keyup", this.docEventHandler);
    this.addWrappedEvent(a, "mousemove", this.docEventHandler)
};
Sahi.prototype.attachEvents = function (a) {
    a.hasAttached || (a.tagName.toLowerCase(), this.isFormElement(a) ? this.attachFormElementEvents(a) : this.attachImageEvents(a), a.hasAttached = !0)
};
Sahi.prototype.attachFormElementEvents = function (a) {
    var b = a.type, c = this.wrappedOnEv, d = this.wrappedOnMouseDownEv;
    if (a.onchange != c && a.onblur != c && a.onclick != c) {
        if ("file" == b || this.isSetValueType(b) || "textarea" == b)this.addEvent(a, "change", c), this.addEvent(a, "keydown", c); else if ("select-one" == b || "select-multiple" == b)this.addEvent(a, "change", c); else if ("button" == b || "submit" == b || "reset" == b || "checkbox" == b || "radio" == b || "image" == b)this.addEvent(a, this.triggerType, c), this.addEvent(a, "dblclick", c), this.addEvent(a,
            "mousedown", d);
        this.addEvent(a, "contextmenu", c)
    }
};
Sahi.prototype.attachLinkEvents = function (a) {
    this.addWrappedEvent(a, "mousedown", this.onMouseDownEv);
    this.addWrappedEvent(a, this.triggerType, this.onEv);
    this.addWrappedEvent(a, "dblclick", this.onEv)
};
Sahi.prototype.attachImageEvents = function (a) {
    this.addWrappedEvent(a, "mousedown", this.onMouseDownEv);
    this.addWrappedEvent(a, this.triggerType, this.onEv);
    this.addWrappedEvent(a, "dblclick", this.onEv);
    this.addWrappedEvent(a, "contextmenu", this.onEv)
};
Sahi.prototype.addWrappedEvent = function (a, b, c) {
    this.addEvent(a, b, this.wrap(c))
};
Sahi.prototype.addEvent = function (a, b, c) {
    a && (a.attachEvent ? a.attachEvent("on" + b, c) : a.addEventListener && a.addEventListener(b, c, !0))
};
Sahi.prototype.removeEvent = function (a, b, c) {
    a && (a.attachEvent ? a.detachEvent("on" + b, c) : a.removeEventListener && a.removeEventListener(b, c, !0))
};
Sahi.prototype.setRetries = function (a) {
    this.sendToServer("/_s_/dyn/Player_setRetries?retries\x3d" + a)
};
Sahi.prototype.markRetry = function (a) {
    this.sendToServer("/_s_/dyn/Player_markRetry")
};
Sahi.prototype.getRetries = function () {
    var a = parseInt(this.sendToServer("/_s_/dyn/Player_getRetries"));
    return "NaN" != "" + a ? a : 0
};
Sahi.prototype.getExceptionString = function (a) {
    if (a.isSahiError)return a.name + ": " + a.message;
    var b = a.stack;
    return b ? -1 != ("" + b).indexOf(a.message) ? b : a.name + ": " + a.message + "\n" + b : a.name + ": " + a.message + "\nNo trace available"
};
Sahi.prototype.onError = function (a, b, c) {
    try {
        b || (b = "");
        c || (c = "");
        var d = a + " (" + b + ":" + c + ")";
        a && -1 == a.indexOf("Access to XPConnect service denied") && this.setJSError(d, c);
        this.prevOnError && this.prevOnError != this.onError && this.prevOnError(a, b, c)
    } catch (e) {
    }
};
Sahi.prototype.setJSError = function (a, b) {
    this.sendToServer("/_s_/dyn/Player_storeJSError?e\x3d" + this.encode(a));
    this.__jsError = {message: a, lineNumber: b}
};
Sahi.prototype.openWin = function (a) {
    try {
        if (a || (a = window.event), this.controller && !this.controller.closed)this.controller.focus(); else {
            if (this.controller = window.open(this.controllerURL, "sahiControl", this.getWinParams(a)))this.controller.opener = window;
            a && window.setTimeout("_sahi.controller.focus()", 200)
        }
    } catch (b) {
        this.handleException(b)
    }
};
Sahi.prototype.openController = Sahi.prototype.openWin;
Sahi.prototype.closeController = function () {
    var a = this.getController();
    a && !a.closed && a.close()
};
Sahi.prototype.getWinParams = function (a) {
    var b = "", b = a ? a.screenX - 40 : window.screen.width - this.controllerWidth - 50;
    a = a ? a.screenY - 60 : 100;
    b = this._isIE() ? ",left\x3d" + b + ",top\x3d" + a : ",screenX\x3d" + b + ",screenY\x3d" + a;
    return "height\x3d" + this.controllerHeight + "px,width\x3d" + this.controllerWidth + "px,resizable\x3dyes,toolbar\x3dno,status\x3dno" + b
};
Sahi.prototype.getController = function () {
    var a = this.topSahi().controller;
    if (a && !a.closed)return a
};
Sahi.prototype.openControllerWindow = function (a) {
    a || (a = window.event);
    if (!this.isHotKeyPressed(a) || this.lastDblClickEvent == a)return !0;
    this.lastDblClickEvent = a;
    this._isChrome() ? window.setTimeout(function () {
        _sahi.topSahi().openWin(a)
    }, 100) : this.topSahi().openWin(a);
    return !0
};
Sahi.prototype.isHotKeyPressed = function (a) {
    return "SHIFT" == this.hotKey && a.shiftKey || "CTRL" == this.hotKey && a.ctrlKey || "ALT" == this.hotKey && a.altKey || "META" == this.hotKey && a.metaKey
};
Sahi.prototype.mouseOver = function (a) {
    a || (a = window.event);
    try {
        if (null != this.getTarget(a) && a.ctrlKey && !this.isInsideFlex) {
            a && a.ctrlKey && this.sendMessageToController(this.toJSON({
                command: "showPosition",
                value: "[" + a.clientX + ", " + a.clientY + "]"
            }));
            var b = this.getTarget(a), c = b.tagName.toLowerCase();
            if ("embed" == c || "object" == c)try {
                b._sahi_getFlexId();
                return
            } catch (d) {
            }
            this.__lastMousedOverElement = b;
            this.__queuedMouseOverTimer && window.clearTimeout(this.__queuedMouseOverTimer);
            this.__queuedMouseOverTimer = window.setTimeout(this.wrap(this.queuedMouseOver),
                50)
        }
    } catch (e) {
    }
};
Sahi.prototype.queuedMouseOver = function () {
    var a = this.__lastMousedOverElement;
    try {
        this.identifyAndDisplay(a)
    } catch (b) {
    }
};
Sahi.prototype.identifyAndDisplay = function (a) {
    var b = this.identify(this.getKnownTags(a));
    if (null != b && null != b.apis && (acc = 0 < b.apis.length ? b.apis[0] : null)) {
        for (var c = [], d = 0; d < b.apis.length; d++)c[d] = "true" == this.displayAttrType ? this.escapeDollar(this.getAccessorWithAttr(b.apis[d])) : this.escapeDollar(this.getAccessor1(b.apis[d]));
        var e = "";
        if (this.topSahi()._isOR && "sahi" == this.topSahi().controllerMode)for (var f = eval(this.addSahi(this.getAccessor1(acc))), h = this.topSahi().orFileContentAr, d = 0; d < h.length; d++) {
            var g =
                h[d];
            if (-1 != g.indexOf("\x3d")) {
                var k = g.split("\x3d"), g = this.trim(k[0].replace("var ", "")), k = this.trim(k[1]);
                k.endsWith(";") && (k = this.trim(k.substring(0, k.length - 1)));
                if (k.substring(0, k.indexOf("(")) == acc.type && this.areOREntriesEqual(k, f)) {
                    this.top()[g] = f;
                    e = g;
                    f = -1;
                    for (d = 0; d < c.length; d++)if (-1 != c[d].indexOf(k)) {
                        f = d;
                        break
                    }
                    0 != f && (null != this.anchor ? c.splice(c.length, 0, k) : (-1 != f && (k = c[f], c.splice(f, 1)), c.splice(0, 0, k)));
                    break
                }
            }
        }
        this.sendIdentifierInfo(c, e, this.escapeValue(acc.value), this.getPopupDomainPrefixes(a),
            b.assertions)
    }
};
Sahi.prototype.xsendIdentifierInfo = function (a, b, c, d, e) {
    this.getController().displayInfo(a, b, c, d, e)
};
Sahi.prototype.sendIdentifierInfo = function (a, b, c, d, e) {
    this.sendMessageToController(this.toJSON({
        command: "showAccessor",
        value: {accessors: a, accessor: b, value: c, popupName: d, assertions: e}
    }))
};
Sahi.prototype.showCoords = function (a) {
    var b = a.clientX;
    a = a.clientY;
    try {
        var c = this.getController();
        c && !c.closed && c.showCoords(b, a)
    } catch (d) {
    }
};
Sahi.prototype.escapeDollar = function (a) {
    return a
};
Sahi.prototype.getAccessorWithAttr = function (a) {
    return null == a || "" == "" + a.shortHand || null == a.shortHand ? null : null != a.attr && "" != a.attr ? "[" + a.attr.toUpperCase() + "] " + a.type + "(" + this.escapeForScript(a.shortHand) + (a.relationStr ? ", " + a.relationStr : "") + ")" : a.type + "(" + this.escapeForScript(a.shortHand) + (a.relationStr ? ", " + a.relationStr : "") + ")"
};
Sahi.prototype.getAccessor1 = function (a) {
    return null == a || "" == "" + a.shortHand || null == a.shortHand ? null : a.type + "(" + this.escapeForScript(a.shortHand) + (a.relationStr ? ", " + a.relationStr : "") + ")"
};
Sahi.prototype.escapeForScript = function (a) {
    return this.quoteIfString(a)
};
Sahi.prototype.schedule = function (a, b) {
    if (this.cmds) {
        var c = this.cmds.length;
        this.cmds[c] = a;
        this.cmdDebugInfo[c] = b
    }
};
Sahi.prototype.instant = function (a, b) {
    if (this.cmds) {
        var c = this.cmdsLocal.length;
        this.cmdsLocal[c] = a;
        this.cmdDebugInfoLocal[c] = b
    }
};
Sahi.prototype._setXHRReadyStatesToWaitFor = function (a) {
    this.setWaitForXHRReadyStates(a);
    this.sendToServer("/_s_/dyn/SessionState_setXHRReadyStatesToWaitFor?states\x3d" + this.encode(a))
};
Sahi.prototype.setWaitForXHRReadyStates = function (a) {
    this.waitWhenXHRReadyState1 = -1 != a.indexOf("1");
    this.waitWhenXHRReadyState2 = -1 != a.indexOf("2");
    this.waitWhenXHRReadyState3 = -1 != a.indexOf("3")
};
Sahi.prototype.showOpenXHRs = function () {
    for (var a = this.XHRs, b = "", c = 0; c < a.length; c++) {
        var d = a[c];
        if (d)try {
            4 != d.readyState && (b += "this.XHRs[" + c + "] " + d + ": xsi.readyState\x3d" + d.readyState + "\n")
        } catch (e) {
            b += e
        }
    }
    return b
};
Sahi.prototype.areXHRsDone = function () {
    for (var a = this.XHRs, b = [], c = [], d = this.SAHI_MAX_WAIT_FOR_LOAD * this.INTERVAL, e = (new Date).getTime(), f = 0; f < a.length; f++) {
        var h = a[f];
        if (h) {
            var g = this.XHRTimes[f];
            if (-1 != g)if (e - g > d)this.XHRTimes[f] = -1; else if (4 != h.readyState && (b.push(h), c.push(this.XHRTimes[f])), g = this.waitWhenXHRReadyState1 || 1E3 > e - g, h = h.readyState, 1 == h && g || 2 == h && this.waitWhenXHRReadyState2 || 3 == h && this.waitWhenXHRReadyState3)return !1
        }
    }
    this.resetOpenXHRs(b, c);
    return !0
};
Sahi.prototype.resetOpenXHRs = function (a, b) {
    this.XHRs = a;
    this.XHRTimes = b
};
Sahi.prototype._setFlexReadyCondition = function (a) {
    this.flexWaitCondition = a
};
Sahi.prototype.areFlexAppsLoaded = function (a) {
    for (var b = [], b = this._isIE() ? a.document.getElementsByTagName("OBJECT") : a.document.getElementsByTagName("EMBED"), c = 0; c < b.length; c++) {
        var d = b[c];
        try {
            d._sahi_getFlexId();
            var e = this.getFlexWrapper(d);
            try {
                if (0 != e.currentCursorID())return !1
            } catch (f) {
            }
            if (this.flexWaitCondition && !this.flexWaitCondition(e))return !1
        } catch (h) {
            try {
                if (100 != d.PercentLoaded())return !1
            } catch (g) {
            }
        }
    }
    if ((b = a.frames) && a.frames)for (a = !0, c = 0; c < b.length; c++)try {
        if (a = this.areFlexAppsLoaded(b[c]),
                !a)return !1
    } catch (k) {
    }
    return !0
};
Sahi.prototype.d = function (a) {
    this.updateControlWinDisplay(a)
};
Sahi.prototype.areWindowsLoaded = function (a) {
    try {
        if ("about:blank" == a.location.href)return !0
    } catch (b) {
        return !0
    }
    try {
        var c = a.frames;
        if (c && 0 != c.length) {
            "listIframe" == a.name && this.d("fs.length\x3d" + c.length);
            for (var d = 0; d < c.length; d++)try {
                if (this.isWindowAccessible(c[d]) && "about:blank" != "" + c[d].location && !c[d]._sahi.areWindowsLoaded(c[d]))return !1
            } catch (e) {
            }
            return a.document && 0 == this.getElementsByTagName("frameset", a.document).length ? (this._isIE() || this.isChrome33Minus()) && "complete" == a.document.readyState ||
            this.loaded : !0
        }
        try {
            return this._isIE() && "complete" == a.document.readyState || this.loaded
        } catch (f) {
            return !0
        }
    } catch (h) {
        return !0
    }
};
var _isLocal = !1;
Sahi._timer = null;
Sahi.prototype.hasErrors = function () {
    return "true" == this.sendToServer("/_s_/dyn/Player_hasErrors")
};
Sahi.prototype.getCurrentStep = function () {
    this.isPopup();
    try {
        this.top()
    } catch (a) {
    }
    try {
        this.getTitle()
    } catch (b) {
    }
    try {
        this.top()
    } catch (c) {
    }
    var d = this.sendToServer("/_s_/dyn/Player_getCurrentStep?" + this.getWindowDomainQS()), d = this.decode(d);
    return eval("(" + d + ")")
};
Sahi.prototype.getWindowDomainQS = function () {
    var a = 1, b = "", c = "", d = "";
    try {
        a = null == this.top().opener || this.top().opener._sahi.top() == this.top() ? 0 : 1
    } catch (e) {
    }
    try {
        b = this.top().name
    } catch (f) {
    }
    try {
        c = this.getTitle()
    } catch (h) {
    }
    try {
        d = this.top().location.href
    } catch (g) {
    }
    return "derivedName\x3d" + this.getPopupName() + "\x26wasOpened\x3d" + a + "\x26windowName\x3d" + this.encode(b) + "\x26windowTitle\x3d" + this.encode(c) + "\x26windowURL\x3d" + this.encode(d) + "\x26domain\x3d" + this.encode(this.getDomainContext())
};
Sahi.prototype.getDomainContext = function () {
    return this.top() == this.absoluteTop() ? "" : document.domain
};
Sahi.prototype.markStepDone = function (a, b, c, d) {
    this.lastStepInfo && a == this.lastStepInfo[0] && b == this.lastStepInfo[1] && c == this.lastStepInfo[2] || (this.interval = this.INTERVAL, this.lastStepInfo = [a, b, c], b = d ? "stepId\x3d" + a + (c ? "\x26failureMsg\x3d" + this.encode(c) : "") + "\x26type\x3d" + b + "\x26lastImageFilePath\x3d" + d : "stepId\x3d" + a + (c ? "\x26failureMsg\x3d" + this.encode(c) : "") + "\x26type\x3d" + b, this.sendToServer("/_s_/dyn/Player_markStepDone?" + b), b = this.sendToServer("/_s_/dyn/SessionState_isScreenCapture"), b = this.decode(b).split("__SAHIDELIMITER__"),
    "true" == b[0] && /PhantomJS/.test(this.navigator.userAgent) && this.triggerPhantom("___sahi___format___" + b[1]), this.lastStepId = a)
};
Sahi.prototype.markStepInProgress = function (a, b, c) {
    a = "stepId\x3d" + a + "\x26type\x3d" + b;
    c && (a += "\x26timeout\x3d" + c);
    this.sendToServer("/_s_/dyn/Player_markStepInProgress?" + a)
};
Sahi.prototype.ping = function () {
    try {
        _sahi.pingTimer = window.setTimeout(function () {
            _sahi.ping()
        }, 5E3);
        var a = this.top();
        if (a != window)a == this.absoluteTop() ? _sahi.pingTimer && window.clearTimeout(_sahi.pingTimer) : this.pingReset(); else {
            try {
                if (this.isChrome33Minus() && "complete" == window.document.readyState)this.onWindowLoad()
            } catch (b) {
            }
            var c = this.createRequestObject();
            c.onreadystatechange = function () {
                if (4 == c.readyState)try {
                    if (200 == c.status) {
                        var a = window.eval("(" + c.responseText + ")");
                        _sahi.pingCallback(a)
                    }
                } catch (b) {
                }
            };
            c.open("POST", this.makeFullURL("/_s_/dyn/SessionState_ping"), !0);
            var d = (new Date).getTime() + Math.floor(1E4 * Math.random());
            c.send("sahisid\x3d" + encodeURIComponent(this.sid) + "\x26t\x3d" + encodeURIComponent(d) + "\x26" + this.getWindowDomainQS())
        }
    } catch (e) {
    }
};
Sahi.prototype.makeFullURL = function (a) {
    var b = window.location.href, b = b.substring(0, b.indexOf("/", 8));
    return b + a
};
Sahi.prototype.pingCallback = function (a) {
    try {
        this.setState(a);
        var b = a.stepInfo;
        null != b ? this.evalStep(b) : this.interval = this.IDLE_PING_INTERVAL;
        this.handleControllerMessage(a)
    } catch (c) {
    } finally {
        this.pingReset()
    }
};
Sahi.prototype.pingReset = function () {
    _sahi.pingTimer && window.clearTimeout(_sahi.pingTimer);
    _sahi.pingTimer = window.setTimeout(function () {
        _sahi.ping()
    }, this.interval)
};
Sahi.prototype.evalStep = function (a) {
    this.currentStepInfo = a;
    var b = a.step, c = a.stepId, d = a.type;
    this.isScreenCaptureOn = a.screenCapture;
    try {
        if (this.isReadyForStep())if ("WAIT" == d) {
            if (b && "null" != b) {
                try {
                    var e = eval(b)
                } catch (f) {
                }
                e && this.markStepDone(c, "info")
            }
        } else if (this.lastStepId != c)if (d = -1 != b.indexOf("_sahi._assert") ? "success" : "NO_LOG" == d ? "NO_LOG" : "info", -1 != b.indexOf("_click") && this.invokeLastBlur())this.interval = 0; else {
            this.currentStepId = c;
            if (1 == this.currentStepId)try {
                var h = _sahi.sendToServer("/_s_/dyn/Player_script/script.js");
                window.eval(h)
            } catch (g) {
                this._log("Error in browser tag code: " + h, "CUSTOM")
            }
            this.currentType = d;
            this.markStepInProgress(c, d);
            this.reAttachEvents();
            this.xyoffsets = new Sahi.Dict;
            this.forked = !1;
            -1 != b.indexOf("setServerVarForFetch") && this.fork(2E4);
            try {
                eval(b), this.forked || this.afterEval()
            } catch (k) {
                if (this.interval = this.ONERROR_INTERVAL, a.canRetry)this.markRetry(); else if (k instanceof SahiAssertionException || 0 == b.indexOf("_sahi._assert")) {
                    var l = k instanceof SahiAssertionException ? k.toString() : "Assertion Failed. " +
                    (k.messageText ? k.messageText : this.getJSErrorMessage(k));
                    this.markStepDone(c, "failure", l)
                } else {
                    var q = this.getJSErrorMessage(k);
                    this.markStepDone(c, "error", q)
                }
            }
        }
    } catch (n) {
    }
};
Sahi.prototype.handleControllerMessage = function (a) {
    a = a.msgFromC;
    var b = "";
    if (a && "null" != a) {
        var c = a.command;
        try {
            if ("eval" == c) {
                var d = this.doNotRecord;
                this.doNotRecord = !0;
                try {
                    var e = a.value.replace("_sahi.", "");
                    if (this.topSahi()._isOR && "sahi" == this.topSahi().controllerMode)for (var f = this.getVariables(e).split(","), h = 0; h < f.length; h++)if ("" != f[h]) {
                        var g = f[h], k = this.sendToServer("/_s_/dyn/Recorder_getORValue?filepath\x3d" + this.orFilePath + "\x26orkey\x3d" + g).toString();
                        this.top()[g] = eval(this.addSahi(k))
                    }
                    this.xyoffsets =
                        new Sahi.Dict;
                    b = (b = eval(a.value)) && b.isSFL ? b.exists() ? e + ".exists() \x3d true\n\n" + e + ".listProperties() \x3d \n" + b.listProperties() + "\n\n" + e + ".introspect() \x3d \n" + b.introspect() : e + ".exists() \x3d null" : "" + b
                } catch (l) {
                    b = "" + l
                } finally {
                    this.doNotRecord = d
                }
            } else"assert" == c ? b = this.doAssert(a.accessor, a.value) : "setAnchor" == c ? b = this.setAnchor(a.value) : "removeAnchor" == c ? b = this.removeAnchor() : "listProperties" == c ? b = this.list(eval(a.value)) : "recordStep" == c ? (h = this.isOREnabled ? this.getOREntry2(a.accessor) : null,
                b = this.recordStep(a.value, h, !0, this.getDomainContext(), this.getPopupName())) : "getAccessorPropsMap" == c ? this.getAccessorPropsMap(a.value) : "saveORValue" == c && this.saveORValue(a.oldValue, a.newValue)
        } catch (q) {
            b = "" + q
        }
        a.returnResult && this.sendMessageToController(this.toJSON({
            command: "showResult",
            value: b,
            target: a.returnResult
        }))
    }
};
Sahi.prototype.saveORValue = function (a, b) {
    this.sendToServer("/_s_/dyn/Recorder_changeOREntry?filepath\x3d" + this.orFilePath + "\x26oldvalue\x3d" + a + "\x26newvalue\x3d" + b);
    this.topSahi().orFileContentAr = this.sendToServer("/_s_/dyn/Recorder_getORFileContent?filepath\x3d" + this.orFilePath).toString().split("__SAHIDELIMITER__")
};
Sahi.prototype.getAccessorPropsMap = function (a) {
    a = eval(a);
    var b = {sahiAccessorProps: !0};
    if (a)for (var c in a)if ("number" != typeof c)try {
        b[c] = "" + a[c]
    } catch (d) {
        b[c] = ""
    }
    this.sendMessageToController(this.toJSON({command: "setAccessorProps", value: b}))
};
Sahi.prototype.isReadyForStepDefault = function () {
    var a = this.top();
    !(this.byPassWaitMechanism || this.areWindowsLoaded(a) && this.areXHRsDone() && this.areFlexAppsLoaded(a)) && 0 < this.waitForLoad && (this.stabilityIndex = 0);
    return this.stabilityIndex < this.STABILITY_INDEX ? (this.stabilityIndex += 1, this.waitForLoad -= 1, this._isIE() || 0 != this.waitForLoad % 20 || this.check204Response(a), !1) : !0
};
Sahi.prototype.isReadyForStep = function () {
    return this.isReadyForStepDefault()
};
Sahi.prototype.sendMessageToController = function (a) {
    this.sendToServer("/_s_/dyn/ControllerUI_setMessageToController?msg\x3d" + encodeURIComponent(a))
};
Sahi.prototype.setState = function (a) {
    try {
        window.eval(a.browserJSDelta)
    } catch (b) {
    }
    a.isRecording ? this.startRecording() : this.stopRecording();
    var c = this.topSahi();
    c.orFilePath != a.orFilePath && (c.orFilePath = a.orFilePath, "true" == this.sendToServer("/_s_/dyn/Driver_isFileExists?filePath\x3d" + a.orFilePath) ? c.orFileContentAr = this.sendToServer("/_s_/dyn/" + this.recorderClass + "_getORFileContent?filepath\x3d" + a.orFilePath).toString().split("__SAHIDELIMITER__") : c.orFileContentAr = []);
    c._isOR = a.isOR;
    c._isPlaying = a.isPlaying;
    c.isAccessorIgnoreCase = a.isAccessorIgnoreCase;
    c.SKIP_SCREENSHOTS = a.isSkipScreenShot;
    c.SKIP_ASSERT_SNAPSHOTS = a.isSkipAssertSnapShot
};
Sahi.prototype.fork = function (a) {
    this.forked = !0;
    this.markStepInProgress(this.currentStepId, this.currentType, a)
};
Sahi.prototype.afterEval = function () {
    this.lastImageFilePath ? (this.markStepDone(this.currentStepId, this.currentType, "", this.lastImageFilePath), this.lastImageFilePath = null) : this.markStepDone(this.currentStepId, this.currentType);
    this.waitForLoad = this.SAHI_MAX_WAIT_FOR_LOAD
};
Sahi.prototype._openWindow = function (a, b, c) {
    null == c && (c = "");
    null == b && (b = "");
    null == a && (a = "");
    window.open(a, b, "width\x3d" + c[0] + ",height\x3d" + c[1] + ",scrollbars\x3d1")
};
Sahi.prototype.getWinDimensions = function (a) {
    var b = 0, c = 0;
    this._isIE() ? "BackCompat" == document.compatMode ? (b = parseInt(a.document.body.clientWidth), c = parseInt(a.document.body.clientHeight)) : (b = parseInt(a.document.documentElement.clientWidth), c = parseInt(a.document.documentElement.clientHeight)) : (c = parseInt(a.innerHeight), b = parseInt(a.innerWidth));
    return [b, c]
};
Sahi.prototype.xgetWinDimensions = function () {
    var a = 630, b = 460;
    this._isIE() && document.body && document.body.clientWidth ? (a = document.body.clientWidth, b = document.body.clientHeight) : this._isFF() ? (a = document.body.offsetWidth, window.innerWidth < a && (a = window.innerWidth), b = window.innerHeight) : this._isChrome() ? (a = document.body.offsetWidth, b = document.body.offsetHeight) : (document.body && document.body.offsetWidth && (a = document.body.offsetWidth, b = document.body.offsetHeight), "CSS1Compat" == document.compatMode && document.documentElement &&
    document.documentElement.offsetWidth && (a = document.documentElement.offsetWidth, b = document.documentElement.offsetHeight), window.innerWidth && window.innerHeight && (a = window.innerWidth, b = window.innerHeight));
    return [a, b]
};
Sahi.prototype.getWinPosition = function () {
    if (this._isFF() || this._isSafari() || this._isChrome()) {
        var a = window.screenX + (window.outerWidth - window.innerWidth) - 8, b = window.screenY + (window.outerHeight - window.innerHeight) - 8;
        return [a, b]
    }
    return this._isIE() ? (a = window.screenLeft + 2, b = window.screenTop + 2, [a, b]) : [window.screenLeft, window.screenTop]
};
Sahi.prototype.xcheckForScrollAndCapture = function (a) {
    var b = this.fetchTopXY(), c = b[0], b = b[1];
    this.getWinDimensions();
    var d = this._isIE() ? parseInt(document.documentElement.clientWidth) : parseInt(window.innerWidth), e = this._isIE() ? parseInt(document.documentElement.clientHeight) : parseInt(window.innerHeight);
    window.scrollTo(0, 0);
    var f = 0;
    this.takeSnapShot(a, f, b, c, e, d);
    f++;
    for (var h = this._isIE() ? parseInt(document.documentElement.clientHeight) : parseInt(window.innerHeight), g = parseInt(document.body.scrollHeight); g -
    h > h;)window.scrollBy(0, h), g -= h, this.takeSnapShot(a, f, b, c, e, d), f++;
    g - h < h && 0 < g - h && (window.scrollBy(0, g - h), g -= h, this.takeSnapShot(a, f, b + h - g, c, g, d), f++);
    return this.stitchSnapShots(a, f, "V")
};
Sahi.prototype.takeHorSnapShots = function (a, b, c, d, e, f) {
    a = a + "temp" + b;
    window.scrollTo(0, this.getScrollOffsetY());
    b = 0;
    this.takeSnapShot(a, b, c, d, e, f);
    b++;
    for (var h = this._isIE() ? parseInt(document.body.clientWidth) : parseInt(window.innerWidth), g = parseInt(document.body.scrollWidth); g - h > h;)window.scrollBy(h, 0), g -= h, this.takeSnapShot(a, b, c, d, e, f), b++;
    g - h < h && 0 < g - h && (window.scrollBy(g - h, 0), g -= h, this.takeSnapShot(a, b, c, d + h - g, e, g), b++);
    return this.stitchSnapShots(a, b, "H")
};
Sahi.prototype.stitchSnapShots = function (a, b, c, d, e, f, h, g, k, l, q) {
    return null !== this.fileSysPath ? this.sendToServer("/_s_/dyn/Player_stitchSnapShots?stepId\x3d" + a + "\x26finalIx\x3d" + b + "\x26dir\x3d" + c + "\x26top\x3d" + d + "\x26left\x3d" + e + "\x26height\x3d" + f + "\x26width\x3d" + h + "\x26noLog\x3d" + g + "\x26format\x3d" + k + "\x26resizePercentage\x3d" + l + "\x26fileSysPath\x3d" + q) : this.sendToServer("/_s_/dyn/Player_stitchSnapShots?stepId\x3d" + a + "\x26finalIx\x3d" + b + "\x26dir\x3d" + c + "\x26top\x3d" + d + "\x26left\x3d" + e + "\x26height\x3d" +
        f + "\x26width\x3d" + h + "\x26noLog\x3d" + g + "\x26format\x3d" + k + "\x26resizePercentage\x3d")
};
Sahi.prototype.takeSnapShot = function (a, b, c, d, e, f, h, g) {
    g || (g = !1);
    this.sendToServer("/_s_/dyn/Player_takeSnapShot?stepId\x3d" + a + "\x26tempIx\x3d" + b + "\x26top\x3d" + c + "\x26left\x3d" + d + "\x26height\x3d" + e + "\x26width\x3d" + f + "\x26isPhantomjs\x3d" + g + "\x26format\x3d" + h)
};
Sahi.prototype.takeSnapShotPhantomJS = function (a, b, c) {
    if ("function" === typeof window.callPhantom)return window.callPhantom("___sahi___format___" + c), this.sendToServer("/_s_/dyn/Player_takeSnapShot?stepId\x3d" + a + "\x26tempIx\x3d" + b + "\x26isPhantomjs\x3dtrue\x26format\x3d" + c)
};
Sahi.prototype.triggerPhantom = function (a) {
    "function" === typeof window.callPhantom && window.callPhantom(a)
};
Sahi.prototype.getJSErrorMessage2 = function (a, b) {
    if ("sahi" == _sahi.controllerMode) {
        for (var c = a.split("\n"), d = "", e = 0; e < c.length; e++) {
            var f = c[e];
            -1 == f.indexOf("_s_/spr") && -1 == f.indexOf("at eval code") && (d += f + "\n")
        }
        c = "/_s_/dyn/Log_getBrowserScript?href\x3d" + this._scriptPath() + "\x26n\x3d" + b;
        return d + ("\n\x3ca href\x3d'" + c + "'\x3e\x3cb\x3eClick for browser script\x3c/b\x3e\x3c/a\x3e")
    }
    return a
};
Sahi.prototype.getJSErrorMessage = function (a) {
    var b = this.getExceptionString(a), c = a.lineNumber ? a.lineNumber : -1;
    return a.isSahiError ? b : this.getJSErrorMessage2(b, c)
};
Sahi.prototype.check204Response = function (a) {
    !0 != a._sahi.loaded && "true" == this.sendToServer("/_s_/dyn/Player_check204") && (a._sahi.loaded = !0);
    if (a = a.frames)for (var b = 0; b < a.length; b++)try {
        this.check204Response(a[b])
    } catch (c) {
    }
};
Sahi.prototype.topSahi = function () {
    return this.top()._sahi
};
Sahi.prototype.updateControlWinDisplay = function (a, b) {
    try {
        var c = this.getController();
        c && !c.closed && (c.displayLogs(a.replace(/_sahi[.]/g, ""), b), null != b && c.displayStepNum(b))
    } catch (d) {
    }
};
Sahi.prototype.setCurrentIndex = function (a) {
    this.startFromStep = a
};
Sahi.prototype.isPlaying = function () {
    return this.topSahi()._isPlaying
};
Sahi.prototype.xstartPlaying = function () {
    this.sendToServer("/_s_/dyn/Player_start")
};
Sahi.prototype.xstepWisePlay = function () {
    this.sendToServer("/_s_/dyn/Player_stepWisePlay")
};
Sahi.prototype.xshowStopPlayingMessage = function () {
    this.updateControlWinDisplay("--Stopped Playback: " + (this.hasErrors() ? "FAILURE" : "SUCCESS") + "--")
};
Sahi.prototype.startRecording = function () {
    !0 != this.topSahi()._isRecording && (this.topSahi()._isRecording = !0, this.addHandlersToAllFrames(this.top()))
};
Sahi.prototype.stopRecording = function () {
    this.topSahi()._isRecording && (this.topSahi()._isRecording = !1)
};
Sahi.prototype.getLogQS = function (a, b, c, d, e) {
    return "msg\x3d" + this.encode(a) + "\x26type\x3d" + b + (c ? "\x26debugInfo\x3d" + this.encode(c) : "") + (e ? "\x26image\x3d" + this.encode(e) : "") + (d ? "\x26failureMsg\x3d" + this.encode(d) : "")
};
Sahi.prototype.logPlayBack = function (a, b, c, d, e) {
    this.sendToServer("/_s_/dyn/TestReporter_logTestResult?" + this.getLogQS(a, b, c, d, e))
};
Sahi.prototype.compare = function (a, b) {
    var c = "equal";
    if (a == b)return c;
    if (a instanceof Array && b instanceof Array)c = this.compareArrays(a, b); else if (a instanceof Object && b instanceof Object)c = this.compareObjects(a, b); else if (!this.areEqualParams(this.trim(b), this.checkRegex(this.trim(a))))return {
        errorMsg: "Expected: " + this.toJSON(a) + "\nActual: " + this.toJSON(b),
        stack: []
    };
    return c
};
Sahi.prototype.compareArrays = function (a, b) {
    if (null == a && null == b)return "Both the arrays are null";
    if (null == a || null == b)return "One of the arrays is null";
    if (a.length != b.length && typeof a == typeof b)return {
        errorMsg: "Difference in length of arrays:\nExpected Length:[" + a.length + "]\nActual Length:[" + b.length + "]",
        stack: []
    };
    for (var c = "equal", d = 0; d < a.length; d++)if (c = this.compare(a[d], b[d]), c.errorMsg) {
        c.stack.push("[" + d + "]");
        break
    }
    return c
};
Sahi.prototype.compareObjects = function (a, b) {
    var c = 0, d = 0, e = {}, f;
    for (f in a) {
        if (!b.hasOwnProperty(f))return {errorMsg: "Expected property '" + f + "' does not exist.", stack: []};
        e = this.compare(a[f], b[f]);
        if (e.errorMsg)return e.stack.push("[" + this.quoted(f) + "]"), e;
        c++
    }
    if (0 < c) {
        for (f in b)d++;
        if (c != d)return {
            errorMsg: "Difference in length of objects:\nExpected Length: " + c + "\nActual Length: " + d,
            stack: []
        }
    }
    return e
};
Sahi.prototype.lowerCase = function (a) {
    return null == a || "string" != typeof a ? a : a.toLowerCase()
};
Sahi.prototype.trim = function (a) {
    if (null == a || "string" != typeof a)return a;
    a = a.replace(/\xA0/g, " ").replace(/\s\s*/g, " ");
    var b = /\s/, c = b.test(a.charAt(0)) ? 1 : 0, b = b.test(a.charAt(a.length - 1)) ? a.length - 1 : a.length;
    return a.slice(c, b)
};
Sahi.prototype.list = function (a) {
    if (this.isFlexObj(a))return a.introspect() + "\n" + a.listProperties();
    var b = "", c = "", d = 0;
    if ("array" == typeof a)for (var e = 0; e < a.length; e++)b += e + "\x3d" + a[e];
    if ("object" == typeof a)for (e in a)try {
        a[e] && a[e] != a && (0 == ("" + a[e]).indexOf("function") ? c += e + "\n" : ("object" == typeof a[e] && a[e] != a.parentNode && (b += e + "\x3d{{" + a[e] + "}};\n"), b += e + "\x3d" + a[e] + ";\n", d++))
    } catch (f) {
        b += "" + e + "\n"
    } else b += a;
    return b + "\n\n-----Functions------\n\n" + c
};
Sahi.prototype.findInArray = function (a, b) {
    for (var c = a.length, d = 0; d < c; d++)if (a[d] == b)return d;
    return -1
};
Sahi.prototype._isPhantomJS = function () {
    return /PhantomJS/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE = function () {
    return "Microsoft Internet Explorer" == this.navigator.appName || this.navigator.appVersion && -1 != this.navigator.appVersion.indexOf("Trident")
};
Sahi.prototype._isIE6 = function () {
    return /MSIE 6[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE7 = function () {
    return /MSIE 7[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE8 = function () {
    return /MSIE 8[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE9 = function () {
    return /MSIE 9[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE10 = function () {
    return /MSIE 10[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE11 = function () {
    return !this._isChrome() && this._isIE() && 11 == document.documentMode
};
Sahi.prototype._isIE11Plus = function () {
    return !this._isChrome() && this._isIE() && 11 <= document.documentMode
};
Sahi.prototype._isIE9Plus = function () {
    return this._isIE() && !/MSIE [0-8][.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isIE9StrictMode = function () {
    return this._isIE() && 9 == document.documentMode
};
Sahi.prototype._isIE9PlusStrictMode = function () {
    return this._isIE() && 9 <= document.documentMode
};
Sahi.prototype._isFF2 = function () {
    return /Firefox\/2[.]|Iceweasel\/2[.]|Shiretoko\/2[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isFF3 = function () {
    return /Firefox\/3[.]|Iceweasel\/3[.]|Shiretoko\/3[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isFF4 = function () {
    return /Firefox\/4[.]|Iceweasel\/4[.]|Shiretoko\/4[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isFF5 = function () {
    return /Firefox\/5[.]|Iceweasel\/5[.]|Shiretoko\/5[.]/.test(this.navigator.userAgent)
};
Sahi.prototype._isFF4Plus = function () {
    return this._isFF() && !this._isFF2() && !this._isFF3()
};
Sahi.prototype._isFF = function () {
    return /Firefox|Iceweasel|Shiretoko/.test(this.navigator.userAgent)
};
Sahi.prototype._isChrome = function () {
    return /Chrome/.test(this.navigator.userAgent) && !this._isOpera()
};
Sahi.prototype._isSafari = function () {
    return /Safari/.test(this.navigator.userAgent) && !/Chrome/.test(this.navigator.userAgent)
};
Sahi.prototype._isOpera = function () {
    return /Opera/.test(this.navigator.userAgent) || /OPR/.test(this.navigator.userAgent)
};
Sahi.prototype.isSafariLike = function () {
    return /Konqueror|Safari|KHTML/.test(this.navigator.userAgent)
};
Sahi.prototype._isHTMLUnit = function () {
    return /HTMLUnit/.test(this.navigator.userAgent)
};
Sahi.prototype._userAgent = function () {
    return this.navigator.userAgent
};
Sahi.prototype.getChromeVersion = function () {
    var a = window.navigator.appVersion.match(/Chrome\/(\d+)\./);
    return a ? parseInt(a[1], 10) : 0
};
Sahi.prototype.isChrome33 = function () {
    return this._isChrome() && 33 == this.getChromeVersion()
};
Sahi.prototype.isChrome33Minus = function () {
    return this._isChrome() && 33 >= this.getChromeVersion()
};
Sahi.prototype.createRequestObject = function () {
    if (window.XMLHttpRequest)try {
        return new XMLHttpRequest
    } catch (a) {
    }
    if (window.ActiveXObject)return new ActiveXObject("Microsoft.XMLHTTP")
};
Sahi.prototype._getFFVersion = function () {
    var a = navigator.userAgent.match(/(Firefox|Iceweasel|Shiretoko)[\/]([0-9]+)/);
    return a && 3 == a.length ? parseInt(a[2]) : -1
};
Sahi.prototype.getServerVar = function (a, b) {
    var c = this.sendToServer("/_s_/dyn/SessionState_getVar?name\x3d" + this.encode(a) + "\x26isglobal\x3d" + (b ? 1 : 0));
    return eval("(" + this.decode(c) + ")")
};
Sahi.prototype.setServerVar = function (a, b, c) {
    this.sendToServer("/_s_/dyn/SessionState_setVar?name\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(this.toJSON(b)) + "\x26isglobal\x3d" + (c ? 1 : 0))
};
Sahi.prototype.setServerVarForFetch = function (a, b, c) {
    this.setServerVar(a, b, c);
    this.afterEval()
};
Sahi.prototype.setServerVarForFetchPlain = function (a, b, c) {
    this.sendToServer("/_s_/dyn/SessionState_setVar?name\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(b) + "\x26isglobal\x3d" + (c ? 1 : 0));
    this.afterEval()
};
Sahi.prototype.getVarRemember = function (a, b) {
    var c = this.sendToServer("/_s_/dyn/SessionState_getVarRemember?name\x3d" + this.encode(a) + "\x26isglobal\x3d" + (b ? 1 : 0));
    return eval("(" + this.decode(c) + ")")
};
Sahi.prototype.setVarRemember = function (a, b, c) {
    this.sendToServer("/_s_/dyn/SessionState_setVarRemember?name\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(this.toJSON(b)) + "\x26isglobal\x3d" + (c ? 1 : 0))
};
Sahi.prototype.getVarStatic = function (a, b) {
    var c = this.sendToServer("/_s_/dyn/SessionState_getVarStatic?name\x3d" + this.encode(a) + "\x26isglobal\x3d" + (b ? 1 : 0));
    return eval("(" + this.decode(c) + ")")
};
Sahi.prototype.setVarStatic = function (a, b, c) {
    this.sendToServer("/_s_/dyn/SessionState_setVarStatic?name\x3d" + this.encode(a) + "\x26value\x3d" + this.encode(this.toJSON(b)) + "\x26isglobal\x3d" + (c ? 1 : 0))
};
Sahi.prototype.logErr = function (a) {
    this.sendToServer("/_s_/dyn/Log?msg\x3d" + this.encode(a) + "\x26type\x3derr")
};
Sahi.prototype._startHarLogging = function () {
    this.sendToServer("/_s_/dyn/SessionState_setHarLoggingStatus?enableHar\x3dtrue")
};
Sahi.prototype._stopHarLogging = function () {
    this.sendToServer("/_s_/dyn/SessionState_setHarLoggingStatus?enableHar\x3dfalse")
};
Sahi.prototype.getParentNode = function (a, b, c, d) {
    c || (c = 1);
    for (var e = 0, f = a = a.parentNode; a && !this.areTagNamesEqual(a.tagName, "body") && !this.areTagNamesEqual(a.tagName.toLowerCase(), "html");) {
        if (this.areTagNamesEqual(b, "ANY") || this.areTagNamesEqual(a.tagName, b))if (e++, c == e)return a;
        f = a;
        a = a.parentNode
    }
    return d ? f : null
};
Sahi.prototype.sendToServer = function (a, b) {
    try {
        0 == a.indexOf("/_s_/") && (a = this.makeFullURL(a));
        var c = (new Date).getTime() + Math.floor(1E4 * Math.random()), d = this.createRequestObject();
        a = a + (-1 == a.indexOf("?") ? "?" : "\x26") + "t\x3d" + c;
        a = a + "\x26sahisid\x3d" + encodeURIComponent(this.sid);
        var e = a.substring(a.indexOf("?") + 1);
        a = a.substring(0, a.indexOf("?"));
        d.open("POST", a, !0 === b);
        d.send(e);
        return d.responseText
    } catch (f) {
        this.handleException(f)
    }
};
var s_v = function (a) {
    var b = typeof a;
    return "number" == b ? a : "string" == b ? '"' + a.replace(/\r/g, "\\r").replace(/\n/g, "\\n").replace(/"/g, '\\"') + '"' : a
};
Sahi.prototype.quoted = function (a) {
    return '"' + a.replace(/"/g, '\\"') + '"'
};
Sahi.prototype.handleException = function (a) {
};
Sahi.prototype.convertUnicode = function (a) {
    return _sahi.escapeUnicode ? this.unicode(a) : a
};
Sahi.prototype.unicode = function (a) {
    if (null == a)return null;
    for (var b = "", c = 0; c < a.length; c++)b = 127 < a.charCodeAt(c) ? b + this.addSlashU(a.charCodeAt(c).toString(16)) : b + a.charAt(c);
    return b
};
Sahi.prototype.addSlashU = function (a) {
    var b;
    switch (a.length) {
        case 1:
            b = "\\u000" + a;
            break;
        case 2:
            b = "\\u00" + a;
            break;
        case 3:
            b = "\\u0" + a;
            break;
        case 4:
            b = "\\u" + a
    }
    return b
};
Sahi.prototype.reAttachEvents = function () {
    var a = this.top();
    this.areWindowsLoaded(a) && (this.reAttachSahi(a), this.isRecording() && this.addHandlersToAllFrames(a))
};
_sahi.top() == window && window.setInterval(_sahi.wrap(_sahi.reAttachEvents), 500);
Sahi.prototype.reAttachSahi = function (a) {
    try {
        try {
            this.isWindowAccessible(a) && !a._sahi && this.reAttachSahiToWin(a)
        } catch (b) {
        }
        var c = a.frames;
        if (c && 0 < c.length)for (a = 0; a < c.length; a++)try {
            var d = c[a];
            !this.isWindowAccessible(d) || this._isHTMLUnit() && d.location.href && -1 != d.location.href.indexOf(".gif") || this.reAttachSahi(d)
        } catch (e) {
        }
    } catch (f) {
    }
};
Sahi.prototype.reAttachSahiToWin = function (a) {
    this.mockDialogs(a);
    this.activateHotKey(a)
};
Sahi.prototype.onBeforeUnLoad = function () {
    this.loaded = !1
};
Sahi.prototype.onWindowLoad = function (a) {
    try {
        this.loaded = !0, this.activateHotKey()
    } catch (b) {
        this.handleException(b)
    }
    this.isRecording() && this.addHandlersToAllFrames(this.top())
};
Sahi.onWindowLoad = function (a) {
    eval("_sahi.onWindowLoad()")
};
Sahi.prototype.init = function (a) {
    __sahiDebug__("init: start");
    this.initTimer && window.clearTimeout(this.initTimer);
    if (!this.initialized) {
        this.initialized = !0;
        try {
            this.activateHotKey()
        } catch (b) {
            this.handleException(b)
        }
        this.prepareADs();
        this.makeLibFunctionsAvailable();
        try {
            __sahiDebug__("init: in try"), this.isRecording() && this.addHandlersToAllFrames(this.top())
        } catch (c) {
            this.handleException(c)
        }
        this.wrappedOnEv = this.wrap(this.onEv);
        this.wrappedOnMouseDownEv = this.wrap(this.onMouseDownEv)
    }
};
Sahi.prototype.activateHotKey = function (a) {
    a || (a = this.self());
    try {
        var b = a.document;
        this.addWrappedEvent(b, "dblclick", this.reAttachEvents);
        this.addWrappedEvent(b, "dblclick", this.openControllerWindow);
        this.addWrappedEvent(b, "mousemove", this.mouseOver)
    } catch (c) {
        this.handleException(c)
    }
};
Sahi.prototype.getOREntry = function (a) {
    a = this.escapeDollar(this.getAccessor1(a[0]));
    return this.getOREntry2(a)
};
Sahi.prototype.getOREntry2 = function (a) {
    return "$" == a.charAt(0) ? {
        name: a,
        value: a
    } : {
        name: "$_" + a.toUpperCase().replace(/_/g, "").replace(/[^a-zA-Z0-9]/g, "_").replace(/_+/g, "_").replace(/^_/, "").replace(/_$/, ""),
        value: a
    }
};
Sahi.prototype.isRecordabeKeyDown = function (a, b) {
    return !1
};
Sahi.prototype.getScript = function (a, b, c, d, e) {
    var f = a[0];
    a = this.escapeDollar(this.getAccessor1(f));
    if (null == a)return null;
    var h = f.event, g = f.value, f = f.type;
    null != c && (c = c.toLowerCase());
    var k = null;
    null == g && (g = "");
    if ("keydown" == c || "contextmenu" == c) {
        if ("keydown" == c ? this.isRecordabeKeyDown(b, d) && (k = "_keyPress(" + a + ", [" + d.keyCode + ",0]);") : k = "_rightClick(" + a + ");", !k)return null
    } else if ("dblclick" == c)k = "_doubleClick(" + a + ");"; else if ("_click" == h)k = "_checkbox" == f && !1 == g || "_radio" == f ? "_check(" + a + ");" : "_checkbox" ==
    f && !0 == g ? "_uncheck(" + a + ");" : "_click(" + a + ");"; else if ("_setValue" == h)k = "_setValue(" + a + ", " + this.quotedEscapeValue(g) + ");"; else if ("_setSelected" == h)k = "_setSelected(" + a + ", " + this.toJSON(g) + ");"; else if ("wait" == h)k = "_wait(" + g + ");"; else if ("mark" == h)k = "//MARK: " + g; else if ("_setFile" == h) {
        if (this.isBlankOrNull(g))return null;
        k = "_setFile2(" + a + ", " + this.quotedEscapeValue(g) + ");"
    }
    return e ? k : this.addPopupDomainPrefixes(k)
};
Sahi.prototype.addPopupDomainPrefixes = function (a) {
    return this.getPopupDomainPrefixes() + a
};
Sahi.prototype.getPopupDomainPrefixes = function () {
    var a = this.getPopupName(), b = this.getDomainContext(), c = "";
    null != c && null != b && "" != b && (c = this.replaceAll(this.language.DOMAIN, "\x3cdomain\x3e", this.quoted(b)));
    null != c && null != a && "" != a && (c += this.replaceAll(this.language.POPUP, "\x3cwindow_name\x3e", this.quoted(a)));
    return c
};
Sahi.prototype.quotedEscapeValue = function (a) {
    return this.quoted(this.escapeValue(a))
};
Sahi.prototype.escapeValue = function (a) {
    return null == a || "string" != typeof a ? a : this.convertUnicode(a.replace(/\r/g, "").replace(/\\/g, "\\\\").replace(/\n/g, "\\n"))
};
Sahi.prototype.escape = function (a) {
    return null == a ? a : this.encode(a)
};
Sahi.prototype.saveCondition = function (a, b) {
    this.setServerVar(a, b ? "true" : "false")
};
Sahi.prototype.resetCmds = function () {
    this.cmds = [];
    this.cmdDebugInfo = [];
    this.scriptScope()
};
Sahi.prototype.handleSet = function (a, b) {
    this.setServerVar(a, b)
};
Sahi.prototype.quoteIfString = function (a) {
    return "number" == typeof a ? a : this.quotedEscapeValue(a)
};
Sahi.prototype._execute = function (a, b) {
    var c = b ? "true" : "false";
    if ("success" != this._callServer("CommandInvoker_execute", "command\x3d" + this.encode(a) + "\x26sync\x3d" + c))throw Error("Execute Command Failed!");
};
_sahi.activateHotKey();
Sahi.prototype._style = function (a, b) {
    var c = a.style[this.toCamelCase(b)];
    c || (a.ownerDocument && a.ownerDocument.defaultView ? c = a.ownerDocument.defaultView.getComputedStyle(a, "").getPropertyValue(b) : a.currentStyle && (c = a.currentStyle[this.toCamelCase(b)]));
    return c
};
Sahi.prototype.toCamelCase = function (a) {
    for (var b = /-([a-z])/; b.test(a); a = a.replace(b, RegExp.$1.toUpperCase()));
    return a
};
Sahi.init = function (a) {
    eval("_sahi.init()")
};
Sahi.onBeforeUnLoad = function (a) {
    _sahi.onBeforeUnLoad(a)
};
SahiXHRWrapper = function (a, b) {
    try {
        this.xhr = b ? new ActiveXObject(a) : new real_XMLHttpRequest
    } catch (c) {
        _sahi._isIE() && window.ActiveXObject && (this.xhr = new ActiveXObject("Microsoft.XMLHTTP"))
    }
    this._async = !1;
    this.upload = this.xhr.upload
};
SahiXHRWrapper.prototype.open = function (a, b, c, d, e) {
    b = "" + b;
    this._async = c;
    a = this.xhr.open(a, b, c, d, e);
    if (-1 == b.indexOf("/_s_/")) {
        try {
            if (!_sahi.isComet(b)) {
                var f = _sahi.topSahi().XHRs, h = f.length;
                f[h] = this;
                _sahi.topSahi().XHRTimes[h] = (new Date).getTime()
            }
        } catch (g) {
            _sahi._debug("concat.js: Diff domain: Could not add XHR to list for automatic monitoring " + g)
        }
        -1 != b.indexOf("://") && -1 == b.indexOf("://" + location.host) || this.setRequestHeader("sahi-isxhr", "true")
    }
    var k = this.stateChange, l = this;
    this.withCredentials &&
    (this.xhr.withCredentials = this.withCredentials);
    this.xhr.onreadystatechange = function () {
        k.apply(l, arguments)
    };
    return a
};
SahiXHRWrapper.prototype.addEventListener = function (a, b, c) {
    return this.xhr.addEventListener(a, b, c)
};
SahiXHRWrapper.prototype.getAllResponseHeaders = function () {
    return this.xhr.getAllResponseHeaders()
};
SahiXHRWrapper.prototype.getResponseHeader = function (a) {
    return this.xhr.getResponseHeader(a)
};
SahiXHRWrapper.prototype.setRequestHeader = function (a, b) {
    return this.xhr.setRequestHeader(a, b)
};
SahiXHRWrapper.prototype.send = function (a) {
    a = this.xhr.send(a);
    this._async || this.populateProps();
    return a
};
SahiXHRWrapper.prototype.stateChange = function () {
    this.readyState = this.xhr.readyState;
    4 == this.readyState && this.populateProps();
    if (this.onreadystatechange)this.onreadystatechange()
};
SahiXHRWrapper.prototype.abort = function () {
    return this.xhr.abort()
};
SahiXHRWrapper.prototype.populateProps = function () {
    this.responseText = this.xhr.responseText;
    this.responseXml = this.responseXML = this.xhr.responseXML;
    this.status = this.xhr.status;
    this.statusText = this.xhr.statusText
};
Sahi.prototype.wrapXHRs = function () {
    if ("undefined" != typeof XMLHttpRequest)try {
        this._isIE6() || this._isIE7() ? (window.real_XMLHttpRequest = XMLHttpRequest, XMLHttpRequest = SahiXHRWrapper) : XMLHttpRequest.prototype && null == XMLHttpRequest.prototype.__sahiModified__ && (XMLHttpRequest.prototype._sahi_openOld = XMLHttpRequest.prototype.open, XMLHttpRequest.prototype.__sahiModified__ = !0, XMLHttpRequest.prototype.open = function (a, c, d, e, f) {
            var h = this._sahi_openOld.apply(this, arguments);
            c = "" + c;
            if (-1 == c.indexOf("/_s_/")) {
                try {
                    if (!_sahi.isComet(c)) {
                        var g =
                            _sahi.topSahi().XHRs, k = g.length;
                        g[k] = this;
                        _sahi.topSahi().XHRTimes[k] = (new Date).getTime()
                    }
                } catch (l) {
                    _sahi._debug("concat.js: Diff domain: Could not add XHR to list for automatic monitoring " + l)
                }
                -1 != c.indexOf("://") && -1 == c.indexOf("://" + location.host) || this.setRequestHeader("sahi-isxhr", "true")
            }
            return h
        })
    } catch (a) {
    }
    new_ActiveXObject = function () {
        var a = "" + arguments[0], c = a.toLowerCase();
        if (_sahi._isIE() && (-1 != c.indexOf("microsoft.xmlhttp") || -1 != c.indexOf("msxml2.xmlhttp")))return new SahiXHRWrapper(a,
            !0);
        a = arguments;
        switch (a.length) {
            case 0:
                return new ActiveXObject;
            case 1:
                return new ActiveXObject(a[0]);
            case 2:
                return new ActiveXObject(a[0], a[1]);
            case 3:
                return new ActiveXObject(a[0], a[1], a[2]);
            case 4:
                return new ActiveXObject(a[0], a[1], a[2], a[3]);
            case 5:
                return new ActiveXObject(a[0], a[1], a[2], a[3], a[4]);
            case 6:
                return new ActiveXObject(a[0], a[1], a[2], a[3], a[4], a[5]);
            case 7:
                return new ActiveXObject(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
            default:
                return new ActiveXObject(a[0], a[1], a[2], a[3], a[4], a[5], a[6],
                    a[7])
        }
    }
};
SahiHashMap = function () {
    this.keys = [];
    this.values = [];
    this.put = function (a, b) {
        var c = this.getIndex(this.keys, a);
        -1 == c && (c = this.keys.length);
        this.keys[c] = a;
        this.values[c] = b
    };
    this.get = function (a) {
        a = this.getIndex(this.keys, a);
        return this.values[a]
    };
    this.getIndex = function (a, b) {
        for (var c = 0; c < a.length; c++)if (b === a[c])return c;
        return -1
    }
};
Sahi.prototype._toJSON = function (a) {
    return this.toJSON(a)
};
Sahi.prototype.toJSON = function (a, b) {
    try {
        b || (b = new SahiHashMap);
        var c = b.get(a);
        if (c && "___in_progress___" == c)return '"recursive_access"';
        b.put(a, "___in_progress___");
        var d = this.toJSON2(a, b);
        b.put(a, d);
        return d
    } catch (e) {
        return "error during toJSON conversion"
    }
};
Sahi.prototype.toJSON2 = function (a, b) {
    if (null == a || void 0 == a)return "null";
    if (a instanceof RegExp)return a.toString();
    if (a instanceof Date)return String(a);
    if ("string" == typeof a)return /["\\\x00-\x1f]/.test(a) ? '"' + a.replace(/([\x00-\x1f\\"])/g, function (a, b) {
        var c = _sahi.escapeMap[b];
        if (c)return c;
        c = b.charCodeAt();
        return "\\u00" + Math.floor(c / 16).toString(16) + (c % 16).toString(16)
    }) + '"' : '"' + a + '"';
    if (a instanceof Array) {
        for (var c = [], d = 0; d < a.length; d++)c[d] = this.toJSON(a[d], b);
        return "[" + c.join(",") + "]"
    }
    if ("number" == typeof a)return new String(a);
    if ("boolean" == typeof a)return String(a);
    if (a instanceof Object || "object" == typeof a) {
        if (a.tagName && !a.sahiAccessorProps)return c = this.identify(a, !0), null == c || null == c.apis ? null : 0 < c.apis.length ? "_sahi." + this.escapeDollar(this.getAccessor1(c.apis[0])) : null;
        c = [];
        for (d in a) {
            var e = a[d];
            "function" != typeof e && (c[c.length] = this.toJSON(d, b) + ":" + this.toJSON(e, b))
        }
        return "{" + c.join(",") + "}"
    }
};
Sahi.prototype.isComet = function (a) {
    return /\/comet[\/.]/.test(a)
};
Sahi.prototype.isIgnorableId = function (a) {
    return this.ignorableIdsPattern.test(a)
};
Sahi.prototype.iframeFromStr = function (a) {
    return "string" == typeof a || "number" == typeof a || a instanceof RegExp ? this._iframe(a) : a
};
Sahi.prototype._rteWrite = function (a, b) {
    this.iframeFromStr(a).contentWindow.document.body.innerHTML = b
};
Sahi.prototype._rteHTML = function (a) {
    return this.iframeFromStr(a).contentWindow.document.body.innerHTML
};
Sahi.prototype._rteText = function (a) {
    return this._getText(this.iframeFromStr(a).contentWindow.document.body)
};
Sahi.prototype._re = function (a) {
    return eval("/" + a.replace(/\s+/g, "\\s+") + "/")
};
Sahi.prototype._parentNode = function (a, b, c) {
    null == b && null == c ? b = "ANY" : "number" == typeof b && (c = b, b = "ANY");
    return this.getParentNode(a, b, c)
};
Sahi.prototype._parentCell = function (a, b) {
    return this._parentNode(a, "TD", b)
};
Sahi.prototype._parentRow = function (a, b) {
    return this._parentNode(a, "TR", b)
};
Sahi.prototype._parentTable = function (a, b) {
    return this._parentNode(a, "TABLE", b)
};
Sahi.prototype.xgetDoc = function (a) {
    return 0 == a.relations.length ? a.window.document : this.getDoc2(a.relations)
};
Sahi.prototype.getDoc = function (a) {
    if (0 == a.relations.length) {
        var b = null;
        try {
            b = a.window.document
        } catch (c) {
        }
        b || (b = new SahiDocProxy([]));
        return b
    }
    return this.getDoc2(a.relations)
};
Sahi.prototype.getDoc2 = function (a) {
    if (this.isArray(a)) {
        for (var b = [], c = 0; c < a.length; c++) {
            var d = a[c];
            !d.type && this.isWindow(d) && b.push(d.document);
            d.relation && "_near" == d.relation && (b = b.concat(this.getDoc2(d).nodes))
        }
        for (var e = null, c = 0; c < a.length; c++)if (d = a[c], d.relation && "_in" == d.relation) {
            d = d.element;
            if (null != e && !this._contains(e, d) && !this._contains(d, e))return new SahiDocProxy([]);
            if (null == e || this._contains(e, d))e = d
        }
        if (null == e)return new SahiDocProxy(b);
        if (0 == b.length)return e;
        a = [];
        for (c = 0; c < b.length; c++)this._contains(e,
            b[c]) && a.push(b[c]), this._contains(b[c], e) && a.push(e);
        return new SahiDocProxy(a)
    }
    if (a.relation) {
        if ("_in" == a.relation)return a.element;
        if ("_near" == a.relation) {
            b = [];
            for (c = 1; 7 > c; c++)b[b.length] = this.getParentNode(a.element, "ANY", c);
            return new SahiDocProxy(b)
        }
    }
    return a.document
};
SahiDocProxy = function (a) {
    this.nodes = a
};
SahiDocProxy.prototype.getElementsByTagName = function (a) {
    for (var b = [], c = 0; c < this.nodes.length; c++)if (null != this.nodes[c])for (var d = _sahi.getElementsByTagName(a, this.nodes[c]), e = 0; e < d.length; e++) {
        for (var f = d[e], h = !1, g = 0; g < b.length; g++)if (b[g] === f) {
            h = !0;
            break
        }
        h || (b[b.length] = f)
    }
    return b
};
Sahi.prototype._in = function (a) {
    this.checkNull(a, "_in");
    return {element: this.handleIframe(a), relation: "_in", type: "dom"}
};
Sahi.prototype._near = function (a) {
    this.checkNull(a, "_near");
    return {element: a, relation: "_near", type: "dom"}
};
Sahi.prototype.handleIframe = function (a) {
    return !a.tagName || "iframe" != a.tagName.toLowerCase() && "frame" != a.tagName.toLowerCase() ? a : a.contentWindow.document
};
Sahi.prototype.getLeftTop = function (a) {
    a = a.getBoundingClientRect();
    return [Math.round(a.left), Math.round(a.top)]
};
Sahi.prototype.getRightTop = function (a) {
    a = a.getBoundingClientRect();
    return [Math.round(a.right), Math.round(a.top)]
};
Sahi.prototype.fixOffset = function (a) {
    null == a ? a = [0, 0] : "number" == typeof a && (a = [a, a]);
    return a
};
Sahi.prototype._under = function (a, b, c) {
    this.checkNull(a, "_under");
    b = this.fixOffset(b);
    var d = this.getLeftTop(a), e = d[0], f = e + a.offsetWidth, h = a.offsetHeight, d = d[1] + (isNaN(h) ? 0 : h / 2);
    this.is_defined(c) && (c += d);
    return {
        element: a,
        relation: "_under",
        type: "position",
        alignX: e - b[0],
        alignXOuter: f + b[1],
        limitY: d,
        limitUnder: c
    }
};
Sahi.prototype._above = function (a, b, c) {
    this.checkNull(a, "_above");
    b = this.fixOffset(b);
    var d = this.getLeftTop(a), e = d[0], f = e + a.offsetWidth, h = a.offsetHeight, d = d[1] - (isNaN(h) ? 0 : h / 2);
    this.is_defined(c) && (c = d - c);
    return {
        element: a,
        relation: "_above",
        type: "position",
        alignX: e - b[0],
        alignXOuter: f + b[1],
        limitY: d,
        limitTop: c
    }
};
Sahi.prototype._leftOf = function (a, b) {
    this.checkNull(a, "_leftOf");
    var c = this.getLeftTop(a), d = c[1], e = d + a.offsetHeight, c = c[0];
    b = this.fixOffset(b);
    return {element: a, relation: "_leftOf", type: "position", alignY: d - b[0], alignYOuter: e + b[1], limitX: c}
};
Sahi.prototype._rightOf = function (a, b) {
    this.checkNull(a, "_rightOf");
    var c = this.getLeftTop(a), d = c[1], e = d + a.offsetHeight, f = a.offsetWidth, c = c[0] + (isNaN(f) ? 0 : f / 2);
    b = this.fixOffset(b);
    return {element: a, relation: "_rightOf", type: "position", alignY: d - b[0], alignYOuter: e + b[1], limitX: c}
};
Sahi.prototype._leftOrRightOf = function (a, b) {
    this.checkNull(a, "_leftOrRightOf");
    var c = this.getLeftTop(a)[1], d = c + a.offsetHeight;
    b = this.fixOffset(b);
    return {element: a, relation: "_rowOf", type: "position", alignY: c - b[0], alignYOuter: d + b[1]}
};
Sahi.prototype._aboveOrUnder = function (a, b) {
    this.checkNull(a, "_aboveOrUnder");
    var c = this.getLeftTop(a)[0], d = null == b ? 0 : b;
    return {element: a, relation: "_colOf", type: "position", alignX: c - d, alignXOuter: c + a.offsetWidth + d}
};
Sahi.prototype._xy = function (a, b, c) {
    this.checkNull(a, "_xy");
    this.xyoffsets.put(a, [b, c]);
    return a
};
Sahi.prototype.getVariables = function (a) {
    return this.decode(this.sendToServer("/_s_/dyn/ControllerUI_getVariables?code\x3d" + this.encode(a)))
};
Sahi.prototype.addSahi = function (a) {
    return this.decode(this.sendToServer("/_s_/dyn/ControllerUI_getSahiScript?code\x3d" + this.encode(a)))
};
_sahi.prevOnError = window.onerror;
window.onerror = _sahi.wrap(_sahi.onError);
_sahi._isIE() && (_sahi.real_execCommand = document.execCommand, document.execCommand = function () {
    return _sahi_dummyExecCommand.apply(document, arguments)
});
Sahi.prototype.encode = function (a) {
    return encodeURIComponent(a).replace(/%20/g, "+").replace(/!/g, "%21").replace(/'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29").replace(/\*/g, "%2A")
};
Sahi.prototype.decode = function (a) {
    return a ? decodeURIComponent(a.replace(/[+]/g, " ")) : a
};
function _sahi_dummyExecCommand() {
    return "ClearAuthenticationCache" == arguments[0] ? (_sahi.sendToServer("/_s_/dyn/SessionState_removeAllCredentials"), !0) : _sahi.real_execCommand.apply(window.document, arguments)
}
Sahi.prototype.getOptionId = function (a, b) {
    if (-1 != a.selectedIndex)return a.options[a.selectedIndex].id
};
Sahi.prototype.addADAr = function (a) {
    this.ADs[this.ADs.length] = a
};
Sahi.prototype.getAD = function (a) {
    for (var b = [], c = 0; c < this.ADs.length; c++) {
        var d = this.ADs[c];
        this.areTagNamesEqual(d.tag, a.tagName) && (a.type ? d.type && this.getElementType(a) != d.type || (b[b.length] = d) : b[b.length] = d)
    }
    return b
};
Sahi.prototype.getDomRelAr = function (a) {
    var b = [], c = [], d = null;
    this.lookInside && b.push(this._in(this.lookInside));
    for (var e = 1; e < a.length; e++) {
        var f = a[e];
        f && (this.isWindow(f) && (d = f), "dom" == f.type && b.push(f), "position" == f.type && c.push(f))
    }
    d || (d = this.absoluteTop());
    return {relations: b, positionals: c, window: d}
};
Sahi.prototype.isWindow = function (a) {
    return a && "undefined" != typeof a.location && "boolean" == typeof a.closed
};
Sahi.prototype.addAD = function (a) {
    this.addADAr(a);
    var b = Sahi.prototype[a.name], c = function (c) {
        var e = this.getDomRelAr(arguments);
        if (b) {
            var f = b.apply(this, arguments);
            if (f)return f
        }
        var h = a.attributes;
        "object" != typeof c || c instanceof RegExp || (h = ["associative_array"]);
        for (var g = 0; g < a.attributes.length; g++)if (f = this.getBlankResult(), f = a.type ? this.findElementHelper(c, e, a.type, f, h[g], a.tag).element : this.findTagHelper(c, e, a.tag, f, h[g]).element, null != f)return f
    };
    a.idOnly || (Sahi.prototype[a.name] = c)
};
Sahi.prototype.identify = function (a, b) {
    if (null == a)return null;
    var c = [], d = [];
    a.tagName.toLowerCase();
    var e = this.getAD(a), f = null, h = null, g = this.topSahi().anchor;
    g && g != a && (this._contains(g, a) ? (f = this._in(g), h = "_in(" + this.topSahi().anchorStr + ")") : this._contains(this.getParentNode(g, "ANY", 7, !0), a) && (f = this._near(g), h = "_near(" + this.topSahi().anchorStr + ")"));
    for (g = 0; g < e.length; g++) {
        var k = e[g];
        if (k && k.attributes)for (var l = k.attributes, q = 0; q < l.length; q++)try {
            var n = l[q];
            if ("index" == n) {
                var m = this.getIdentifyIx(null,
                    a, null, f);
                -1 != m && this[k.name](m) == a && (c[c.length] = this.buildAccessorInfo(a, k, m, h, n))
            } else if ("string" != typeof n || b || 0 != n.indexOf("encaps")) {
                var r = this.getAttribute(a, n);
                if (r && !("id" == n && this.isIgnorableId(r) || "sahiText" == n && 200 < r.length))if (this[k.name](r, f) == a) {
                    var s = this.getAttrDisplayType(n);
                    c[c.length] = this.buildAccessorInfo(a, k, r, h, s)
                } else m = this.getIdentifyIx(r, a, n, f), r = r + "[" + m + "]", -1 != m && this[k.name](r) == a && (s = this.getAttrDisplayType(n), c[c.length] = this.buildAccessorInfo(a, k, r, h, s))
            } else {
                var u =
                    n.substring(n.indexOf("_") + 1), v = this._parentNode(a, u), t = this.identify(v);
                t && (c = c.concat(t.apis), d = d.concat(t.assertions))
            }
        } catch (w) {
        }
    }
    0 < c.length && (d = d.concat(this.getAssertions(e, c[0])));
    return {apis: c, assertions: d}
};
Sahi.prototype.buildAccessorInfo = function (a, b, c, d, e) {
    return new AccessorInfo("", c, b.name, b.action, b.value ? this.getAttribute(a, b.value) : null, b.value, d, e)
};
Sahi.prototype.getIdentifyIx = function (a, b, c, d) {
    d = this.getDomRelAr(arguments);
    var e = b.tagName.toLowerCase(), f = this.getBlankResult();
    return this.isFormElement(b) ? this.findElementIxHelper(a, b.type, b, d, f, c, e).cnt : this.findTagIxHelper(a, b, d, e, f, c).cnt
};
Sahi.prototype.isFormElement = function (a) {
    a = a.tagName.toLowerCase();
    return "input" == a || "button" == a || "textarea" == a || "select" == a || "option" == a
};
Sahi.prototype.getAttribute = function (a, b) {
    if (null == b)return null;
    if ("function" == typeof b)return b(a);
    if (-1 != b.indexOf("|"))for (var c = b.split("|"), d = 0; d < c.length; d++) {
        var e = this.getAttribute(a, c[d]);
        if (null != e && "" != e)return e
    } else return "sahiText" == b ? this._getText(a) : null != a[b] ? a[b] : a[b] || a.getAttribute(b)
};
Sahi.prototype.makeLibFunctionsAvailable = function () {
    for (var a = "_scriptName _scriptPath _suiteInfo _userDataDir _sessionInfo _userDataPath _readFile _readCSVFile _readURL _scriptStatus _stackTrace _selectWindow _resolvePath _takeScreenShot _readLayoutFile _fail _trim".split(" "), b = 0; b < a.length; b++)this.addRhinoFn(a[b])
};
Sahi.prototype.addRhinoFn = function (a) {
    this[a] = function () {
        for (var b = "", c = 0; c < arguments.length; c++)0 != c && (b += ", "), b += this.toJSON(arguments[c]);
        return this._evalOnRhino(a + "(" + b + ")")
    }
};
Sahi.prototype._evalOnRhino = function (a) {
    try {
        var b = this.sendToServer("/_s_/dyn/RhinoRuntime_eval?toEval\x3d" + this.encode(a));
        return eval("(" + this.decode(b) + ")")
    } catch (c) {
        return null
    }
};
Sahi.prototype.getFileFromURL = function (a) {
    a = a.src;
    a = a.replace(/[;?].*$/, "");
    return a.substring(a.lastIndexOf("/") + 1)
};
Sahi.prototype.getFileFromURL.displayName = "url";
Sahi.prototype.getAssociatedLegendName = function (a) {
    a = a.getElementsByTagName("legend");
    if (0 < a.length && null != a[0])return _sahi._getText(a[0])
};
Sahi.prototype.getAssociatedLegendName.displayName = "legend";
Sahi.prototype.getAssociatedLabel = function (a) {
    var b = _sahi._label({htmlFor: a.id}, _sahi._near(a));
    if (null != b)return _sahi._getText(b);
    for (b = 0; 8 > b++;) {
        if (null == a || a == document.body)return null;
        var c = a.parentNode;
        if (null == c || a == c)return null;
        if ("LABEL" == c.nodeName)return _sahi._getText(c);
        a = c
    }
};
Sahi.prototype.getAssociatedLabel.displayName = "label";
Sahi.prototype.getXPath = function (a) {
    for (var b = ""; ;) {
        var c = a.parentNode;
        if (c == a || null == c)break;
        var d = this.findInArray(this.getElementsByTagName(a.tagName, c), a), d = 0 < d ? "[" + (d + 1) + "]" : "", b = a.tagName.toLowerCase() + d + ("" == b ? "" : "/" + b);
        a = c
    }
    return "/" + b
};
Sahi.prototype.isElementCompletelyVisibleInCurrentViewport = function (a) {
    a = a.getBoundingClientRect();
    return 0 <= a.top && 0 <= a.left && a.bottom <= (window.innerHeight || document.documentElement.clientHeight) && a.right <= (window.innerWidth || document.documentElement.clientWidth)
};
Sahi.prototype.getAttrDisplayType = function (a) {
    if ("string" == typeof a)return a;
    if ("function" == typeof a)return a.displayName
};
Sahi.prototype.prepareADs = function () {
    for (var a = 0; a < this.accessors_metadata.length; a++)this.addAD(this.accessors_metadata[a]);
    this._rte = this._iframe
};
Sahi.prototype.getAssertions = function (a, b) {
    for (var c = [this.language.ASSERT_EXISTS, this.language.ASSERT_VISIBLE], d = 0; d < a.length; d++) {
        var e = a[d];
        e.assertions && (c = c.concat(e.assertions(b.value)))
    }
    "sahiText" == b.valueType ? (c[c.length] = this.language.ASSERT_EQUAL_TEXT, c[c.length] = this.language.ASSERT_CONTAINS_TEXT) : "value" == b.valueType && (c[c.length] = this.language.ASSERT_EQUAL_VALUE);
    return c
};
var sahiLanguage = {
    ASSERT_EXISTS: "_assertExists(\x3caccessor\x3e);",
    ASSERT_VISIBLE: "_assertVisible(\x3caccessor\x3e);",
    ASSERT_EQUAL_TEXT: "_assertEqual(\x3cvalue\x3e, _getText(\x3caccessor\x3e));",
    ASSERT_CONTAINS_TEXT: "_assertContainsText(\x3cvalue\x3e, \x3caccessor\x3e);",
    ASSERT_EQUAL_VALUE: "_assertEqual(\x3cvalue\x3e, _getValue(\x3caccessor\x3e));",
    ASSERT_SELECTION: "_assertEqual(\x3cvalue\x3e, _getSelectedText(\x3caccessor\x3e));",
    ASSERT_CHECKED: "_assert(\x3caccessor\x3e.checked);",
    ASSERT_NOT_CHECKED: "_assertNotTrue(\x3caccessor\x3e.checked);",
    POPUP: "_popup(\x3cwindow_name\x3e).",
    DOMAIN: "_domain(\x3cdomain\x3e)."
};
_sahi.language = sahiLanguage;
Sahi.prototype._bySeleniumLocator = function (a, b, c) {
    var d = new BrowserBot(this.top());
    "" != b && "undefined" != b && "null" != b && null != b && d.selectWindow(b);
    if ("" != c && "undefined" != c && "null" != c && null != c)if (b = c.split(","), 0 < b.length)for (c = 0; c < b.length; c++)d.selectFrame(this.trim(b[c])); else d.selectFrame(this.top());
    return d.findElementOrNull(a)
};
Sahi.prototype.evalSelenium = function (a, b, c) {
    var d = new BrowserBot(this.top());
    "" != b && "undefined" != b && "null" != b && null != b && d.selectWindow(b);
    if ("" != c && "undefined" != c && "null" != c && null != c)if (b = c.split(","), 0 < b.length)for (c = 0; c < b.length; c++)d.selectFrame(this.trim(b[c])); else d.selectFrame(this.top());
    return d.getCurrentWindow().eval(a)
};
Sahi.prototype._doSeleniumSelect = function (a, b, c) {
    var d = new OptionLocatorFactory;
    a = this._bySeleniumLocator(a);
    this._setSelected(a, d.fromLocatorString(b).findOption(a).index, c)
};
Sahi.prototype.loadXPathScript = function () {
    if (this._isFF() || this._isHTMLUnit())return !1;
    document.implementation && document.implementation.hasFeature && document.implementation.hasFeature("XPath", null) || this.loadScript("/_s_/spr/ext/javascript-xpath/javascript-xpath.js", "_sahi_concat")
};
Sahi.prototype.loadScript = function (a, b) {
    var c = document.createElement("script");
    c.src = a;
    var d = document.getElementById(b);
    d.parentNode.insertBefore(c, d)
};
Sahi.prototype.setLastHTMLSnapShotFile = function (a) {
    try {
        var b = new Packages.com.pushtotest.sahi.SahiHTMLUnit;
        if (b && a) {
            var c = new Packages.java.io.File(a);
            b.takeSnapShot(c)
        }
    } catch (d) {
    }
};
__sahiDebug__("concat.js: end");
Sahi.prototype.setAnchor = function (a) {
    "java" == _sahi.controllerMode ? (a = a.substring(2), a = "_" + a) : "ruby" == _sahi.controllerMode && (a = a.substring(3), a = "_" + a);
    this.anchorStr = a;
    try {
        var b = this.addSahi(a);
        this.anchor = eval(b)
    } catch (c) {
    }
};
Sahi.prototype.removeAnchor = function () {
    this.anchor = this.anchorStr = null
};
Sahi.prototype.isFlexObj = function (a) {
    try {
        return a.isSFL
    } catch (b) {
        return !1
    }
};
function isSahiAvailable() {
    return !0
}
Sahi.prototype._verifyLayout = function (a, b) {
    var c = this.verifyLayout2(a, b);
    if (!0 != c)throw new SahiAssertionException(4, c);
    return !0
};
Sahi.prototype.verifyLayout2 = function (a, b) {
    var c, d;
    d = a[0][0];
    var e = "";
    this._isVisible(d) && (c = this._position(d)[1]);
    for (var f = 0; f < a.length; f++) {
        for (var h = d = 0; h < a[f].length; h++) {
            var g = a[f][h];
            if (!this._isVisible(g)) {
                e = "Element at 2d-array [" + f + "," + h + "] is not visible";
                break
            }
            if (0 == h) {
                if (0 != f && this._position(g)[1] <= c) {
                    e = "Layout not correct for " + g + ". Y co-ordinate fail";
                    break
                }
                this._position(g);
                c = this._position(g)[1]
            }
            if (Math.abs(this._position(g)[1] - c) <= b)this._assert(this._isVisible(g)); else {
                e = "Layout not correct for " +
                    g + ". Y co-ordinate fail";
                break
            }
            if (0 != h) {
                if (this._position(g)[0] <= d) {
                    e = "Layout not correct for " + g + ". X co-ordinate fail";
                    break
                }
                d = this._position(g)[0]
            }
        }
        if (e)return e
    }
    return !0
};
Sahi.prototype._getSelectionText = function (a) {
    a || (a = this.top());
    if (this.isWindowAccessible(a)) {
        var b = a.document.activeElement, c = null;
        if (!this._isFF() && !this._isIE11Plus() || !b || -1 == this.findInArray(this.textboxTypes, b.type) && "textarea" != b.type) {
            var d;
            !a.getSelection || this._isIE9PlusStrictMode() && !this._isIE11Plus() ? a.document.selection && (d = a.document.selection.createRange()) : d = a.getSelection();
            c = void 0 != d.text ? d.text : "" + d
        } else c = b.value.substring(b.selectionStart, b.selectionEnd);
        if (!this.isBlankOrNull(c))return c
    }
    for (b =
             0; b < a.frames.length; b++)if (c = this._getSelectionText(a.frames[b]), !this.isBlankOrNull(c))return c;
    return ""
};
Sahi.prototype.getImageFormat = function () {
    return this.sendToServer("/_s_/dyn/Player_getImageFormat")
};
Sahi.prototype.getResizePercentage = function () {
    return parseInt(this.sendToServer("/_s_/dyn/Player_getResizePercentage"))
};
Sahi.prototype.fnStart = function () {
};
Sahi.prototype.fnEnd = function () {
};