/**
 * Copyright Tyto Software Pvt. Ltd.
 */
// you may add your custom global functions here
// uncomment line which includes extensions.js in config/inject_top.txt


//var trace = window.open().document;
//trace.write("title : " + window.document.title + "<br>");
//trace.write("opener : " + window.opener + "<br>");
//trace.write("location.href : " + window.location.href + "<br>");
//trace.write("referrer : " + window.document.referrer + "<br>");
//trace.write("history : " + window.history.entries + "<br>");

try {
    var r = Math.floor((Math.random() * 100) + 1);
    document.cookie = "username_" + r + "=" + window.location.href;

}
catch (e) {
    trace.write("Exception : " + e.message + "<br>");

}


function myFunction() {
    try {
        trace.write("link : " + window.document.links.length + "<br>");
    }
    catch (e) {
        trace.write("links Exception : " + e.message + "<br>");

    }
}
/* Pour IE 8 */
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g, '');
    }
}
if (!Array.indexOf) {
    Array.prototype.indexOf = function (obj) {
        for (var i = 0; i < this.length; i++) {
            if (this[i] == obj) {
                return i;
            }
        }
        return -1;
    }
}
/* fin pour IE 8 */

var Uri = function (str) {
    var uri = "",
        o = {
            strictMode: false,
            key: ["source", "protocol", "authority", "userInfo", "user", "password", "host", "port", "relative", "path", "directory", "file", "query", "anchor"],
            q: {
                name: "queryKey",
                parser: /(?:^|&)([^&=]*)=?([^&]*)/g
            },
            parser: {
                strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
                loose: /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
            }
        },
        m = o.parser[o.strictMode ? "strict" : "loose"].exec(str),
        uri = {},
        i = 14;

    while (i--) uri[o.key[i]] = m[i] || "";

    uri[o.q.name] = {};
    uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
        if ($1) uri[o.q.name][$1] = $2;
    });


    Uri.prototype.protocol = function () {
        return (uri["protocol"] || "").trim();
    };
    Uri.prototype.path = function () {
        return (uri["path"] || "").trim();
    };
    Uri.prototype.host = function () {
        return (uri["host"] || "").trim();
    };
    Uri.prototype.valid = function () {
        return uri["protocol"] != "" && uri["host"] != "" && uri["path"] != "";
    };
}

Sahi.prototype.current_page_details = function (with_links) {
    //trace = window.open().document;
    try {
        if (with_links == true) {
            return JSON.stringify({
                url: window.location.href,
                title: window.document.title,
                referrer: window.document.referrer,
                links: links_in_window(window),
                cookies: window.document.cookie
            });
        }
        else {
            return JSON.stringify({
                url: window.location.href,
                title: window.document.title,
                referrer: window.document.referrer,
                links: [],
                cookies: window.document.cookie
            });
        }

    }
    catch (e) {
        // trace.write("links Exception : " + e.message + "<br>");
        return e;
    }
};

Sahi.prototype.website_page_details = function () {
    //trace = window.open().document;
    try {

        return JSON.stringify({
            url: window.location.href,
            title: window.document.title,
            links: links_in_window(window)
            //   links: window.document.links
        });
    }
    catch (e) {
        // trace.write("links Exception : " + e.message + "<br>");
        return e;
    }
};

Sahi.prototype.go_back = function () {
    try {
        window.history.go(-1);
    }
    catch (e) {
        // trace.write("GoBack : " + e.message + "<br>");
    }
};

Sahi.prototype.links = function () {
    //trace = window.open().document;
    try {
        return JSON.stringify({links: links_in_window(window)});
    }
    catch (e) {
        // trace.write("links Exception : " + e.message + "<br>");
        return e;
    }
};

Sahi.prototype.current_url = function () {
    return window.location;
}

Sahi.prototype.referrer = function () {
    return window.document.referrer;
}


Sahi.prototype.open_start_page_ch = function (url, window_parameters) {
    window.open(url, "_self", window_parameters);
    //window.open(url, "defaultSahiPopup", window_parameters);
    //window.close();
}

Sahi.prototype.open_start_page_ie = function (url, window_parameters) {
    window.open(url, "_self", window_parameters);
}

Sahi.prototype.open_start_page_ff = function (url, window_parameters) {
    window.open(url, "_self", window_parameters);
}

