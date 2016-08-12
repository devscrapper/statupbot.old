Sahi.prototype._click = function (a, b) {
    this.checkNull(a, "_click");
    this.checkVisible(a);
    if (this.isApplet(a))return a.click();
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.click();
    this.markStepDone(this.currentStepId, this.currentType);
    this.simulateClick(a, !1, !1, b)
};
Sahi.prototype._doubleClick = function (a, b) {
    this.checkNull(a, "_doubleClick");
    this.checkVisible(a);
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.doubleClick();
    this.simulateDoubleClick(a, !1, !0, b)
};
Sahi.prototype._rightClick = function (a, b) {
    this.checkNull(a, "_rightClick");
    this.checkVisible(a);
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.rightClick();
    this.simulateRightClick(a, !0, !1, b)
};
Sahi.prototype._mouseOver = function (a, b) {
    null != this.lookInside && (a = a.inside(this.lookInside));
    this.checkNull(a, "_mouseOver");
    this.checkVisible(a);
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.mouseOver();
    this.simulateMouseEvent(a, "mousemove", !1, !1, b);
    this.simulateMouseEvent(a, "mouseover", !1, !1, b);
    this.setLastBlurFn(function () {
        try {
            _sahi.simulateMouseEvent(a, "mousemove"), _sahi.simulateMouseEvent(a, "mouseout"), _sahi.simulateMouseEvent(a, "blur")
        } catch (b) {
        }
    })
};
Sahi.prototype._mouseDown = function (a, b, c) {
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.mouseDown();
    this.simulateMouseEvent(a, "mousedown", b, !1, c)
};
Sahi.prototype._mouseUp = function (a, b, c) {
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.mouseUp();
    this.simulateMouseEvent(a, "mouseup", b, !1, c)
};
Sahi.prototype._keyPress = function (a, b, c) {
    var d = a && a.type && ("text" == a.type || "password" == a.type || "textarea" == a.type) && this.shouldAppend(a);
    this.simulateKeyPressEvents(a, b, c, d)
};
Sahi.prototype.simulateKeyPressEvents = function (a, b, c, d) {
    var e = a.value, g = 0, h = 0, k = null;
    "number" == typeof b ? (h = b, g = this.getKeyCode(h), k = String.fromCharCode(h)) : "object" == typeof b ? (g = b[0], h = b[1], k = String.fromCharCode(h)) : "string" == typeof b && (h = b.charCodeAt(0), g = this.getKeyCode(h), k = b);
    (b = 65 <= h && 90 >= h) && (c = "" + c + "|SHIFT|");
    this.simulateKeyEvent([b ? 16 : g, 0], a, "keydown", c);
    this.isSafariLike() ? this.simulateKeyEvent([g, h], a, "keypress", c) : this.simulateKeyEvent([0, h], a, "keypress", c);
    d && 10 != h && e == a.value && (!this._isFF4Plus() ||
    this._isFF4Plus() && "CTRL" != c && "ALT" != c) && (a.value += k);
    try {
        this._isIE() && !this._isIE9PlusStrictMode() || this.simulateKeyEvent([g, 0], a, "input", c)
    } catch (m) {
    }
    this.simulateKeyEvent([g, 0], a, "keyup", c)
};
Sahi.prototype._keyPressEvent = function (a, b, c) {
    this.checkNull(a, "_keyPressEvent", 1);
    this.checkVisible(a);
    this.simulateKeyEvent("object" == typeof b ? b : [0, b], a, "keypress", c)
};
Sahi.prototype._focus = function (a) {
    this.isFlexObj(a) && null != this.lookInside && (a = a.inside(this.lookInside));
    try {
        a.focus()
    } catch (b) {
    }
    this.simulateEvent(a, "focus")
};
Sahi.prototype._blur = function (a) {
    this.simulateEvent(a, "blur")
};
Sahi.prototype._removeFocus = Sahi.prototype._blur;
Sahi.prototype._keyDown = function (a, b, c) {
    this.checkNull(a, "_keyDown", 1);
    this.checkVisible(a);
    this.simulateKeyEvent("number" == typeof b ? [b, 0] : b, a, "keydown", c)
};
Sahi.prototype._keyUp = function (a, b, c) {
    this.checkNull(a, "_keyUp", 1);
    this.checkVisible(a);
    this.simulateKeyEvent("number" == typeof b ? [b, 0] : b, a, "keyup", c)
};
Sahi.prototype._closeWindow = function (a) {
    if (!a)try {
        a = this.absoluteTop().window
    } catch (b) {
        a = window
    }
    a && (a.open("", "_self"), a.close())
};
Sahi.prototype.isCheckboxRadioSimulationRequired = function () {
    return this._isChrome() ? this.chromeExplicitCheckboxRadioToggle : this.isSafariLike()
};
Sahi.prototype.simulateDoubleClick = function (a, b, c, d) {
    var e = !0;
    this._isFF() || this.isSafariLike() || this._isOpera() ? (this.simulateMouseEvent(a, "mousemove"), this.simulateMouseEvent(a, "mouseover"), this.simulateMouseEvent(a, "mousedown", b, !1, d), this.invokeLastBlur(), (e = this.isFocusableFormElement(a)) && this.simulateEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "click", b, !1, d), this.simulateMouseEvent(a, "mousedown", b, c, d), this.simulateMouseEvent(a, "mouseup", b, c, d), this.simulateMouseEvent(a,
        "click", b, c, d), this.simulateMouseEvent(a, "dblclick", b, c, d)) : this._isIE() && !this._isIE9PlusStrictMode() ? (this.simulateMouseEvent(a, "mousemove"), this.simulateMouseEvent(a, "mouseover"), this.simulateMouseEvent(a, "mousedown", b, !1, d), this.invokeLastBlur(), this._isIE() && this.simulateEvent(a, "focusin"), this.simulateMouseEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "click", b, !1, d), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "dblclick", b, c,
        d)) : this._isIE9PlusStrictMode() && (this.simulateMouseEvent(a, "mousemove"), this.simulateMouseEvent(a, "mouseover"), this.simulateMouseEvent(a, "mousedown", b, !1, d), this.invokeLastBlur(), this._isIE11Plus() && (this.simulateEvent(a, "beforeactivate"), this.simulateEvent(a, "activate")), this._isIE() && this.simulateEvent(a, "focusin"), this.simulateMouseEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "click", b, !1, d), this.simulateMouseEvent(a, "mousedown", b, c, d), this.simulateMouseEvent(a,
        "mouseup", b, c, d), this.simulateMouseEvent(a, "click", b, c, d), this.simulateMouseEvent(a, "dblclick", b, c, d), this._isIE11Plus() && this.simulateEvent(a, "deactivate"));
    e && this.setLastBlurFn(function () {
        try {
            _sahi.simulateMouseEvent(a, "mousemove"), _sahi.simulateMouseEvent(a, "mouseout"), _sahi._isFF() || _sahi._isIE9PlusStrictMode() || _sahi._isOpera() || "checkbox" != a.type && "radio" != a.type || _sahi.simulateEvent(a, "change"), _sahi._isIE() && _sahi.simulateEvent(a, "focusout"), _sahi.simulateEvent(a, "blur")
        } catch (b) {
        }
    })
};
Sahi.prototype.simulateRightClick = function (a, b, c, d) {
    c = !0;
    this._isFF() || this.isSafariLike() || this._isOpera() ? (this.simulateMouseEvent(a, "mousemove"), this.simulateMouseEvent(a, "mouseover"), this.simulateMouseEvent(a, "mousedown", b, !1, d), this.invokeLastBlur(), (c = this.isFocusableFormElement(a)) && this.simulateEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "contextmenu", b, !1, d)) : this._isIE() && (this.simulateMouseEvent(a, "mousemove"), this.simulateMouseEvent(a, "mouseover"),
        this.simulateMouseEvent(a, "mousedown", b, !1, d), this.invokeLastBlur(), this._isIE11Plus() && (this.simulateEvent(a, "beforeactivate"), this.simulateEvent(a, "activate")), this.simulateEvent(a, "focusin"), this.simulateMouseEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", b, !1, d), this.simulateMouseEvent(a, "contextmenu", b, !1, d), this._isIE11Plus() && this.simulateEvent(a, "deactivate"));
    c && this.setLastBlurFn(function () {
        try {
            _sahi.simulateMouseEvent(a, "mousemove"), _sahi.simulateMouseEvent(a, "mouseout"), _sahi._isFF() ||
            _sahi._isIE9PlusStrictMode() || _sahi._isOpera() || "checkbox" != a.type && "radio" != a.type || _sahi.simulateEvent(a, "change"), _sahi._isIE() && _sahi.simulateEvent(a, "focusout"), _sahi.simulateEvent(a, "blur")
        } catch (b) {
        }
    })
};
Sahi.prototype.isFocusableFormElement = function (a) {
    return !this.isFormElement(a) || this.isSafariLike() && ("checkbox" == a.type || "radio" == a.type || "button" == a.type) ? !1 : !0
};
Sahi.prototype.simulateClick = function (a, b, c, d) {
    var e = this.getEncapsulatingLink(a);
    if (null != e && this._isFF()) {
        e.__sahi__prevClick = e.onclick;
        var g = this.getWindow(e);
        e.onclick = function (a) {
            return _sahi.wrap(_sahi.linkClick)(a ? a : g.event)
        }
    }
    this.simulateMouseEvent(a, "mousemove");
    this.simulateMouseEvent(a, "mouseover");
    this.simulateMouseEvent(a, "mousedown", b, !1, d);
    this.invokeLastBlur();
    this._isIE11Plus() && (this.simulateEvent(a, "beforeactivate"), this.simulateEvent(a, "activate"));
    var h = this.isFocusableFormElement(a);
    h && (this._isIE() && this.simulateEvent(a, "focusin"), this.simulateEvent(a, "focus"));
    this.simulateMouseEvent(a, "mouseup", b, !1, d);
    try {
        if (this._isIE() && a && (this.areTagNamesEqual(a.tagName, "LABEL") || null != e || a.type && ("submit" == a.type || "reset" == a.type || "image" == a.type || "checkbox" == a.type || "radio" == a.type)))null != e && this.markStepDone(this.currentStepId, this.currentType), a.click(); else if (window.opera)this.simulateMouseEvent(a, "click", b, c, d), !this.areTagNamesEqual(a.tagName, "INPUT") || "radio" != a.type && "checkbox" !=
        a.type || this.simulateEvent(a, "change"); else {
            var k = !1;
            this.isCheckboxRadioSimulationRequired() && this.areTagNamesEqual(a.tagName, "INPUT") && ("radio" == a.type || "checkbox" == a.type) && (k = !0, a.checked = "radio" == a.type ? !0 : !a.checked, this.simulateEvent(a, "change"), this.simulateMouseEvent(a, "click", b, c, d));
            k || this.simulateMouseEvent(a, "click", b, c, d)
        }
    } catch (m) {
    }
    this._isIE11Plus() && this.simulateEvent(a, "deactivate");
    h && this.setLastBlurFn(function () {
        try {
            _sahi.simulateMouseEvent(a, "mousemove"), _sahi.simulateMouseEvent(a,
                "mouseout"), _sahi._isFF() || _sahi._isIE9PlusStrictMode() || _sahi._isOpera() || "checkbox" != a.type && "radio" != a.type || _sahi.simulateEvent(a, "change"), _sahi._isIE() && _sahi.simulateEvent(a, "focusout"), _sahi.simulateEvent(a, "blur")
        } catch (b) {
        }
    });
    null != e && this._isFF() && (e.onclick = e.__sahi__prevClick)
};
Sahi.prototype.simulateMouseEvent = function (a, b, c, d, e) {
    var g = this.findClientPosWithOffset(a);
    this.simulateMouseEventXY(a, b, g[0], g[1], c, d, e)
};
Sahi.prototype.simulateDragEvent = function (a, b, c, d) {
    var e = this.findClientPosWithOffset(a);
    this.simulateDragEventXY(a, b, e[0], e[1], c, d)
};
Sahi.prototype.simulateDragEventXY = function (a, b, c, d, e, g) {
    g || (g = "");
    var h = -1 != g.indexOf("SHIFT"), k = -1 != g.indexOf("CTRL"), m = -1 != g.indexOf("ALT");
    g = -1 != g.indexOf("META");
    if (this._isIE() && !this._isIE11Plus()) {
        var f = a.ownerDocument.createEventObject();
        f.clientX = c;
        f.clientY = d;
        f.ctrlKey = k;
        f.altKey = m;
        f.metaKey = g;
        f.shiftKey = h;
        if ("mousedown" == b || "mouseup" == b || "mousemove" == b)f.button = 1;
        a.fireEvent(this.getEventTypeName(b), f);
        f.cancelBubble = !0
    } else if (this._isFF())f = a.ownerDocument.createEvent("DragEvents"),
        f.initDragEvent(b, !0, !0, a.ownerDocument.defaultView, 1, c, d, c, d, k, m, h, g, 0, null, e), a.dispatchEvent(f); else if (this._isChrome() || this._isIE11Plus())f = a.ownerDocument.createEvent("HTMLEvents"), f.initEvent(b, !0, !0, a.ownerDocument.defaultView, 1, c, d, c, d, k, m, h, g, 0, null), f.dataTransfer = e, a.dispatchEvent(f)
};
Sahi.prototype.simulateMouseEventXY = function (a, b, c, d, e, g, h) {
    h || (h = "");
    var k = -1 != h.indexOf("SHIFT"), m = -1 != h.indexOf("CTRL"), f = -1 != h.indexOf("ALT");
    h = -1 != h.indexOf("META");
    if (!this._isIE() || this._isIE9PlusStrictMode() && ("click" != b || !g))if (this.isSafariLike() || this._isIE9PlusStrictMode() || this._isOpera()) {
        if (a.ownerDocument.createEvent) {
            var l = a.ownerDocument.createEvent("HTMLEvents");
            l.initEvent(b, !0, !0);
            l.clientX = c;
            l.clientY = d;
            l.pageX = c + this.getScrollOffsetX();
            l.pageY = d + this.getScrollOffsetY();
            l.screenX =
                c;
            l.screenY = d;
            l.button = e ? 2 : 0;
            l.which = e ? 3 : 1;
            l.detail = g ? 2 : "contextmenu" == b ? 0 : 1;
            l.ctrlKey = m;
            l.altKey = f;
            l.metaKey = h;
            l.shiftKey = k;
            a.dispatchEvent(l)
        }
    } else l = a.ownerDocument.createEvent("MouseEvents"), l.initMouseEvent(b, !0, !0, a.ownerDocument.defaultView, g ? 2 : 1, c + this.getScrollOffsetX(), d + this.getScrollOffsetY(), c, d, m, f, k, h, e ? 2 : 0, null), a.dispatchEvent(l);
    if (this.checkForDuplicateEventsOnIE9Plus(a, b) && !this._isIE11Plus()) {
        l = a.ownerDocument.createEventObject();
        l.clientX = c + this.getScrollOffsetX();
        l.clientY =
            d + this.getScrollOffsetY();
        l.ctrlKey = m;
        l.altKey = f;
        l.metaKey = h;
        l.shiftKey = k;
        if ("mousedown" == b || "mouseup" == b || "mousemove" == b)l.button = e ? 2 : 1;
        a.fireEvent(this.getEventTypeName(b), l);
        l.cancelBubble = !0
    }
};
Sahi.prototype.checkForDuplicateEventsOnIE9Plus = function (a, b) {
    return this._isIE() ? this._isIE9Plus() ? null == a["on" + b] || null != a["on" + b] && !this._isIE9PlusStrictMode() : !0 : !1
};
Sahi.pointTimer = 0;
Sahi.prototype._highlight = function (a) {
    if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.highlight();
    if (this.isApplet(a))return a.highlight();
    Sahi.lastUnhighlight && (Sahi.lastUnhighlight(), window.clearTimeout(Sahi.unhighlightTimer));
    var b = a.style.border, c = a.style.outline;
    a.style.border = "1px solid red";
    a.style.outline = "1px solid red";
    Sahi.lastUnhighlight = function () {
        a.style.border = b;
        a.style.outline = c;
        Sahi.lastUnhighlight = null
    };
    Sahi.unhighlightTimer = window.setTimeout(Sahi.lastUnhighlight,
        1E3)
};
Sahi.prototype.navigateLink = function () {
    var a = this.lastLink;
    if (!(!a || this.lastLinkEvent.getPreventDefault && this.lastLinkEvent.getPreventDefault() || (this._isIE() || this.isSafariLike()) && !1 == this.lastLinkEvent.returnValue)) {
        var b = this.getWindow(a);
        if (0 == a.href.indexOf("javascript:"))a = a.href.substring(11), b.setTimeout(unescape(a), 0); else {
            var c = a.target;
            if (null == a.target || "" == a.target)if (c = this.getBaseTarget(b), null == c || "" == c)c = "_self";
            var d = this.getNamedWindow(b, c);
            if (d) {
                if (this.isSafariLike())try {
                    d._sahi.onBeforeUnLoad()
                } catch (e) {
                }
                d.location = a.href
            } else b.open(a.href,
                c)
        }
    }
};
Sahi.prototype._type = function (a, b, c) {
    for (var d = 0; d < b.length; d++)this.simulateKeyPressEvents(a, b.charAt(d), null, c)
};
Sahi.prototype._setValue = function (a, b) {
    if (null != b) {
        if (this.isApplet(a))return a.setValue(b);
        if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.setValue(b);
        this.invokeLastBlur();
        this.setValue(a, b)
    }
};
Sahi.prototype.shouldAppend = function (a) {
    return !(this._isFF() && !this._isFF4Plus() && !this._isHTMLUnit() || a.readOnly || a.disabled)
};
Sahi.prototype.setValue = function (a, b) {
    this.checkNull(a, "_setValue", 1);
    this.checkVisible(a);
    this._isIE() && (a.setActive(), this.simulateEvent(a, "focusin"));
    this.simulateEvent(a, "focus");
    b = "" + b;
    var c = this.navigator.userAgent.toLowerCase();
    if (-1 != c.indexOf("windows")) {
        if (b = b.replace(/\r/g, ""), !this._isFF() || 12 <= this._getFFVersion())b = b.replace(/\n/g, "\r\n")
    } else c.indexOf("macintosh") ? (b = b.replace(/\r\n/g, "\r"), b = b.replace(/\n/g, "\r")) : -1 != c.indexOf("linux") && (b = b.replace(/\r\n/g, "\n"), b = b.replace(/\r/g,
        "\n"));
    c = a.value;
    this._isFF4Plus() && this._focus(a);
    if (a.type && "hidden" == a.type)a.value = b; else {
        if (a.type && ("range" == a.type || "date" == a.type))a.value = b; else if (!a.type || -1 == a.type.indexOf("select")) {
            var d = a && a.type && -1 != this.findInArray(this.textboxTypes, a.type) && this.shouldAppend(a);
            a.value = "";
            if ("string" == typeof b) {
                var e = b.length;
                a.maxLength && 0 <= a.maxLength && b.length > a.maxLength && (e = a.maxLength);
                for (var g = 0; g < e; g++) {
                    var h = b.charAt(g);
                    this.simulateKeyPressEvents(a, h, null, d)
                }
            }
        }
        var k = c != b;
        this.setLastBlurFn(function () {
            try {
                k &&
                (_sahi._isFF3() || _sahi.simulateEvent(a, "change")), _sahi._isIE() && (_sahi.simulateEvent(a, "deactivate"), _sahi.simulateEvent(a, "focusout")), _sahi._isIE() && a.blur(), _sahi.simulateEvent(a, "blur"), _sahi._isIE() || _sahi.simulateEvent(a, "focusout")
            } catch (b) {
            }
        })
    }
};
Sahi.prototype._setFile2 = function (a, b, c) {
    this._setFile(a, b, c);
    this._isIE() ? (a.outerHTML = a.outerHTML.replace(/type=['"]?file['"]?/, "type\x3dtext"), c = a.name, "" == c && (c = a.id), "" != c && (a = this._textbox(c), this._setValue(a, b), this._blur(a))) : (a.type = "text", this._setValue(a, b), this._blur(a))
};
Sahi.prototype._setFile = function (a, b, c) {
    if (null != b) {
        if (!c && ((c = !a.form || this.isBlankOrNull(a.form.action) || "string" != typeof a.form.action ? this.getWindow(a).location.href : a.form.action) && -1 != (q = c.indexOf("?")) && (c = c.substring(0, q)), 0 != c.indexOf("http"))) {
            var d = window.location;
            0 == c.indexOf("/") ? c = d.protocol + "//" + d.hostname + (d.port ? ":" + d.port : "") + c : (d = d.href, c = d.substring(0, d.lastIndexOf("/") + 1) + c)
        }
        a = this._callServer("FileUpload_setFile", "n\x3d" + a.name + "\x26v\x3d" + this.encode(b) + "\x26action\x3d" + this.encode(c));
        if ("true" != a)throw Error(a);
    }
};
Sahi.prototype.simulateEvent = function (a, b) {
    var c = !this._isIE() || this._isIE9StrictMode() || this._isIE11Plus(), d = this._isIE() && !this._isIE11Plus();
    if (c) {
        c = {};
        c.type = b;
        c.button = 0;
        c.bubbles = !0;
        c.cancelable = !0;
        if (!a)return;
        var e = a.ownerDocument.createEvent("HTMLEvents");
        e.initEvent(c.type, c.bubbles, c.cancelable);
        a.dispatchEvent(e)
    }
    d && (c = a.ownerDocument.createEventObject(), c.type = b, c.bubbles = !0, c.cancelable = !0, c.cancelBubble = !0, a.fireEvent(this.getEventTypeName(b), c))
};
Sahi.prototype.getKeyCode = function (a) {
    return 97 <= a && 122 >= a ? a - 32 : a
};
Sahi.prototype.simulateKeyEvent = function (a, b, c, d) {
    var e = a[0];
    a = a[1];
    d || (d = "");
    var g = -1 != d.indexOf("SHIFT"), h = -1 != d.indexOf("CTRL"), k = -1 != d.indexOf("ALT");
    d = -1 != d.indexOf("META");
    if (!this._isIE() || this._isIE9PlusStrictMode())if (this.isSafariLike() || window.opera || this._isIE9PlusStrictMode()) {
        if (b.ownerDocument.createEvent) {
            var m = b.ownerDocument.createEvent("HTMLEvents"), f = m;
            window.opera || (f.bubbles = !0, f.cancelable = !0);
            f.ctrlKey = h;
            f.altKey = k;
            f.metaKey = d;
            f.charCode = a;
            f.keyCode = "keypress" == c ? a : e;
            f.shiftKey =
                g;
            f.which = f.keyCode;
            f.initEvent(c, !0, !0);
            b.dispatchEvent(f)
        }
    } else {
        f = {};
        f.type = c;
        f.bubbles = !0;
        f.cancelable = !0;
        f.ctrlKey = h;
        f.altKey = k;
        f.metaKey = d;
        f.keyCode = e;
        f.charCode = a;
        f.shiftKey = g;
        if (!b)return;
        m = b.ownerDocument.createEvent("KeyEvents");
        m.initKeyEvent(f.type, f.bubbles, f.cancelable, b.ownerDocument.defaultView, f.ctrlKey, f.altKey, f.shiftKey, f.metaKey, f.keyCode, f.charCode);
        b.dispatchEvent(m)
    }
    this._isIE() && !this._isIE11Plus() && (f = b.ownerDocument.createEventObject(), f.type = c, f.bubbles = !0, f.cancelable = !0, m = this.findClientPosWithOffset(b), f.clientX = m[0], f.clientY = m[1], f.ctrlKey = h, f.altKey = k, f.metaKey = d, f.keyCode = this._isIE() && "keypress" == c ? a : e, f.shiftKey = g, f.shiftLeft = g, f.cancelBubble = !0, f.target = b, b.fireEvent(this.getEventTypeName(c), f))
};
Sahi.prototype.getEventTypeName = function (a) {
    return "object" == typeof MooTools ? a : "on" + a
};
Sahi.prototype.typeNativePhantomJS = function (a) {
    "function" === typeof window.callPhantom && window.callPhantom(a)
};
Sahi.prototype.clickNativePhantomJS = function (a, b, c, d) {
    if ("function" === typeof window.callPhantom) {
        var e = this._position(a);
        a = this.getWindow(a);
        a = _sahi.computeFrameOffset(a);
        _sahi.debug(e[0]);
        _sahi.debug(e[1]);
        e[0] += a[0];
        e[1] += a[1];
        _sahi.debug(e[0]);
        _sahi.debug(e[1]);
        window.callPhantom(e, b, c, d)
    }
};
Sahi.prototype.dragDropNativePhantomJS = function (a, b) {
    if ("function" === typeof window.callPhantom) {
        var c = this._position(a), d = this._position(b);
        window.callPhantom(c, d)
    }
};
Sahi.prototype._simulateMouseEvent = Sahi.prototype.simulateMouseEvent;
Sahi.prototype._simulateMouseEventXY = Sahi.prototype.simulateMouseEventXY;
Sahi.prototype._simulateKeyEvent = Sahi.prototype.simulateKeyEvent;
Sahi.prototype.selectOption = function (a, b, c) {
    c = c ? "CTRL" : null;
    var d = this._option(b, this._in(a));
    if (!d)throw Error("Option not found: " + b);
    this._isIE() ? (this.simulateMouseEvent(a, "mousedown", !1, !1, c), this.simulateMouseEvent(a, "mouseup", !1, !1, c), d.selected = !0, this.simulateMouseEvent(a, "change"), this.simulateMouseEvent(a, "click", !1, !1, c)) : this._isFF() ? (d.selected = !0, this.simulateMouseEvent(d, "mousedown", !1, !1, c), this.simulateMouseEvent(d, "mouseup", !1, !1, c), this.simulateMouseEvent(a, "change"), this.simulateMouseEvent(d,
        "click", !1, !1, c)) : (d.selected = !0, this.simulateMouseEvent(a, "change"))
};
Sahi.prototype.selectOptionWithSize = function (a, b, c) {
    c = c ? "CTRL" : null;
    var d = this._option(b, this._in(a));
    if (!d)throw Error("Option not found: " + b);
    this._isIE() ? (this.simulateMouseEvent(a, "mousedown", !1, !1, c), this.simulateEvent(a, "beforeactivate"), this.simulateEvent(a, "activate"), this.simulateEvent(a, "focusin"), this.simulateEvent(a, "focus"), this.simulateMouseEvent(a, "mouseup", !1, !1, c), d.selected = !0, this.simulateMouseEvent(a, "change"), this.simulateMouseEvent(a, "click", !1, !1, c)) : (d.selected = !0, this.simulateMouseEvent(d,
        "mousedown", !1, !1, c), this.simulateEvent(a, "focus"), (this._isChrome() || this._isSafari() || this._isOpera()) && this.simulateEvent(a, "focusin"), this.simulateMouseEvent(d, "mouseup", !1, !1, c), this.simulateMouseEvent(a, "change"), this.simulateMouseEvent(d, "click", !1, !1, c))
};
Sahi.prototype._setSelected = function (a, b, c) {
    if (null != b) {
        this.checkNull(a, "_setSelected");
        this.checkVisible(a);
        if (this.isApplet(a))return a.setSelected(b);
        if (this.isFlexObj(a))return null != this.lookInside && (a = a.inside(this.lookInside)), a.choose(b);
        this.xyoffsets = new Sahi.Dict;
        var d = a.options.length;
        if ("select-one" == a.type)if (1 < a.size)this.selectOptionWithSize(a, b); else {
            this.simulateMouseEvent(a, "mousedown");
            (this._isIE() || this._isChrome()) && this.simulateEvent(a, "focusin");
            this.simulateEvent(a, "focus");
            this.simulateMouseEvent(a, "mouseup");
            this.simulateMouseEvent(a, "click");
            this.selectOption(a, b);
            return
        } else {
            this.isArray(b) || (b = [b]);
            if (!c)for (var e = 0; e < d; e++)a.options[e].selected = !1;
            for (e = 0; e < b.length; e++)this.selectOption(a, b[e], 0 < e || c)
        }
        this.setLastBlurFn(function () {
            try {
                _sahi._isIE() && _sahi.simulateEvent(a, "focusout"), _sahi.simulateEvent(a, "blur")
            } catch (b) {
            }
        })
    }
};
Sahi.prototype._check = function (a) {
    this.checkNull(a, "_check");
    a.checked || this._click(a)
};
Sahi.prototype._uncheck = function (a) {
    this.checkNull(a, "_uncheck");
    a.checked && this._click(a)
};
Sahi.prototype._wait = function (a, b) {
    return b ? eval(b) : !1
};
Sahi.prototype.getTextNodesIn = function (a) {
    var b = [];
    if (3 == a.nodeType)b.push(a); else {
        a = a.childNodes;
        for (var c = 0, d = a.length; c < d; ++c)b.push.apply(b, this.getTextNodesIn(a[c]))
    }
    return b
};
Sahi.prototype.getDocumentNode = function (a) {
    "iframe" == a.tagName.toLowerCase() ? a = a.contentWindow.document.body : this.isWindow(a) && (a = a.document.body);
    return a
};
Sahi.prototype.getStartEndIndexes = function (a, b) {
    var c = -1, d = -1, e = this.getArrayNameAndIndex(a, !0), g = e.index, e = e.name;
    -1 == g && (g = 0);
    if (e instanceof RegExp) {
        for (var h = null, k = 0; k <= g && (h = e.exec(b), null != h); k++);
        h && (c = h.index, d = e.lastIndex)
    } else {
        h = -1;
        for (k = 0; k <= g && (h = b.indexOf(e, h + 1), -1 != h); k++);
        -1 != h && (c = h, d = c + e.length)
    }
    return [c, d]
};
Sahi.prototype._selectTextRange = function (a, b, c) {
    this.checkNull(a, "_selectTextRange");
    var d = 0, e = 0;
    a = this.getDocumentNode(a);
    var g = -1 != this.findInArray(this.textboxTypes, a.type) || "textarea" == a.type ? a.value : a.textContent;
    g && (b = this.getStartEndIndexes(b, g), d = b[0], e = b[1]);
    this._selectRange(a, d, e, c)
};
Sahi.prototype._selectRange = function (a, b, c, d) {
    if (-1 != b && -1 != c) {
        "after" == d && (b = c);
        this.checkNull(a, "_selectRange");
        a = this.getDocumentNode(a);
        var e = this.getWindow(a);
        if (-1 != this.findInArray(this.textboxTypes, a.type) || "textarea" == a.type)if ("before" == d && (c = b), a.createTextRange) {
            var g = a.createTextRange();
            g.collapse(!0);
            g.moveStart("character", b);
            this._isIE() && (c -= b);
            g.moveEnd("character", c);
            g.select();
            a.focus()
        } else"undefined" != typeof a.selectionStart ? (a.selectionStart = b, a.selectionEnd = c, a.focus()) : a.setSelectionRange &&
        (a.focus(), a.setSelectionRange(b, c)); else if (document.createRange && window.getSelection) {
            g = e.document.createRange();
            g.selectNodeContents(a);
            a = this.getTextNodesIn(a);
            for (var h = !1, k = 0, m, f = 0, l; l = a[f++];) {
                m = k + l.length;
                if (!h && b >= k && (b < m || b == m && f < a.length)) {
                    if ("before" == d) {
                        if (b - k == l.length && c != b && f + 1 < a.length) {
                            b = a[f];
                            g.setStartBefore(b);
                            g.setEnd(b, 0);
                            g.collapse(!0);
                            break
                        }
                        g.setStart(l, b - k);
                        g.setEnd(l, b - k);
                        break
                    }
                    g.setStart(l, b - k);
                    h = !0
                }
                if (h && c <= m) {
                    g.setEnd(l, c - k);
                    break
                }
                k = m
            }
            b = e.getSelection();
            b.removeAllRanges();
            b.addRange(g)
        } else document.selection && document.body.createTextRange && (g = this.getWindow(a).document.body.createTextRange(), g.moveToElementText(a), g.collapse(!0), g.moveEnd("character", c), g.moveStart("character", b), g.select())
    }
};
Sahi.prototype._mapDomainToIP = function (a, b) {
    a = 0 == a.indexOf("http") ? a : "http://" + a;
    b && this._addToSession(a);
    var c = "domain\x3d" + encodeURIComponent(".*" + a.replace(/[.]/g, "[.]") + ".*"), c = c + ("\x26ip\x3d" + encodeURIComponent(null == b ? "" : b)), c = c + ("\x26sahisid\x3d" + _sahi.sid);
    this.sendToServer("/_s_/dyn/pro/in.co.sahi.plugin.Rerouter_mapDomainToIP?" + c)
};
var SahiScrollAndCapture = function (a, b, c, d, e, g, h, k, m, f, l, n) {
    this.el = d ? d : window;
    this.win = c;
    this.img = b;
    this.delay = e ? e : 100;
    _sahi._isPhantomJS() && 5E3 > this.delay && (this.delay = 5E3);
    this.stepId = a;
    this.scrollLimit = g ? g : 2E5;
    this.trim = !0 === h;
    this.fileSysPath = k ? k : null;
    this.noLog = !0 === m;
    this.wrapped = [];
    this.isPhantomJS = n;
    this.format = f && "-1" != f ? f : _sahi.getImageFormat();
    this.resizePercentage = l && -1 != l ? l : _sahi.getResizePercentage()
};
SahiScrollAndCapture.prototype.init = function () {
    this.isPhantomJS ? this.schedulePhantomJSStart() : this.scheduleStart()
};
SahiScrollAndCapture.prototype.wrap = function (a) {
    var b = this;
    null == this.wrapped[a] && (this.wrapped[a] = function () {
        return a.apply(b, arguments)
    });
    return this.wrapped[a]
};
SahiScrollAndCapture.prototype.scheduleStart = function () {
    setTimeout(this.wrap(this.start), this.delay)
};
SahiScrollAndCapture.prototype.schedulePhantomJSStart = function () {
    setTimeout(this.wrap(this.phantomJSStart), this.delay)
};
SahiScrollAndCapture.prototype.phantomJSStart = function () {
    this.phantomJSImg = _sahi.takeSnapShotPhantomJS(999, 999, this.format);
    this.scheduleStart()
};
SahiScrollAndCapture.prototype.start = function () {
    var a = this.phantomJSImg, a = this.isPhantomJS ? _sahi.fetchTopXY(a) : _sahi.fetchTopXY();
    this.img.style.display = "none";
    this.originalOverflowX = _sahi._style(this.win.document.documentElement, "overflow-x");
    this.originalOverflowY = _sahi._style(this.win.document.documentElement, "overflow-y");
    this.win.document.documentElement.style.overflowX = "hidden";
    this.win.document.documentElement.style.overflowY = "hidden";
    this.left = a[0];
    this.top = a[1];
    a = _sahi.getWinDimensions(this.win);
    this.width = a[0];
    this.height = a[1];
    this.innerHeight = a[1];
    this.scrollHeight = parseInt(this.win.document.body.scrollHeight);
    this.scrollHeight > this.scrollLimit && (this.scrollHeight = this.scrollLimit);
    this.win.scrollTo(0, 0);
    this.counter = 0;
    this.scheduleProceed()
};
SahiScrollAndCapture.prototype.scheduleProceed = function () {
    setTimeout(this.wrap(this.proceed), this.delay)
};
SahiScrollAndCapture.prototype.proceed = function () {
    this.isPhantomJS ? _sahi.takeSnapShotPhantomJS(this.stepId, this.counter, this.format) : _sahi.takeSnapShot(this.stepId, this.counter, this.top, this.left, this.height, this.width, this.format, !1);
    this.counter++;
    "frameset" == ("" + this.win.document.body.tagName).toLowerCase() || this.isPhantomJS ? this.logAndStitch() : this.scrollHeight - this.innerHeight > this.innerHeight && !this.isPhantomJS ? (this.win.scrollBy(0, this.innerHeight), this.scrollHeight -= this.innerHeight, this.scheduleProceed()) :
        0 >= this.scrollHeight - this.innerHeight ? this.logAndStitch() : (this.win.scrollBy(0, this.scrollHeight - this.innerHeight), this.scrollHeight -= this.innerHeight, this.top = this.top + this.innerHeight - this.scrollHeight, this.height = this.scrollHeight, this.scheduleLast())
};
SahiScrollAndCapture.prototype.scheduleStitch = function () {
    setTimeout(this.wrap(this.stitch), this.delay)
};
SahiScrollAndCapture.prototype.stitch = function () {
    if (this.el == window || _sahi.isWindow(this.el))lastImageFilePath = _sahi.stitchSnapShots(this.stepId, this.counter, "V", -1, -1, -1, -1, this.noLog, this.format, this.resizePercentage, this.fileSysPath); else {
        var a = _sahi._position(this.el), b = a[1], a = a[0];
        this.isPhantomJS && (b += this.top, a += this.left);
        lastImageFilePath = _sahi.stitchSnapShots(this.stepId, this.counter, "V", b, a, this.el.offsetHeight, this.el.offsetWidth, this.noLog, this.format, this.resizePercentage, this.fileSysPath)
    }
    _sahi.lastImageFilePath =
        null;
    this.isAssert ? this.assertImage(lastImageFilePath) : (this.noLog || (_sahi.lastImageFilePath = lastImageFilePath), _sahi.afterEval())
};
SahiScrollAndCapture.prototype.scheduleLast = function () {
    setTimeout(this.wrap(this.last), this.delay)
};
SahiScrollAndCapture.prototype.last = function () {
    this.isPhantomJS ? _sahi.takeSnapShotPhantomJS(this.stepId, this.counter, this.format) : _sahi.takeSnapShot(this.stepId, this.counter, this.top, this.left, this.height, this.width, this.format, !1);
    this.counter++;
    this.logAndStitch()
};
SahiScrollAndCapture.prototype.logAndStitch = function () {
    this.win.document.documentElement.style.overflowX = this.originalOverflowX;
    this.win.document.documentElement.style.overflowY = this.originalOverflowY;
    this.scheduleStitch()
};
SahiScrollAndCapture.prototype.setAssertProperties = function (a, b, c) {
    this.isAssert = !0;
    this.refImagePath = a;
    this.threshold = b;
    this.displayOnSuccess = c
};
SahiScrollAndCapture.prototype.assertImage = function (a) {
    var b = _sahi._callServer("Driver_getCompareImagesData", "actualImage\x3d" + a + "\x26refImage\x3d" + this.refImagePath + "\x26stepId\x3d" + this.stepId + "\x26isSnapShot\x3dtrue").split(",");
    a = parseInt(b.shift());
    _sahi.lastImageFilePath = b.toString();
    b = "Score: " + a;
    if (isNaN(a) || a > this.threshold)_sahi.currentType = "FAILURE", _sahi.markStepDone(_sahi.currentStepId, _sahi.currentType, b, _sahi.lastImageFilePath), _sahi.lastImageFilePath = null, _sahi.waitForLoad = _sahi.SAHI_MAX_WAIT_FOR_LOAD;
    else return _sahi.currentType = "SUCCESS", this.displayOnSuccess || (_sahi.lastImageFilePath = null), _sahi._log(b, _sahi.currentType), _sahi.afterEval(), a
};
Sahi.prototype._assertEqualImages = function (a, b, c, d, e) {
    if (!this.SKIP_ASSERT_SNAPSHOTS)if (this.fork(3E4), null == c && (c = this.DEFAULT_IMAGE_COMPARISON_THRESHOLD), b = _sahi._callServer("Driver_getCompareImagesData", "actualImage\x3d" + b + "\x26refImage\x3d" + a + "\x26stepId\x3d" + this.currentStepId + "\x26isSnapShot\x3dfalse").split(","), a = parseInt(b.shift()), _sahi.lastImageFilePath = b.toString(), b = "Score: " + a, isNaN(a) || a > c)_sahi.currentType = "FAILURE", _sahi.markStepDone(_sahi.currentStepId, _sahi.currentType, e + "\n" + b,
        _sahi.lastImageFilePath), _sahi.lastImageFilePath = null, _sahi.waitForLoad = _sahi.SAHI_MAX_WAIT_FOR_LOAD; else return _sahi.currentType = "SUCCESS", d || (_sahi.lastImageFilePath = null), _sahi._log(b, _sahi.currentType), _sahi.afterEval(), a
};
Sahi.prototype.getFirstFrameInFrameset = function (a) {
    if ("frameset" == ("" + a.document.body.tagName).toLowerCase()) {
        var b = a.frames;
        if (b)for (var c = 0; c < b.length; c++) {
            var d = b[c];
            try {
                if (0 < d.document.body.offsetHeight)return d
            } catch (e) {
            }
        }
    }
    return a
};
Sahi.prototype.placePattern = function (a) {
    a.focus();
    var b = a.document.elementFromPoint(0, 0);
    b && "APPLET" == b.tagName && (b.style.top = "1px", this.appletOnTop = b);
    a.scrollTo(0, 0);
    a = this.getFirstFrameInFrameset(a);
    var c = a.document.getElementById("sahi_pattern");
    c ? c.style.display = "block" : (c = new Image, c.id = "sahi_pattern", c.src = "/_s_/spr/images/pattern.png", a.document.body.appendChild(c), c.style.position = "absolute", c.style.top = "0", c.style.left = "0", c.style.zIndex = "" + this.getPatternZIndex(b));
    return c
};
Sahi.prototype.getPatternZIndex = function (a) {
    if (!a)return 2147483647;
    var b = 2147483647;
    try {
        var c = this._style(a, "z-index"), c = parseInt(c);
        2147483647 < c && (2147483647 <= c ? a.style.zIndex = "2147483646" : b = c + 1)
    } catch (d) {
    }
    return b
};
Sahi.prototype.removePatternAndScroll = function (a) {
    this.removePattern(this.getWindow(a));
    this.scrollIntoView(a)
};
Sahi.prototype.scrollIntoView = function (a) {
    return (this.isFlexObj(a) ? a.object : a).scrollIntoView()
};
Sahi.prototype.removePattern = function (a) {
    var b = this.appletOnTop;
    b && (b.style.top = "0px", this.appletOnTop = null);
    if (a = a.document.getElementById("sahi_pattern"))a.style.display = "none"
};
Sahi.prototype._takePageScreenShot = function (a, b, c, d) {
    if (!this.SKIP_SCREENSHOTS) {
        null === a && (a = this._eval(top));
        var e = null, g = null, h = !0, k = null, m = null;
        d && (d.delay && (e = d.delay), d.scrollLimit && (g = d.scrollLimit), d.trim && (h = d.trim), d.format && (k = d.format), d.resizePercentage && (m = d.resizePercentage));
        0 < arguments.length && this.checkNull(a, "_takePageScreenShot");
        this.fork(6E4);
        var f = window;
        a && a != window && (f = this.getWindow(a));
        var l = this.placePattern(f);
        this.takeScrolledScreenShot(f, l, a, e, g, h, b, c, k, m)
    }
};
Sahi.prototype.takeScrolledScreenShot = function (a, b, c, d, e, g, h, k, m, f) {
    (new SahiScrollAndCapture(this.currentStepId, b, a, c, d, e, g, h, k, m, f, _sahi._isPhantomJS())).init()
};
Sahi.prototype.fetchTopXY = function (a) {
    return a && null !== a && void 0 !== a ? eval("(" + this.sendToServer("/_s_/dyn/Player_getTopXY?imagePath\x3d" + a) + ")") : eval("(" + this.sendToServer("/_s_/dyn/Player_getTopXY") + ")")
};