/**
 * This function is used to search divs or elements with entered text and hide
 * the rest. This enables a search functionality in a single page.
 * 
 * @author Vivek
 */
function searchApi() {
	var searchTerm = document.getElementsByName("api")[0].value;
	hideUnrelated();
	showResults(searchTerm);
}

function hideUnrelated() {
	var elements = new Array();
	elements = getElementsByClassName('api-sign');
	for (i in elements) {
		elements[i].style.display = "none";
	}
	var desc = new Array();
	desc = getElementsByClassName('api-desc');
	for (i in desc) {
		desc[i].style.display = "none";
	}
}

function getElementsByClassName(classname, node) {
	if (!node)
		node = document.getElementsByTagName("body")[0];
	var a = [];
	var re = new RegExp('\\b' + classname + '\\b');
	var els = node.getElementsByTagName("*");
	for ( var i = 0, j = els.length; i < j; i++)
		if (re.test(els[i].className))
			a.push(els[i]);
	return a;
}

function showResults(sTerm) {
	var elements = new Array();
	elements = getElementsByClassName('api-sign');
	var desc = new Array();
	desc = getElementsByClassName('api-desc');
	for (i = 0; i < elements.length; i++) {
		var html = elements[i].innerHTML;
		var text = html.replace(/<[^>]*>/g, "");
		if (text.toLowerCase().indexOf(sTerm.toLowerCase()) !== -1) {
			elements[i].style.display = "block";
			var apiClass = elements[i].className;
			var reqClass = apiClass.split();
			desc[i].style.display = "block";
			
		}
	}
	
	for (i = 0; i < desc.length; i++) {
		var html = desc[i].innerHTML;
		var text = html.replace(/<[^>]*>/g, "");
		if (text.toLowerCase().indexOf(sTerm.toLowerCase()) !== -1) {
			desc[i].style.display = "block";
			var apiClass = desc[i].className;
			var reqClass = apiClass.split();
			elements[i].style.display = "block";
		}
	}
	
	
}