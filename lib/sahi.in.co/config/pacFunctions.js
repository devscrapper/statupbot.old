/**
shexp can be *.example.com
*/
function shExpMatch(str, shexpr){
	shexpr = shexpr.replace(/[.]/g, '[.]').replace(/[*]/g, '[^.]*');
	return str.match(new RegExp(shexpr));
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
	var result = (host & mask) == pattern;
	return result;
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
			myIP = java.lang.System.getProperty(OVERRIDE_LOCAL_IP);
			if (myIP != null && myIP.trim().length() > 0) {
					return myIP.trim();
			}
			return java.net.InetAddress.getLocalHost().getHostAddress();
	} catch (e) {
			return "";
	}
}

function dnsDomainLevels(host) {
	count = 0;
	startPos = 0;
	while ((startPos = host.indexOf(".", startPos + 1)) > -1) {
			count++;
	}
	return count;
}
//Utility Function
String.prototype.endsWith = function(suffix) {
	return this.indexOf(suffix, this.length - suffix.length) !== -1;
}