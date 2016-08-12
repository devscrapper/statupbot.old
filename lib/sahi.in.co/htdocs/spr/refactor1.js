var refactorWin = null;
var optionsStore = null;
var paramStore = null;

Ext.onReady(function() {
	
	Ext.ns('Ext.ux.grid');

	Ext.ux.grid.CheckColumn = function(config){
	    Ext.apply(this, config);
	    if(!this.id){
	        this.id = Ext.id();
	    }
	    this.renderer = this.renderer.createDelegate(this);
	};
	
	Ext.ux.grid.CheckColumn.prototype ={
	    init : function(grid){
	        this.grid = grid;
	        this.grid.on('render', function(){
	            var view = this.grid.getView();
	            view.mainBody.on('mousedown', this.onMouseDown, this);
	        }, this);
	    },
	
	    onMouseDown : function(e, t){
	        if(t.className && t.className.indexOf('x-grid3-cc-'+this.id) != -1){
	            e.stopEvent();
	            var index = this.grid.getView().findRowIndex(t);
	            var record = this.grid.store.getAt(index);
	            record.set(this.dataIndex, !record.data[this.dataIndex]);
	        }
	    },
	
	    renderer : function(v, p, record){
	        p.css += ' x-grid3-check-col-td'; 
	        return '<div class="x-grid3-check-col'+(v?'-on':'')+' x-grid3-cc-'+this.id+'">&#160;</div>';
	    }
	};
	
	// register ptype
	Ext.preg('checkcolumn', Ext.ux.grid.CheckColumn);
	
	// backwards compat
	Ext.grid.CheckColumn = Ext.ux.grid.CheckColumn;

	var fm = Ext.form;
	
	var checkedColumn =  new Ext.grid.CheckColumn({
       header: '&nbsp;',
       dataIndex: 'checked',
       width: 20
    });
    
    var optionsCM = new Ext.grid.ColumnModel([
        checkedColumn,
        {
           id: 'original',
           header: 'HTML Element',
           dataIndex: 'original',
           width: 200,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: 'Variable',
           dataIndex: 'replacement',
           width: 200,
           editor: new fm.TextField({
               allowBlank: false
           })
        }
    ]);
	
    optionsStore = new Ext.data.SimpleStore({
        fields: [['checked', 'original', 'replacement']],
		data: []
    });
	
	var checkedColumn =  new Ext.grid.CheckColumn({
       header: '&nbsp;',
       dataIndex: 'checked',
       width: 20
    });
    
    var paramCM = new Ext.grid.ColumnModel([
        checkedColumn,
        {
           id: 'original',
           header: 'Parameter Name',
           dataIndex: 'original',
           width: 200,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: 'Variable',
           dataIndex: 'replacement',
           width: 200,
           editor: new fm.TextField({
               allowBlank: false
           })
        }
    ]);
	
    paramStore = new Ext.data.SimpleStore({
        fields: [['checked', 'original', 'replacement']],
        data:[]
    });
    
	var paramGrid = new Ext.grid.EditorGridPanel({
        store: paramStore,
        cm: paramCM,
        width: '100%',
        height: 200,
        title: 'Parameters',
        frame: true,
        plugins: checkedColumn,
        clicksToEdit: 1
	});
	
	var optionsGrid = new Ext.grid.EditorGridPanel({
        store: optionsStore,
        cm: optionsCM,
        width: '100%',
        height: 200,
        title: 'Options',
        frame: true,
        plugins: checkedColumn,
        clicksToEdit: 1
	});
	
	var formPanelRight = new Ext.Panel({
		region     : 'east',
		bodyStyle  : 'padding: 10px; background-color: #DFE8F6',
		width      : '50%',
		items      : [{
			xtype: 'form',
			labelWidth : 100,
			frame: true,
			items: [{
				xtype: 'textfield',
				id: 'functionName',
				width: 250,
				fieldLabel: '<b>Function Name</b>',
				value: ''
			}]
		},
			optionsGrid
		,   
			paramGrid
		],   
		buttons    : [{
				text    : '<b>Preview</b>',
				handler : function() {
					showPreview();
				}
			}]	
	});	
	
	var formPanelLeft = new Ext.Panel({
		region     : 'center',
		bodyStyle  : 'padding: 10px; background-color: #DFE8F6',
		width      : '50%',
		items      : [{
			xtype: 'textarea',
			id: 'scriptText',
			value: '',
			width: '100%',
			height: '100%'
		}],
		buttons  : [{
				text    : '<b>Refactor</b>',
				handler : function() {
					refactor();
				}
			}]
	});
	
	var displayPanel = new Ext.Panel({
		width    : '100%',
		height   : 500,
		layout   : 'border',
		renderTo : 'panel',
		items    : [
			formPanelLeft,
			formPanelRight
		]
	});
});

