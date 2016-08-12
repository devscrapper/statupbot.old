var isTouchOn = false;
Sahi.prototype._touch = function (el, count) {
	if(typeof count == 'undefined') count = 1;
	if(this.lookInside != null) el = el.inside(this.lookInside);
	this.checkNull(el, "_touch");
	this.checkVisible(el);
	if(this._isIE()){
		this.touchInIE(el);
		return;
	}
//	if (this.isApplet(el))	return el.click();
//	if (this.isFlexObj(el)) return el.click();
	this.simulateTouch(el,count);
};
Sahi.prototype._tap = Sahi.prototype._touch;
Sahi.prototype._touchCancel = function (el) {
	if(this.lookInside != null) el = el.inside(this.lookInside);
	this.checkNull(el, "_touch");
	this.checkVisible(el);
	if(this._isIE()){
		this.touchCancelInIE(el);
		return;
	}
//	if (this.isApplet(el))	return el.click();
//	if (this.isFlexObj(el)) return el.click();
	this.simulateTouchSingleEvent(el,'touchcancel');
};

Sahi.prototype._touchStart = function (el, startX, startY) {
	isTouchOn = true;
	if(this.lookInside != null) el = el.inside(this.lookInside);
	this.checkNull(el, "_touch");
	this.checkVisible(el);
	if(this._isIE()){
		this.touchStartInIE(el);
		return;
	}
//	if (this.isApplet(el))	return el.click();
//	if (this.isFlexObj(el)) return el.click();
	this.simulateTouchSingleEvent(el,'touchstart', startX, startY);
};

Sahi.prototype._touchEnd = function (el, endX, endY) {
	if(this.lookInside != null) el = el.inside(this.lookInside);
	this.checkNull(el, "_touch");
	this.checkVisible(el);
	if(this._isIE()){
		this.touchEndInIE(el);
		return;
	}
//	if (this.isApplet(el))	return el.click();
//	if (this.isFlexObj(el)) return el.click();
	this.simulateTouchSingleEvent(el,'touchend', endX, endY);
	isTouchOn = false;
};

Sahi.prototype._touchMove = function (el, moveX, moveY, isRelative) {
	this._touchStart(el);
	if(typeof isRelative == 'undefined') isRelative = true;
//	this._touchStart(el);
	if(this.lookInside != null) el = el.inside(this.lookInside);
	this.checkNull(el, "_touch");
	this.checkVisible(el);
	if(this._isIE()){
		this.touchMoveInIE(el, moveX, moveY);
		return;
	}
	if(!isRelative){
		moveX = moveX - _sahi._position(el)[0];
		moveY = moveY - _sahi._position(el)[1];
		/*var goBackX = _sahi._position(el)[0];
		var goBackY = _sahi._position(el)[1];
		this.simulateTouchSingleEvent(el,'touchmove', -goBackX, -goBackY);*/
	}
	this.simulateTouchSingleEvent(el,'touchmove', moveX, moveY);
};
Sahi.prototype._swipe = Sahi.prototype._touchMove;

Sahi.prototype.simulateTouchSingleEvent = function (el, type, pageX, pageY) {
	var identifier = new Date().getTime();
	var touch = document.createTouch(window, el, identifier, pageX, pageY, 0, 0);
	var touches = document.createTouchList(touch);
    var targetTouches = document.createTouchList(touch);
    var changedTouches = document.createTouchList(touch);
    try {
    	this.simulateType(el, touch, touches, targetTouches, changedTouches, type, pageX, pageY);
    } catch (except){
    	this._alert(except);
    } 
};
Sahi.prototype.simulateTouch = function (el, count) {
	if(typeof count == 'undefined') count = 1;
	var x = this._position(el)[0];
	var y = this._position(el)[1];
    var touchArray = [];
    var identifier = new Date().getTime();
    for(var i = 0; i< count; i++){
    	var touchI = document.createTouch(window, el, identifier, 0, 0, 0, 0);
    	touchArray.push(touchI);
    }
    var touches = document.createTouchList.apply(document, touchArray);
	var targetTouches = document.createTouchList.apply(document, touchArray);
	var changedTouches = document.createTouchList.apply(document, touchArray);
    
    try {
	    this.simulateType(el, touchI, touches, targetTouches, changedTouches, 'touchstart');
	    this.simulateType(el, touchI, touches, targetTouches, changedTouches, 'touchmove', 1, 1);
    	this.simulateType(el, touchI, touches, targetTouches, changedTouches, 'touchend');
    } catch (except){
    	this._alert(except);
    } 
};
Sahi.prototype.simulateType = function(el, touch, touches, targetTouches, changedTouches, type, pageX, pageY) {
	if (!pageX) {
		pageX = 0;
	}
	if (!pageY) {
		pageY = 0;
	}
	var evt = document.createEvent('UIEvent');
    evt.initUIEvent(
    		 type, //type of event
    		 true, //data.bubbles
    		 true, //data.cancelable
    		 window, //data.view
    		 true, //data.detail
    		 0, //data.screenX
    		 0, //data.screenY
    		 pageX, //data.pageX
    		 pageY, //data.pageY
    		 false, //data.ctrlKey
    		 false, //data.altKey
    		 false, //data.shiftKey
    		 false, //data.metaKey
     	     touches, //data.touches
     	     targetTouches, //data.targetTouches
     	     changedTouches, //data.changedTouches
     	     1, //data.scale
     	     0 //data.rotation
     	     );
     evt.bubbles = true;
     evt.detail = 1;
     evt.cancelable = true;
     evt.view = window;
     evt.altKey = false;
     evt.ctrlKey = false;
     evt.shiftKey = false;
     evt.metaKey = false;
     evt.touch = touch;
     evt.touches = touches;
     evt.targetTouches = targetTouches;
     evt.changedTouches = changedTouches;
     el.dispatchEvent(evt);
}
/* Touch For IE */

