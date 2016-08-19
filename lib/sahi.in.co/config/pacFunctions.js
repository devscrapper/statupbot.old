/**
 * In Internet Explorer, the support for shell expressions is limited to "?" and
 * "*" in the expressions. This is by design.
 * https://support.microsoft.com/en-us/kb/274204/ 
 * shexp can be *.example.com
 */
function shExpMatch(str, shexpr) {
	shexpr = "^" + shexpr.replace(/[.]/g, '[.]').replace(/[?]/g, '.').replace(/[*]/g, '.*') + "$";
	return str.match(new RegExp(shexpr)) != null;
}

function dnsResolve(host) {
	try {
		return java.net.InetAddress.getByName(host).getHostAddress();
	} catch (e) {
		// Not resolvable.
	}
	return "";
}

function isResolvable(host) {
	try {
		java.net.InetAddress.getByName(host).getHostAddress();
		return true;
	} catch (e) {
		// Not resolvable
	}
	return false;
}

function isInNet(host, pattern, mask) {
	try {
		var InetAddress = java.net.InetAddress;
		var hostAd = InetAddress.getByName(host).getAddress();
		var maskAd = InetAddress.getByName(mask).getAddress();
		
		var patternAd = InetAddress.getByName(pattern).getAddress();
		for (var i=0; i<hostAd.length; i++) {
			hostAd[i] &= maskAd[i];
			if (hostAd[i] != patternAd[i]) return false;
		}
		return true;	
	} catch (e) {}
	return false;
}

function dnsDomainIs(host, domain) {
	return host.endsWith(domain);
}
function localHostOrDomainIs(host, domain) {
	return domain.startsWith(host);
}

function isPlainHostName(host) {
	return host.indexOf(".") < 0;
}

function myIpAddress() {
	try {
		return "" + java.net.InetAddress.getLocalHost().getHostAddress();
	} catch (e) {
		return "";
	}
}

function dnsDomainLevels(host) {
	var count = 0;
	var startPos = 0;
	while ((startPos = host.indexOf(".", startPos + 1)) > -1) {
		count++;
	}
	return count;
}
// Utility Function
String.prototype.endsWith = function(suffix) {
	return this.indexOf(suffix, this.length - suffix.length) !== -1;
}