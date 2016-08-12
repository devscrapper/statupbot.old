var editors = {};
function callOnCMEChange() {
	if (typeof onCMEChange != "undefined") {
		onCMEChange();
	}
}
function createCMEditor(taName, showLineNumbers) {
	editors[taName] = CodeMirror.fromTextArea(document.getElementById(taName),
			{
				lineNumbers : showLineNumbers,
				matchBrackets : true,
				mode : "javascript",
				extraKeys : {
					"Ctrl-Space" : function(cm) {
						CodeMirror.simpleHint(cm, CodeMirror.sahiHint);
					}
				}
			});
	editors[taName].refresh();
	if (editors[taName].on)
		editors[taName].on('change', callOnCMEChange);
}
function createXmlCMEditor(taName, showLineNumbers) {
	editors[taName] = CodeMirror.fromTextArea(document.getElementById(taName),
			{
				lineNumbers : showLineNumbers,
				matchBrackets : true,
				mode : "xml",
				readOnly: true
			});
}
function createTextCMEditor(taName, showLineNumbers) {
	editors[taName] = CodeMirror.fromTextArea(document.getElementById(taName),
			{
				lineNumbers : showLineNumbers,
				matchBrackets : true,
				mode : "text",
			});
}
function findInCME(id){
	if(editors[id]){
		CodeMirror.commands["find"](editors[id])
	}
}
function setValueInCME(id, value){
	if(editors[id]){
		editors[id].setValue(value);
		editors[id].clearHistory();
	}
}
function refreshInCME(id){
	if(editors[id]){
		editors[id].refresh();
		editors[id].clearHistory();
	}
}
// editor.setOption("theme", "eclipse");
function getEditorSelectionValue(id, defaultToFull, lineSep) {
	if (lineSep != "\r\n") lineSep = "\n";
	if (editors[id]) {
		var sel = editors[id].getSelection(lineSep);
		if (!sel && defaultToFull) sel = editors[id].getValue(lineSep);
		return sel;
	} else {
		return getSelectedText(id, defaultToFull);
	}
}
function storeTextAreaValueInEditor(id) {
	editors[id].setValue(document.getElementById(id).value);
}
function showEditors() {
	for ( var i in editors) {
		try {
			storeTextAreaValueInEditor(i);
		} catch (e) {
		}
	}
}
function setEditorValue(taName, s, clearHistory) {
	$(taName).value = s;
	if (editors[taName]){
		storeTextAreaValueInEditor(taName);
		if (clearHistory)
			editors[taName].clearHistory();
	}
}
function replaceEditorSelection(id, s) {
	if (editors[id]) {
		editors[id].replaceSelection(s);
	} else {
		$(id).value = s; // not inserting at selection.
	}
}
function getEditorValue(taName, lineSep) {
	if (lineSep != "\r\n") lineSep = "\n";
	if (editors[taName])
		return editors[taName].getValue(lineSep);
	return $(taName).value;
}
function getScroller(taName){
	if(editors[taName]) return editors[taName].getScrollerElement(); 
	return $(taName);
}
function getWrappper(taName){
	if(editors[taName]) return  editors[taName].getWrapperElement(); 
	return $(taName);
}
function getCurrentLineText(id) {
	if(editors[id]) {
		return (editors[id].getLine(editors[id].getCursor().line));
	}
	return "";
}
function getCurrentLineNumber(id) {
	if(editors[id]) {
		return (editors[id].getCursor().line);
	}
	return 0;
}
function replaceLineText(id, text, lineNo, lineLength) {
	if (editors[id]) {
		editors[id].replaceRange(text, {line:lineNo, ch:0}, {line:lineNo, ch:lineLength});
	}
}
function refreshCME(taName) {
	if(editors[taName]) {
		editors[taName].refresh();
	}
}
