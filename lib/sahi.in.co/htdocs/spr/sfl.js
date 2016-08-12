function SflWrapper(o){
	this.isSFL = true;
	this.object = o;
	this.id = o._sahi_getFlexId();
	this.accessorAPINames = new Array();
	this.addAccessorFns();
	
}
SflWrapper.prototype.loadRecordParameters = function(s){
	this.object._sahi_setRecordParameters("addRecordListenerToRoot", true);
	this.object._sahi_setRecordParameters("addRecordListenerToRootOnMouseOver", true);
	this.object._sahi_setRecordParameters("addRecordListenerToRootOnMouseOut", true);
	this.object._sahi_setRecordParameters("addRecordListenerToRootOnClick", true);
	this.object._sahi_setRecordParameters("addRecordListenerToRootOnClickForControllerOpen", true);
	this.object._sahi_setRecordParameters("addRecordListener", true);
	this.object._sahi_setRecordParameters("addAllEventListener", true);
	this.object._sahi_setRecordParameters("addEventListenerOnClick", true);
	this.object._sahi_setRecordParameters("addEventListenerOnSetSelected", true);
	this.object._sahi_setRecordParameters("addEventListenerOnSetValue", true);
	this.object._sahi_setRecordParameters("reAttachRecorderListenersOnInterval", true);
	this.object._sahi_setRecordParameters("debug", false);
}
__fl_debugStr = "";
SflWrapper.prototype.debug = function(s){
	_sahi._debug(s);
	return;
	__fl_debugStr += "\n" + s;
	_sahi.showStepsInController(__fl_debugStr);
}
SflWrapper.prototype.display = function(s){
	var val = "";
	if (typeof _sahi == "object") {
		var ar = eval("("+s+")");
		var alts = [];
		for (var i=0; i<ar.length; i++) {
			var item = ar[i];
			alts.push(SflWrapper.convertToFn(item));
		}
		_sahi.sendIdentifierInfo(alts, 
				alts[0], 
				ar[0].value, 
				_sahi.getPopupDomainPrefixes(), 
				[]);
	}
}
SflWrapper.prototype.record = function(elJSON, action, value){
	if (action == "click") value = null;
	if (typeof _sahi == "object") {
		var s = SflWrapper.convertToFn(elJSON);
		if (_sahi.isRecording()){
			_sahi.recordStep(this.getStep(action, s, value));
		}
	}
}
SflWrapper.prototype.getStep = function(action, accessorS, value){
	return "_" + action + "(" + accessorS + (value ? (", " + value) : "") + ");";
}
SflWrapper.prototype.exists = function(){
	try{
		return this.fetch("constructor") != "Error:null_object";
	}catch(e){
		return false;
	}
}
SflWrapper.prototype.isVisible = function(){
	if (!this.exists()) return false;
	try {
		return this.get("visible") == true;
	}catch(e){return false;}
}
SflWrapper.prototype.xgetFlexApp = function(id){
	if (navigator.appName.indexOf ("Microsoft") !=-1) return window[id];
	return document[id];
}
SflWrapper.prototype.addAccessorFns = function(){
	var actionMethodNames = ["getGlobalXY", "click", "mouseDown", "mouseOver", "mouseUp", "dragDrop", "dragDropXY", "setAsDroppable",
	                         "setValue", "fetch", "choose", "listProperties", 
	                         "introspect", "executeFn", 
	                         "set", "highlight", "getValue", 
	                         "getText", "getRowNo", "getColumnNo", "getGridData", 
	                         "getTextOrToolTip", "getDataProviderData", 
	                         "rightClick", "doubleClick", "identifyParent" , "identifySelf"];	
	for (var i=0; i<actionMethodNames.length; i++){
		var methodName = actionMethodNames[i];
		this[methodName] = this.getFlexFn(methodName, true);
	}
}
SflWrapper.prototype.getFlexFn = function(methodName, isAction){
	return function(){
		var ar = new Array();
		if (this.command) ar[0] = this.command;
		for (var i=0; i<arguments.length; i++){
			ar[ar.length] = arguments[i];
		}
		var command = {api:methodName, args:ar};
		//_sahi._alert(_sahi.toJSON(command));
		if (isAction){
			var s = this.object._sahi_eval(command);
			if (s && (typeof s == "string") && s.indexOf("SAHI_FLEX_ERROR") == 0) throw new Error(s);
			var e = eval("(" + s.replace(/[\r\n]/g, "\\r\\n") + ")");
			return e;
		}else {
			this.command = command;
			return this;
		}
	}
}
/*
SflWrapper.prototype.getAPIObj = function(apiName, args){
	if (_sahi.isArray(args)) args = [args];
	return {api:apiName, args:args};
}
*/
SflWrapper.convertToFn = function(s){
	var o = (typeof s == "string") ? eval("(" + s + ")") : s;
	return '_f("' + o.objectId + '").' + o.api + '(' + _sahi.toJSON(o.args[0]) + ')';
}
SflWrapper.prototype.addMetaData = function(metadata){
	if (!metadata.apiName) metadata.apiName = this.getAccessorAPIName(metadata.qn);
	SflWrapper.prototype[metadata.apiName] = this.getFlexFn(metadata.apiName);
	this.object._sahi_addMetaData(metadata);
}