Sahi.prototype.touchInIE = function (el) {
//	if (this.isApplet(el))	return el.click();
//	if (this.isFlexObj(el)) return el.click();
	this.simulateTouchinIE(el);
};
Sahi.prototype.simulateTouchinIE = function (el) {
	var identifier = new Date().getTime();
	var touch = new MSGesture();
	touch.target = el;
   
    try {
    	this.simulateTypeInIE(el, identifier, touch, 'MSPointerDown');
    	this.simulateTypeInIE(el, identifier, touch, 'MSPointerMove', 1, 1);
    	this.simulateTypeInIE(el, identifier, touch, 'MSPointerUp');
    } catch (except){
    	this._alert(except);
    } 
};
Sahi.prototype.simulateTypeInIE = function(el, identifier, touch, type, pageX, pageY) {
	if (!pageX) {
		pageX = 0;
	}
	if (!pageY) {
		pageY = 0;
	}
	var evt = document.createEvent('UIEvent');
	// createEventObject
	//el.attachEvent
    evt.initUIEvent(
    		 type, //type of event
    		 true, //data.bubbles
    		 true, //data.cancelable
    		 window, //data.view
    		 true, //data.detail
    		 0, //data.screenX
    		 0, //data.screenY
    		 pageX, //data.pageX
    		 pageY, //data.pageY
    		 false, //data.ctrlKey
    		 false, //data.altKey
    		 false, //data.shiftKey
    		 false //data.metaKey
     	     );
     evt.view = window;
     evt.altKey = false;
     evt.ctrlKey = false;
     evt.shiftKey = false;
     evt.metaKey = false;
     evt.touch = touch;
//     evt.touches = touches;
//     evt.targetTouches = targetTouches;
//     evt.changedTouches = changedTouches;
     el.dispatchEvent(evt);
};

Sahi.prototype.simulateTypeSingleEventInIE = function(el, identifier, touch, type, pageX, pageY) {
	var target = el;
	if (!pageX) {
		pageX = 0;
	}
	if (!pageY) {
		pageY = 0;
	}
	var evt = document.createEvent('MSGestureEvent');
	evt.initGestureEvent(type, true, true, window, 1, 0, 0, pageX, pageY, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, el);
	evt.type = type;
	evt.bubbles = true;
    evt.cancelable = true;
    evt.view = window;
    evt.detail = true;
    evt.clientX = pageX;
    evt.clientY = pageY;
    evt.altKey = false;
    evt.ctrlKey = false;
    evt.shiftKey = false;
    evt.metaKey = false;
    evt.which = 1;
    evt.button=-1;
    target.dispatchEvent(evt);
};
Sahi.prototype.touchEndInIE = function (el, startX, startY) {
	this.simulateTouchSingleEventInIE(el,'MSPointerUp', startX, startY);
};

Sahi.prototype.touchStartInIE = function (el, startX, startY) {
	this.simulateTouchSingleEventInIE(el,'MSPointerDown', startX, startY);
};

Sahi.prototype.touchCancelInIE = function (el, startX, startY) {
	this.simulateTouchSingleEventInIE(el,'MSPointerCancel', startX, startY);
};
Sahi.prototype.simulateTouchSingleEventInIE = function (el, type, pageX, pageY) {
	var identifier = new Date().getTime();
	var touch = new MSGesture();
	touch.target = el;
	touch.pageX = pageX;
	touch.pageY = pageY;

    try {
    	this.simulateTypeSingleEventInIE(el, identifier, touch, type, pageX, pageY);
    } catch (except){
    	this._alert(except);
    } 
};
Sahi.prototype.touchMoveInIE = function (el, moveX, moveY) {
	this.simulateTouchSingleEventInIE(el,'MSPointerMove', moveX, moveY);
};
