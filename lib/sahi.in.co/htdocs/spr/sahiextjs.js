/**
 * Copyright Tyto Software Pvt. Ltd.
 */
var SahiExtjs = function(){};
SahiExtjs.prototype.getGridCell = function(rowEntity, colEntity){
    return _sahi._cell(_sahi._cell(colEntity).cellIndex, _sahi._in(_sahi._parentRow(_sahi._cell(rowEntity))));
}

SahiExtjs.prototype.getGridHeaderSortMenu = function(headerName){
    return _sahi._link(0, _sahi._in(_sahi._cell(headerName)));
}
SahiExtjs.prototype.findButton = function(headerName, className){
    var nodes = _sahi._spandiv(headerName).parentNode.childNodes;
    for (var i=0; i<nodes.length; i++){
    	var node = nodes[i]; 
    	if (node == null) continue;
    	if (node.className.indexOf(className) != -1) return node;
    }
    return null;
}
SahiExtjs.prototype.closeButton = function(headerName){
	return this.findButton(headerName, "x-tool-close");
}
SahiExtjs.prototype.maximizeButton = function(headerName){
	return this.findButton(headerName, "x-tool-maximize");
}
SahiExtjs.prototype.minimizeButton = function(headerName){
	return this.findButton(headerName, "x-tool-minimize");
}
SahiExtjs.prototype.restoreButton = function(headerName){
	return this.findButton(headerName, "x-tool-restore");
}
_extjs = new SahiExtjs();
