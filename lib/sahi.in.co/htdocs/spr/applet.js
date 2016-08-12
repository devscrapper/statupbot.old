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
	return new SahiApplet(appletName, this.appletsMap[appletName]);
}

var SahiApplet = function(appletName, sahiapplet){
	this.appletName = appletName;
	this.sahiApplet = sahiapplet;
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
	//Abstract Button
	this.addMetaData({qn: "javax.swing.JButton", attributes: ["encaps_javax.swing.JComboBox", "Name", "Text", "Label"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JToggleButton", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JMenu", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JMenuItem", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JCheckBoxMenuItem", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JRadioButtonMenuItem", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JCheckBox", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
	this.addMetaData({qn: "javax.swing.JRadioButton", attributes: ["Name", "Text", "Label", "ToolTipText"], action: "click", value: "Text", type: "button"});
//	//JTextComponent
	this.addMetaData({qn: "javax.swing.JTextField", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Text", type: "text"});
	this.addMetaData({qn: "javax.swing.JTextArea", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Text", type: "text"});
	this.addMetaData({qn: "javax.swing.JPasswordField", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Text", type: "text"});
//	//others
	this.addMetaData({qn: "javax.swing.JComboBox", attributes: ["Name", "ToolTipText"], action: "setSelected", value: "SelectedItem", type: "combo"});
	this.addMetaData({qn: "javax.swing.JTabbedPane", attributes: ["Name", "ToolTipText"], action: "setSelected", value: "SelectedIndex", type: "pane"});
	this.addMetaData({qn: "javax.swing.JLabel", attributes: ["Name", "Text", "ToolTipText"], action: "setSelected", value: "Text", type: "label"});
	this.addMetaData({qn: "javax.swing.JPanel", attributes: ["Name"], action: "setSelected", value: "", type: "cont"});
	this.addMetaData({qn: "javax.swing.JSlider", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Value", type: "slider"});
//	this.addMetaData({qn: "javax.swing.JScrollBar", attributes: ["Name", "ToolTipText"], action: "setValue", value: "Text", type: "scroll"});
//	//AWT Componets
	this.addMetaData({qn: "java.awt.Button", attributes: ["Label", "Name"], action: "click", value: "Label", type: "button"});
	this.addMetaData({qn: "java.awt.TextField", attributes: ["Name"], action: "Value", value: "Text", type: "text"});
	this.addMetaData({qn: "java.awt.TextArea", attributes: ["Name"], action: "Value", value: "Text", type: "text"});
//	Oracle Form Components
	this.addMetaData({qn: "oracle.forms.ui.VButton", attributes: ["Label", "Name"], action: "click", value: "Label", type: "o_button"});
	this.addMetaData({qn: "oracle.ewt.lwAWT.LWLabel", attributes: ["Name", "Text"], action: "Value", value: "Text", type: "o_label"});
	this.addMetaData({qn: "oracle.forms.ui.VTextField", attributes: ["Name"], action: "Value", value: "Text", type: "o_text"});
	this.addMetaData({qn: "oracle.forms.ui.FLWTextArea", attributes: ["Name"], action: "Value", value: "Text", type: "o_text"});
	this.addMetaData({qn: "oracle.forms.ui.ExtendedCheckbox", attributes: ["Name", "Label"], action: "click", value: "State", type: "o_button"});
	this.addMetaData({qn: "oracle.apps.fnd.ui.Button", attributes: ["Label", "Name"], action: "click", value: "Label", type: "o_button"});
	this.addMetaData({qn: "oracle.ewt.lwAWT.LWScrollbar", attributes: ["Name"], action: "Value", value: "Value", type: "o_scroll"});
	this.addMetaData({qn: "oracle.forms.ui.FormsTabPanel", attributes: ["Name"], action: "setSelected", value: "", type: "o_pane"});
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
Sahi.prototype.getAllSahiApplets = function () {
	var applets = document.getElementsByTagName("applet");
	for(var i=0; i<applets.length; i++){
		if((applets[i].code == "in.co.sahi.applet.SahiApplet.class" || 
				applets[i].code == "in.co.sahi.applet.SahiAppletOracle.class" )){
			this.addAppletToAppletMap(applets[i]);
		}
	}
}
Sahi.prototype.addAppletToAppletMap = function (sahiApplet) {
	try{
		if(sahiApplet.isActive()){
			var userApplet = sahiApplet.nextSibling;
			//this._alert("userApplet : " + userApplet);
			if(typeof userApplet == "undefined"){
				var applets = document.applets;
				for(var i=0;i<applets.length;i++){
					//this._alert(">>> " + applets[0]);
					if(applets[i] == sahiApplet){
						userApplet = applets[i+1];
						break;
					}
				}
			}
			var userAppletName = userApplet.getClass().getSimpleName();
			//this._alert("userAppletName : " + userAppletName);
			this.appletsMap[userAppletName] = sahiApplet;
			var allFramesNames = sahiApplet.getFrameNames();
			//this._alert("allFramesNames : " + allFramesNames);
			allFramesNames = eval("(" + allFramesNames + ")");
			for(var j=0; j<allFramesNames.length; j++){
//		_sahi._alert(allFramesNames[j]);				
				if(allFramesNames[j] != "SahiApplet")
					this.appletsMap[allFramesNames[j]] = sahiApplet;
			}
			new SahiApplet(userAppletName).addAllMetaData();
			this.addAppletHandlers(sahiApplet);
		} else {
		setTimeout(function(){_sahi.addAppletToAppletMap(sahiApplet);}, 1000);
		}
	} catch (e) {
		//throw e;
		setTimeout(function(){_sahi.addAppletToAppletMap(sahiApplet);}, 1000);
	}
}
Sahi.prototype.addAppletToAppletMap2 = function (userApplet, sahiApplet) {
	try{
		var userAppletName = userApplet.getClass().getSimpleName();
		//this._alert("userAppletName : " + userAppletName);
		this.appletsMap[userAppletName] = sahiApplet;
		var allFramesNames = sahiApplet.getFrameNames();
		//this._alert("allFramesNames : " + allFramesNames);
		allFramesNames = eval("(" + allFramesNames + ")");
		for(var j=0; j<allFramesNames.length; j++){
			if(allFramesNames[j] != "SahiApplet")
				this.appletsMap[allFramesNames[j]] = sahiApplet;
		}
		new SahiApplet(userAppletName).addAllMetaData();
		this.addAppletHandlers(sahiApplet);
	} catch (e) {
		//throw e;
		setTimeout(function(){_sahi.addAppletToAppletMap2(userApplet, sahiApplet);}, 1000);
	}
}

SahiApplet.prototype.getFrameNames = function () {
	return this.sahiApplet.getFrameNames();
}
Sahi.prototype.addSahiAppletTag = function () {
	//this._alert("Adding Sahi Applet Tags");
	try{
		appletTags =  document.applets;
		var len = appletTags.length;
		for(var i=0; i<len; i++){
			var applet = appletTags[i];
			var appletName = applet.getClass().getSimpleName();
			if(applet.id.indexOf("sahiApplet") != -1 || this.appletsMap[appletName] != null) continue;
			var archiveFromAttribute = applet.archive;
//			this._alert("archiveFromAttribute : " + archiveFromAttribute);
			var codebaseFromAttribute = applet.codeBase;
//			this._alert("codebaseFromAttribute : " + codebaseFromAttribute);
			var codebaseFromParam = "";
			var archiveFromParam = "";
			if(appletTags[i].tagName.toUpperCase() == "OBJECT"){
				var params = appletTags[i].getElementsByTagName("param");
				for(var j=0;j<params.length;j++){
					var param = params[j];
					if(param.name.toUpperCase() == "ARCHIVE"){
						archiveFromParam = param.value;
					}
					if(param.name.toUpperCase() == "CODEBASE"){
						codebaseFromParam = param.value;
					}
				}
			}
//			this._alert("codebaseFromParam : " + codebaseFromParam);
//			this._alert("archiveFromParam : " + archiveFromParam) ;
			var archive = (archiveFromParam && archiveFromParam != "") ?  archiveFromParam : archiveFromAttribute;
//			this._alert("archive : " + archive);
			var codebase = (codebaseFromParam && codebaseFromParam != "") ?  codebaseFromParam : codebaseFromAttribute;
//			this._alert("codebase : " + codebase);
			var code = "in.co.sahi.applet.SahiApplet.class";		
			if(typeof archive != "undefined" && archive != ""){
				for(var k=0;k<oracleJars.length;k++){
					if(archive.indexOf(oracleJars[k]) != -1){
						code = "in.co.sahi.applet.SahiAppletOracle.class";
					}
				}
			}
//			this._alert("code : " + code);
			sahiAppletTag = "<applet code=\"" + code + "\" ";
			if(typeof codebase != "undefined" && codebase != ""){
				sahiAppletTag += "codebase=\"" + codebase + "\" ";
			}
			if(typeof archive != "undefined" && archive != ""){
				sahiAppletTag += "archive=\"" + archive +"\" ";
			}
			sahiAppletTag += "width=0 height=0 id=\"sahiApplet" + i + "\" MAYSCRIPT></applet>";
//			this._alert("sahiAppletTag " + sahiAppletTag);
//			this._alert("archive " + archive);
			var p = document.createElement("p");
			p.innerHTML = sahiAppletTag;
			document.body.appendChild(p);
			var sahiApplet = document.getElementById("sahiApplet"+i);
			this.addAppletToAppletMap2(appletTags[i], sahiApplet);
		}
	} catch(e){}
	setTimeout(function(){_sahi.addSahiAppletTag();}, 5000);
}
setTimeout(function(){_sahi.addSahiAppletTag();}, 5000);

//setTimeout(function(){_sahi.getAllSahiApplets();}, 1000);
//_sahi.getAllSahiApplets();
//new SahiApplet().addAllMetaData();
//setTimeout(function(){_sahi.addAppletHandlers()}, 1000);
//setInterval(function(){_sahi.getAppletIntoFocus()},1000);
//Sahi.prototype.getAppletIntoFocus = function(){
//	document.getElementById("sample").requestFocus();
//	_sahi._alert(document.getElementById("sample"));
//}
//_sahi.addAppletHandlers();
/** Applet end **/