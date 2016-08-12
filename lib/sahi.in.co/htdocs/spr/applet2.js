/** Applet start **/
//_setValue(_applet("GuiExample").textfield("textfield0"), "abcd");
oracleJars = new Array("fndaol.jar","fndaolj.jar","fndbalishare.jar","fndctx.jar","fndewt.jar","fndforms.jar","fndformsi18n.jar","fndlist.jar","fndlist.jar","fndswing.jar","fndutil.jar","fndxmlparserv2.jar","frmall.jar");
Sahi.prototype.isApplet = function(el){
	try {return el.isApplet;}
	catch(e){return false;}
}
Sahi.prototype._applet = function(appletName){
	return this._a(appletName);
}
Sahi.prototype._a = function(appletName){
	var applet = this.appletsMap[appletName];
	if (!applet) this.addSahiAppletTag();
	return new SahiApplet(appletName, applet);
}

var SahiApplet = function(appletName, sahiApplet){
	this.appletName = appletName;
	this.sahiApplet = sahiApplet;
	this.isApplet = true;
	this.json = [];
}
SahiApplet.prototype.identifyParent = function() {
	this.sahiApplet.identifyParent(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.identifySelf = function() {
	this.sahiApplet.identifySelf(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.fetch = function(attribute) {
	return this.sahiApplet.fetch(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json}, attribute);
}
SahiApplet.prototype.printComponent = function() {
	return this.sahiApplet.printComponent(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.introspect = function() {
	return this.sahiApplet.introspect(this.appletName);
} 
SahiApplet.prototype.addSahiListeners = function(elName) {
	return this.sahiApplet.addSahiListeners(this.appletName);
} 
SahiApplet.prototype.click = function() {
	return this.sahiApplet.clickElement(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.exists = function() {
	return this.sahiApplet.exists(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.setSelected = function(val) {
	return this.sahiApplet.setSelected(this.appletName, {name: this.name, className: this.className, value: val, relationLength: this.json.length,relations: this.json});
}
SahiApplet.prototype.getText = function() {
	return this.sahiApplet.getText(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length,relations: this.json});
}
SahiApplet.prototype.getValue = function() { //Only for JTextComponent
	return this.sahiApplet.getValue(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length,relations: this.json});
}
SahiApplet.prototype.setValue = function(val) {
	return this.sahiApplet.setValue(this.appletName, {name: this.name, className: this.className, value: val, relationLength: this.json.length,relations: this.json});
} 
SahiApplet.prototype.listAll = function(val) {
	return this.sahiApplet.getAppletNames();
}
SahiApplet.prototype.highlight = function() {
	return this.sahiApplet.highlight(this.appletName, {name: this.name, className: this.className, relationLength: this.json.length, relations: this.json});
}
SahiApplet.prototype.inside = function(el) {
	this.json.push({relation: "_in", element: {className: el.className, name: el.name, relationLength: el.json.length, relations: el.json}});
	return this;
}
SahiApplet.prototype.near = function(el) {
	this.json.push({relation: "_near", element: {className: el.className, name: el.name, relationLength: el.json.length, relations: el.json}});
	return this;
}
SahiApplet.prototype.under = function(el, xOffset, yOffset) {
	if(!yOffset) yOffset = xOffset;
	this.json.push({relation: "_under", element: {className: el.className, name: el.name, relationLength: el.json.length, relations: el.json}, xOffset: xOffset, yOffset: yOffset});
	return this;
}
SahiApplet.prototype.rightOf = function(el, xOffset, yOffset) {
	if(!yOffset) yOffset = xOffset;
	this.json.push({relation: "_rightOf", element: {className: el.className, name: el.name, relationLength: el.json.length, relations: el.json}, xOffset: xOffset, yOffset: yOffset});
	return this;
}
SahiApplet.prototype.leftOf = function(el, xOffset, yOffset) {
	if(!yOffset) yOffset = xOffset;
	this.json.push({relation: "_leftOf", element: {className: el.className, name: el.name, relationLength: el.json.length, relations: el.json}, xOffset: xOffset, yOffset: yOffset});
	return this;
}
SahiApplet.appMetadata = new Array();
SahiApplet.prototype.addMetaData = function(metadata) {
	SahiApplet.appMetadata.push(metadata);
	if (!metadata.apiName) metadata.apiName = this.getAccessorAPIName(metadata.qn);
	SahiApplet.prototype[metadata.apiName] = function(elName) {
		if (typeof elName == "number") {
			this.name = "_sahi_null_[" + elName + "]";
		} else { 
			this.name = elName;
		}
		this.className = metadata.qn;
		return this;
	}
	return this;	
}
SahiApplet.prototype.addAllMetaData = function() {
//	this.addMetaData({qn: "java.awt.TextField", attributes: ["Name", "Text", "Index"], action: "setValue", value: "Text"});
//	this.addMetaData({qn: "java.awt.Button", attributes: ["Name", "Text", "Index"], action: "click", value: "Text"});
//	this.addMetaData({qn: "javax.swing.JScrollBar", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Text", type: "scroll"});
	for(var i=0; i<_sahi.accessors_applet_metadata.length; i++){
		var accessors_metadata = _sahi.accessors_applet_metadata[i];
		this.addMetaData(accessors_metadata);
	}
}
SahiApplet.prototype.getAccessorAPIName = function(qn){
	return qn.substring(qn.lastIndexOf(".")+1).toLowerCase();
}
SahiApplet.convertToFn = function(s){
	var o = (typeof s == "string") ? eval("(" + s + ")") : s;
	return '_a("' + o.objectId + '").' + o.api + '(' + _sahi.toJSON(o.args[0]) + ')';
}
SahiApplet.display = function(s){
	//_sahi._alert(_sahi.toJSON(s));
	var val = "";
	if (typeof _sahi == "object") {
		var ar = [s]; //eval("("+s+")");
		var alts = [];
		for (var i=0; i<ar.length; i++) {
			var item = ar[i];
			alts.push(SahiApplet.convertToFn(item));
		}
		_sahi.sendIdentifierInfo(alts, alts[0], ar[0].value, _sahi.getPopupDomainPrefixes(), []);
	}
}

Sahi.prototype.addAppletHandlers = function (sahiApplet) {
//	this._alert("In wait Until Ok" + this._byId("_sahi_applet"));
	try {
		if (sahiApplet != null && sahiApplet.isActive()) {
			for (var i=0; i<SahiApplet.appMetadata.length; i++) {
				var m = SahiApplet.appMetadata[i];
				sahiApplet.setMetadata(m.qn, m.attributes, m.action, m.value, m.type);
			}
			return;
		}
	} catch (e) {
		//throw e;
	}
	setTimeout(function(){_sahi.addAppletHandlers(sahiApplet)}, 1000);
}
Sahi.prototype.appletsMap = new Array();
Sahi.prototype.addAppletToAppletMap2 = function (applet) {
	try{
		var appletName = applet.getClass().getSimpleName();
		this.appletsMap[appletName] = applet;
		var allFramesNames = applet.getFrameNames();
		//this._alert("allFramesNames : " + allFramesNames);
		allFramesNames = eval("(" + allFramesNames + ")");
		for(var j=0; j<allFramesNames.length; j++){
			if(allFramesNames[j] != "SahiApplet")
				this.appletsMap[allFramesNames[j]] = applet;
		}
		new SahiApplet(appletName).addAllMetaData();
		this.addAppletHandlers(applet);
	} catch (e) {
		//throw e;
		setTimeout(function(){_sahi.addAppletToAppletMap2(applet);}, 1000);
	}
}

SahiApplet.prototype.getFrameNames = function () {
	return this.sahiApplet.getFrameNames();
}
Sahi.prototype.addSahiAppletTag = function () {
	this.addSahiAppletTagInList(document.getElementsByTagName("object"));
	this.addSahiAppletTagInList(document.getElementsByTagName("applet"));
	this.addSahiAppletTagInList(document.getElementsByTagName("embed"));
	if (this.appletFindTimer) window.clearTimeout(this.appletFindTimer);
	this.appletFindTimer = setTimeout(function(){_sahi.addSahiAppletTag();}, 5000);
}
Sahi.prototype.addSahiAppletTagInList = function(appletTags) {
	try{
		var len = appletTags.length;
		for(var i=0; i<len; i++){
			var applet = appletTags[i];
			try{
				var appletClass = applet.getClass();
				if (appletClass != null) {
					var appletName = appletClass.getSimpleName();
					if(applet.id.indexOf("sahiApplet") != -1) continue;
					this.addAppletToAppletMap2(applet);
				}
			} catch(e){}
		}
	} catch(e){}
}
_sahi.appletFindTimer = setTimeout(function(){_sahi.addSahiAppletTag();}, 5000);
/** Applet end **/