SflWrapper.prototype.addEncaps = function(qn, encapsQn){
	this.object._sahi_addEncaps(qn, encapsQn);
}

SflWrapper.prototype.setStrictVisibility = function(b){
	this.object._sahi_setStrictVisibility(b);
}

SflWrapper.prototype.find = function(type, identifier){
	return this[type](identifier);
}
SflWrapper.prototype.getAccessorAPIName = function(qn){
	var ix = qn.indexOf("::");
	if (ix != -1) {
		var a = qn.substring(ix+2).toLowerCase();
		return (qn.indexOf("spark") == 0) ? ("s_"+a) : a; 
	}
	return qn;
}

SflWrapper.prototype.addAllRecorderListeners = function(){
	this.object._sahi_addAllRecorderListeners();
}
SflWrapper.prototype.leftOf = function(leftOfObj, offSetX, offSetY){
	if(!offSetY) offSetY = offSetX;
	var a0 = this.command.args[0];
	if (typeof a0 == 'object' && a0['id'] != null) {
		a0['leftOf'] = leftOfObj.command;
		a0['leftOf'].offsetX = offSetX;
		a0['leftOf'].offsetY = offSetY;
	} else {
		this.command.args[0] = {id:this.command.args[0], leftOf:leftOfObj.command};
		this.command.args[0].leftOf.offsetX = offSetX;
		this.command.args[0].leftOf.offsetY = offSetY;
	}
	return this;
}
SflWrapper.prototype.under = function(underObj, offSetX, offSetY){
	if(!offSetY) offSetY = offSetX;
	var a0 = this.command.args[0];
	if (typeof a0 == 'object' && a0['id'] != null) {
		a0['under'] = underObj.command;
		a0['under'].offsetX = offSetX;
		a0['under'].offsetY = offSetY;
	} else {
		this.command.args[0] = {id:a0, under:underObj.command};
		this.command.args[0].under.offsetX = offSetX;
		this.command.args[0].under.offsetY = offSetY;
	}
	return this;
}
SflWrapper.prototype.rightOf = function(rightOfObj, offSetX, offSetY){
	if(!offSetY) offSetY = offSetX;
	var a0 = this.command.args[0];
	if (typeof a0 == 'object' && a0['id'] != null) {
		a0['rightOf'] = rightOfObj.command;
		a0['rightOf'].offsetX = offSetX;
		a0['rightOf'].offsetY = offSetY;
	} else {
		this.command.args[0] = {id:a0, rightOf:rightOfObj.command};
		this.command.args[0].rightOf.offsetX = offSetX;
		this.command.args[0].rightOf.offsetY = offSetY;
	}
	return this;
}
SflWrapper.prototype.near = function(nearObj){
	var a0 = this.command.args[0];
	if (typeof a0 == 'object' && a0['id'] != null) {
		a0['near'] = nearObj.command;
	} else {
		this.command.args[0] = {id:this.command.args[0], near:nearObj.command};
	}
	return this;
}
SflWrapper.prototype.inside = function(inObj){
	var a0 = this.command.args[0];
	if (typeof a0 == 'object' && a0['id'] != null) {
		a0['inside'] = inObj.command;
	} else {
		this.command.args[0] = {id:this.command.args[0], inside:inObj.command};
	}
	return this;
}
SflWrapper.prototype.getData = function(){
	return this.getDataProviderData();
}
SflWrapper.prototype.get = function(attr){
	return this.fetch(attr);
}

