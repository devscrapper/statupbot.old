/**
 * Copyright Tyto Software Pvt. Ltd.
 */
function sahiCreateCookie(name, value, days, path, domain, secure)
{
    var expires = "";
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    }
    var s = name + "=" + value + expires;
    s += "; path=" + (path ? path : "/");
    if (domain) s += "; domain=" + domain;
    if (secure) s += "; secure=" + secure;
    window.document.cookie = s;
}

function sahiReadCookie(name)
{
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++)
	{
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function sahiEraseCookie(name)
{
	sahiCreateCookie(name,"",-1);
}
