/**
 * Copyright Tyto Software Pvt. Ltd.
 */
(function(){
	if (typeof window.dialogArguments != 'undefined') {
		return; // for modal.
	}
	var d = document.domain;
	//alert("$domainInfo");
	var info = $domainInfo;
	if (d){
		for (var k in info) {
			if (new RegExp(k).test(d)) {
				window.document.domain = info[k];
				break;
			} 
		}
	}
})();
__sahiDebug__("domainfix.js: end");