SflWrapper.prototype.currentCursorID = function(){
	return this.object._sahi_currentCursorID();
}
SflWrapper.prototype.addAllMetaData = function(){
//	this.addMetaData({qn: "mx.core::UIComponent", attributes: ["label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "label"});
//	this.addMetaData({qn: "mx.controls::Text", attributes: ["label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "text"});
//	this.addMetaData({qn: "mx.controls::TextArea", attributes: ["label", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "setValue", value: "text"});
//	this.addMetaData({qn: "spark.components::Group", attributes: ["encaps_spark.components::Form","encaps_spark.components::DataGrid","encaps_spark.components::VideoPlayer","encaps_spark.components::TitleWindow","encaps_spark.components::RichText","encaps_spark.components::VScrollBar","encaps_spark.components::TextArea","encaps_spark.components::NavigatorContent","encaps_spark.components::PopUpAnchor","label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "label"});
//	this.addMetaData({qn: "spark.components::HGroup", attributes: ["encaps_spark.components::VScrollBar","label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "name"});
//	this.addMetaData({qn: "spark.components::VGroup", attributes: ["encaps_spark.components::DataGrid","encaps_spark.components::HSlider","encaps_spark.components::HSrollBar","encaps_spark.components::NumericStepper","label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "name"});
//	this.addMetaData({qn: "spark.components::Scroller", attributes: ["label", "text", "name", "automationName", "toolTip", "id", "autoGeneratedName", "index"], action: "click", value: "value"});

	for(var i=0; i<_sahi.accessors_flex_metadata.length; i++){
		var accessors_metadata = _sahi.accessors_flex_metadata[i];
		this.addMetaData(accessors_metadata);
	}	
	
	SflWrapper.prototype.cell = this.getFlexFn("cell");
	
	this.addCustomMetaData();
}
Sahi.prototype.getFlexWrapper = function(o){
	var win = this.getWindow(o);
	var t = win.SflWrapper;
	return new t(o);
}
Sahi.prototype._flex = function(id){
	try {
		var o = this._object(id);
		if (o && typeof o._sahi_getFlexId == "function") return this.getFlexWrapper(o);
		o = this._embed(id);
		if (o && typeof o._sahi_getFlexId == "function") return this.getFlexWrapper(o);
	} catch (e) {
		return null;
	}
}
Sahi.prototype._findFlexElement = function(fl, api, id, rel){
	var el = fl[api](id);
	if (rel && rel.type == "dom") {
		if (rel.relation == "_in") return el.inside(rel.element);
		if (rel.relation == "_near") return el.near(rel.element);
		if (rel.relation == "_leftOf") return el.leftOf(rel.element);
		if (rel.relation == "_rightOf") return el.rightOf(rel.element);
		if (rel.relation == "_under") return el.under(rel.element);
	}
	return el;
}
Sahi.prototype._sfl_executeFn = function(el, fnName){
	return el.executeFn.apply(el, this.getArgsAr(arguments, 1));
}
Sahi.prototype._sfl_set = function(el, key, value){
	return el.set(key, value);
}
Sahi.prototype._sfl_get = function(el, key){
	return el.get(key);
}
Sahi.prototype._sfl_listProperties = function(el, fn){
	return el.listProperties();
}
Sahi.prototype._sfl_introspect = function(el){
	return el.introspect();
}
Sahi.prototype._sfl_getGridData = function(el){
	return el.getGridData();
}
Sahi.prototype._sfl_getData = function(el){
	return el.getData();
}
Sahi.prototype._f = Sahi.prototype._flex;
Sahi.prototype.insideFlex = function(b){
	this.isInsideFlex = b; 
}
Sahi.prototype.setMyFlexId = function(uid){
	try {
		var o = this._embed(uid) || this._object(uid);
		//alert(uid + " " + o);
		if (!o) return null;
		var flexId = (!this.isBlankOrNull(o.id)) ? o.id : o.name;
		o._sahi_setFlexId(flexId);
	}catch(e){alert(e);}
}