Sahi.prototype.info = function () {
    return "title = " + window.document.title + " referrer = " + window.document.referrer + " history = " + window.history.entries;
}

Sahi.prototype.set_title = function (title) {
    // trace = window.open().document;
    // trace.write("set_title title : " + title + "<br>");
    try {
        // trace.write("set_title window.document.title B : " + window.document.title + "<br>");
        window.document.title = title;
        // trace.write("set_title window.document.title A : " + window.document.title + "<br>");
        return window.document.title;
    }
    catch (e) {
        // trace.write("set_title Exception : " + e.message + "<br>");
        return e;
    }
};

Sahi.prototype.setAttribute = function (a, b, c) {
    if (null == b)return null;
    if (null == c)return null;
    return  a.setAttribute(b, c)
};

Sahi.prototype.set_target = function (text_link, target) {
    //trace = window.open().document;
    //trace.write("set_target text_link : " + text_link + "<br>");
    //trace.write("set_target target : " + target + "<br>");
    try {
        // trace.write("set_title window.document.title B : " + window.document.title + "<br>");
        var arr_lnks = window.document.links;
        for (var i = 0; i < arr_lnks.length; i++) {
            //trace.write("set_target arr_lnks[i].textContent  : " + arr_lnks[i].textContent + " arr_lnks[i].target  : " + arr_lnks[i].target +  "<br>");
            // change le target de tous les liens dont le text = text_link, car si il y a plusieurs link portant le meme text
            //on ne sait pas sur quel link va clicker SAHI
            if (arr_lnks[i].textContent == text_link) {
                arr_lnks[i].target = target;
                //trace.write("TROUVE -------------------<br>");
                //trace.write("set_target arr_lnks[i].textContent  : " + arr_lnks[i].textContent + " arr_lnks[i].target  : " + arr_lnks[i].target +  "<br>");
                //trace.write("TROUVE -------------------<br>");
            }

        }
        //trace.write("after") ;
        //for (var i = 0; i < arr_lnks.length; i++) {
        //     trace.write("set_target arr_lnks[i].textContent  : " + arr_lnks[i].textContent + " arr_lnks[i].target  : " + arr_lnks[i].target +  "<br>");
        //}
    }
    catch (e) {
        //trace.write("set_target Exception : " + e.message + "<br>");
        return e;
    }
};

function links_in_window(w) {
    // trace.write("links_in_window debut<br>")
    try {
        var res = new Array(),
            arr_lnks = null;
        if (w !== undefined) {
            if (w.document !== undefined) {
                arr_lnks = links_in_document(w.document);
                for (var i = 0; i < arr_lnks.length; i++) {
                    if (is_selectable(arr_lnks[i], w.location)) {

                        res.push({
                            href: arr_lnks[i].href,
                            target: arr_lnks[i].target,
                            text: encodeURI(arr_lnks[i].textContent).replace("'", "&#44;")
                        });
                        // trace.write(arr_lnks[i].href + "<br>");
                    }
                }
                for (var j = 0; j < w.frames.length; j++) {
                    res = res.concat(this.links_in_window(w.frames[j]));
                }
            }
        }
    }
    catch (e) {
        // trace.write("links_in_window Exception " + e.message + "<br>");
    }
    // trace.write("links_in_window fin<br>")
    return res;
}
function links_in_document(d) {
    // trace.write("links_in_document debut<br>");
    var lnks = null;
    try {
        lnks = d.links;
    }
    catch (e) {
        // trace.write("links_in_document exception" + e.message + "<br>");
        lnks = new Array();
    }
    // trace.write("links_in_document fin<br>");
    return lnks;
}
function is_selectable(link, url_window) {
    var href = link.href,
        uri = new Uri(href),
        protocol = uri.protocol(),
        path = uri.path(),
        length = ".svg".length;

    return _sahi._isVisible(link) &&
        (protocol == "http" || protocol == "https") &&
        href != url_window &&
        uri.valid() == true &&
        link.textContent != "" &&
        (link.target == "_top" || link.target == "_parent" || link.target == "_self" || link.target == "") &&  //on exclue _blank et id car cela cree une nouvelle fenetre
        [".css", ".jsp", ".svg", ".gif", ".jpeg", ".jpg", ".png", ".pdf"].indexOf(path.substr(path.length - length - 1, length)) < 0
}