function showPopup(script){
	if(!refactorWin){
		refactorWin = new Ext.Window({
        applyTo:'refactor-win',
        layout:'fit',
        width:600,
        height:500,
        modal:true,
        closeAction:'hide',
        items: [{
        	xtype: 'textarea',
        	id: 'refactor-textarea',
        	width: 600,
        	height: 500
        }],
        buttons: [{
	             	text: 'Apply',
	             	handler: function(){
	             		Ext.getCmp("scriptText").setValue(Ext.getCmp("refactor-textarea").getValue());
	             		refactorWin.hide();
	             	}
	             },{
	                text: 'Close',
	                handler: function(){
	            	 	refactorWin.hide();
	                }
	             }]
			});
	}
	refactorWin.show();
	var refactorTextarea = Ext.getCmp("refactor-textarea");
	if(refactorTextarea && script){
		refactorTextarea.setValue(script);
	}
}

function getSelectedText(){
	var textarea = $("scriptText");
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var sel = textarea.value.substring(start, end);
	return sel;
}
function $(id){
	return Ext.getCmp(id).el.dom;
}
function toggleParam(id){
	g_params[id]["enabled"] = !g_params[id]["enabled"];
}
function toggleObject(id){
	g_objects[id]["enabled"] = !g_objects[id]["enabled"];
}
function showPreview(){
	var parameters = "";
	var fnName = $("functionName").value;
	if (fnName == "") fnName = "fnXXX";
	for (var i=0; i<g_params.length; i++){
		if (!g_params[i]["enabled"]) continue;
		if (i != 0) parameters += ", ";
		parameters += g_params[i]["replacement"];
	}
	var s = "function " + fnName + "(" + parameters + "){\n";
	var content = g_currentSelection;
	for (var i=0; i<g_params.length; i++){
		if (!g_params[i]["enabled"]) continue;
		var o = g_params[i]["original"];
		var r = g_params[i]["replacement"];
		if (o == r) continue;
		while (content.indexOf(o) != -1)
			content = content.replace(o, r);
	}
	for (var i=0; i<g_objects.length; i++){
		if (!g_objects[i]["enabled"]) continue;
		var o = g_objects[i]["original"];
		var r = g_objects[i]["replacement"];
		if (o == r) continue;
		while (content.indexOf(o) != -1)
			content = content.replace(o, r);

	}
	s += "\t" + content.replace(/\n/g, '\n\t');
	s += "\n}\n";

	var argToPass = "";
	for (var i=0; i<g_params.length; i++){
		if (!g_params[i]["enabled"]) continue;
		if (i != 0) argToPass += ", ";
		argToPass += g_params[i]["original"];
	}
		
	var fnCall = fnName + "(" + argToPass + ");\n";

	var output = s + "\n" + $("scriptText").value.replace(g_currentSelection, fnCall);
	showPopup(output);
}
var g_currentSelection = "";
var g_params = [];
var g_objects = [];
function refactor(){
	var content = getSelectedText();
	g_currentSelection = content;
	g_params = [];
	g_objects = [];	
	var lines = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split("\n");
	optionsStore.removeAll();
	paramStore.removeAll();
	$("functionName").value = "";
	var sbParams = [];
	var duplicates = new Object();
	for (var i=0; i<lines.length; i++){
		var line = lines[i];
		if (line == "") continue;
		var lineData = new LineData(line);
		var params = lineData.params;

		for (var j=0; j<params.length; j++){
			var param = params[j];
			if (duplicates[param]) continue;
			duplicates[param] = param;
			var firstChar = param.charAt(0);
			if (firstChar == '"' || firstChar == '/' || firstChar == "'" || (firstChar == '$' && param.indexOf("$_") != 0)){
				var id = g_params.length;
				var variable = makeParameter(param);
				g_params[id] = {original:param, replacement: variable, enabled:true};
				addHTMLElement(param, variable, true);
			} else {
				var id = g_objects.length;
				var constant = makeConstant(param);
				g_objects[id] = {original:param, replacement: constant, enabled:true};
				addFunctionParameter(param, constant, true);
			}
		}		
	}
}
function addHTMLElement(original, replacement, checked){
	var Record = paramStore.recordType;
	var rec= new Record({
	   	checked: checked,
	   	original: original,
	   	replacement: replacement
	});
	paramStore.insert(paramStore.getCount(), rec);	
}
function addFunctionParameter(original, replacement, checked){
	var Record = optionsStore.recordType;
	var rec= new Record({
	   	checked: checked,
	   	original: original,
	   	replacement: replacement
	});
	optionsStore.insert(optionsStore.getCount(), rec);	
}
function makeParameter(s){
	if (s.charAt(0) == '$') return s;
	return "$" + s.replace(/_/g, '').replace(/_/g, '').replace(/[ \(\)\[\]"\-\/]/g, '_').replace(/_+/g, '_').replace(/^_/, '').replace(/_$/, '');
}
function makeConstant(s){
	if (s.charAt(0) == '$') return s;
	return "$_" + s.toUpperCase().replace(/_/g, '').replace(/[ \(\)\[\]"\-\/]/g, '_').replace(/_+/g, '_').replace(/^_/, '').replace(/_$/, '');
}
function LineData(line){
	this.line = line;
	this.parse();
}
LineData.prototype.parse = function(){
	var o = new Parser(this.line).parse();
	this.action = o.action;
	this.params = o.params;
}
function Parser(line){
	this.line = this.trim(line);
}
Parser.prototype.parse = function(){
	var startBracket = this.findNext("(");
	var endBracket = this.findNext(")", startBracket+1);
	var paramsStr = this.line.substring(startBracket+1, endBracket);
	var params = [];
	var tempStartIx = 0;
	var paramsParser = new Parser(paramsStr);
	var j=0;
	while (j++ < 10){
		var tempEndIx = paramsParser.findNext(",", tempStartIx);
		if (tempEndIx != -1){
			params[params.length] = this.trim(paramsStr.substring(tempStartIx, tempEndIx));
			tempStartIx = tempEndIx + 1;
		} else {
			params[params.length] = this.trim(paramsStr.substring(tempStartIx));
			break;
		}
	}
	var action = this.line.substring(0, startBracket);
	return {action:action, params:params};
}
Parser.prototype.trim = function(s){
	return s.replace(/^[\r\n\s]*/, '').replace(/[\r\n\s]*$/, '');
}
Parser.prototype.findNext = function(charToFind, startIx){
	var c = ' ';
	var isVar = false;
	var escaped = false;
	var doubleQuoted = false;
	var quoted = false;
	var len = this.line.length;
	var bracket = 0;
	var square = 0;
	if (!startIx) startIx = 0;
	for (var i=startIx; i<len; i++){
		c = this.line[i];
		if (c == charToFind && !escaped && !quoted && !doubleQuoted && square == 0 && bracket == 0){
			return i;
		}
		if (c == '\\') {
			escaped = !escaped;
		} else if (c == '"') {
			if (!(escaped || quoted)) {
				doubleQuoted = !doubleQuoted;
			}
		} else if (c == "'") {
			if (!(escaped || doubleQuoted)) {
				quoted = !quoted;
			}
		} else if (c == '['){
			if (!(escaped || quoted || doubleQuoted)) {
				square++;
			}			
		} else if (c == ']'){
			if (!(escaped || quoted || doubleQuoted)) {
				square--;
			}			
		} else if (c == '('){
			if (!(escaped || quoted || doubleQuoted)) {
				bracket++;
			}			
		} else if (c == ')'){
			if (!(escaped || quoted || doubleQuoted)) {
				bracket--;
			}			
		}
		if (c != '\\') {
			escaped = false;
		}
	}
	return -1;		
}

var _selectedScriptDir = null;
var _selectedScript = null;
var _scriptDirList = null;
var _scriptFileList = null;

function loadScript(){
	var dir = _selectedScriptDir;
	var file = $("filebox").value;
	if(dir && file){
		var textFile = sahiSendToServer("/_s_/dyn/Player_getScript?dir="+dir+"&file="+file);
		Ext.getCmp("scriptText").setValue(textFile);
	}
}

function populateOptions(el, opts, selectedOpt, defaultOpt, prefix) {
    el.options.length = 0;
    if (defaultOpt) {
        el.options[0] = new Option(defaultOpt, "");
    }
    var len = opts.length;
    for (var i = 0; i < len; i++) {
        var ix = el.options.length;
        if (prefix) {
            if (opts[i].indexOf(prefix) == 0) {
                el.options[ix] = new Option(opts[i].substring(prefix.length), opts[i]);
                if (opts[i] == selectedOpt) el.options[ix].selected = true;
            }
        } else {
            el.options[ix] = new Option(opts[i], opts[i]);
            if (opts[i] == selectedOpt) el.options[ix].selected = true;
        }
    }
}

function getScriptFiles(str){
    var options = [];
    var fileList = null;
    fileList = _scriptFileList;
    if(!str) str="";
    var fileName = "";
    if(fileList){
    	for (var i=0; i<fileList.length; i++){
    		fileName = fileList[i].replace(_selectedScriptDir, ""); 
        	if (fileName.indexOf(str) != -1)
            	options[options.length] = new Option(fileName, fileName);
    	}
    }
    return options;
}

function populateScripts(dir) {
	_scriptFileList = refreshScriptListFile(dir);
	setSelectedScriptDir(dir);
	$('filebox').value = "";
}

function setSelectedScriptDir(s) {
    _selectedScriptDir = s;
}

function setSelectedScript(s) {
    _selectedScript = s;
}

function refreshScriptListDir(){
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptDirsListJSON") + ")");
}

function refreshScriptListFile(dir){
	return eval("(" + sahiSendToServer("/_s_/dyn/ControllerUI_scriptsListJSON?dir="+dir) + ")");
}

