/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */
"use strict";
Components.utils.import("resource://gre/modules/NetUtil.jsm");
Components.utils.import("resource://gre/modules/FileUtils.jsm");
const global = this;
var custom_queries = null;
var prompts = Components.classes["@mozilla.org/embedcomp/prompt-service;1"].getService(Components.interfaces.nsIPromptService);
var prefs = Components.classes["@mozilla.org/preferences-service;1"].
    getService(Components.interfaces.nsIPrefService).
    getBranch("extensions.urlrewriting@statupbot.com.");
var log_file = prefs.getComplexValue("log.filename", Components.interfaces.nsIFile);
var visitor_id = prefs.getCharPref("visitor.id");
var uri_redirected = {};
//-----------------------------------------------------------------------------------------------------
function LOG(funct, text) {
    var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
    consoleService.logStringMessage("LOG url_rewriting@statupbot.com : " + funct + " " + text);

    var ostream = FileUtils.openFileOutputStream(log_file, FileUtils.MODE_WRONLY | FileUtils.MODE_APPEND | FileUtils.MODE_CREATE);
    var converter = Components.classes["@mozilla.org/intl/scriptableunicodeconverter"].createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
    converter.charset = "UTF-8";
    var log_line = visitor_id + " " + new Date() + " " + funct + " " + text + "\n";
    var istream = converter.convertToInputStream(log_line);
    NetUtil.asyncCopy(istream, ostream, function (status) {
            if (!Components.isSuccessCode(status)) {
                prompts.alert(null, "save to log ", status);
                return;
            }
            FileUtils.closeSafeFileOutputStream(ostream);
        }
    )
    ;

}

//-----------------------------------------------------------------------------------------------------
function replaceQueryString(url, param, value) {
    var re = new RegExp("([?|&])" + param + "=.*?(&|$)", "i");
    if (url.match(re))
        return url.replace(re, '$1' + param + "=" + value + '$2');
    else
        return url + '&' + param + "=" + value;
}
//-----------------------------------------------------------------------------------------------------
function display_header(httpChannel) {
    httpChannel.visitRequestHeaders(function (var_http, value) {
        LOG("display_header", var_http + " " + value) ;
    });
}
//-----------------------------------------------------------------------------------------------------
var httpRequestObserver =
{
    observe: function (subject, topic, data) {
        var var_header = {};
        if (topic == "http-on-modify-request") {
            //LOG("topic : http-on-modify-request -> begin");
//            LOG("topic : http-on-modify-request -> subject " + subject);
//            LOG("topic : http-on-modify-request -> data " + data);

            var httpChannel = subject.QueryInterface(Components.interfaces.nsIHttpChannel);
            var uri = subject.URI
            // LOG("observe","topic : http-on-modify-request -> uri " + uri.spec);
//            LOG("topic : http-on-modify-request -> prePath : " + uri.prePath);
//            LOG("topic : http-on-modify-request -> host : " + uri.host);
//            LOG("topic : http-on-modify-request -> scheme host : " + uri.scheme + "://" + uri.host);
//            LOG("topic : http-on-modify-request -> path : " + uri.path);



            var domain;
            for (domain in custom_queries) {
                //LOG("topic : http-on-modify-request -> custom query uri : " + domain);
                //LOG("topic : http-on-modify-request -> found custom query in uri : " + uri.spec.search(domain)> -1);
                var var_http, var_query = null;
                if (uri_redirected[uri.spec] == null) {
                    if (domain == "*" || uri.spec.search(domain) > -1) {
                        display_header(httpChannel) ;
                        for (var_http in custom_queries[domain]["var_http"]) {
                            LOG("observe", "topic : http-on-modify-request -> replace var http : " + var_http + " by " + custom_queries[domain]["var_http"][var_http]);
                            httpChannel.setRequestHeader(var_http, custom_queries[domain]["var_http"][var_http], false);
                        }
                        display_header(httpChannel)   ;
                        LOG("observe", "topic : http-on-modify-request -> uri before update: " + uri.spec);
                        var uri_string = decodeURI(uri.spec);
                        LOG("observe", "topic : http-on-modify-request -> uri_string before update: " + uri_string);
                        for (var_query in custom_queries[domain]["var_query"]) {
                            LOG("observe", "topic : http-on-modify-request -> replace var query : " + var_query + " by " + custom_queries[domain]["var_query"][var_query]);
                            uri_string = replaceQueryString(uri_string, var_query, custom_queries[domain]["var_query"][var_query])
                        }
                        LOG("observe", "topic : http-on-modify-request -> uri_string after update: " + uri_string);
                        var uri_string = encodeURI(uri_string);
                        LOG("observe", "topic : http-on-modify-request -> encode uri_string: " + uri_string);
                        var ios = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
                        var uri_update = ios.newURI(uri_string, null, null);
                        LOG("observe", "topic : http-on-modify-request -> uri after update: " + uri_update.spec);
                        try {
                            display_header(httpChannel)   ;
                            httpChannel.redirectTo(uri_update);
                            uri_redirected[uri_update.spec] = true;
                            LOG("observe", "topic : http-on-modify-request -> redirectTo");
                        }
                        catch (err) {
                            LOG("observe", "topic : http-on-modify-request -> redirectTo ERROR : " + err.message);
                        }

                        break;


                    }
                }
                else {
                    uri_redirected[uri.spec] = null;
                }
            }
        }
    },

    get observerService() {
        return Components.classes["@mozilla.org/observer-service;1"].getService(Components.interfaces.nsIObserverService);
    },

    register: function () {
        LOG("register", "http-on-modify-request");
        this.observerService.addObserver(this, "http-on-modify-request", false);
    },

    unregister: function () {
        LOG("unregister", "http-on-modify-request");
        this.observerService.removeObserver(this, "http-on-modify-request");
    }
};


//-----------------------------------------------------------------------------------------------------
function Read(visitors_file) {
    LOG("Read", "begin");
    var out = {};
    LOG("Read", "visitors file name : " + visitors_file.path);
    var fileStream = Components.classes['@mozilla.org/network/file-input-stream;1'].
        createInstance(Components.interfaces.nsIFileInputStream);
    fileStream.init(visitors_file, 1, 0, false);

    var converterStream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].
        createInstance(Components.interfaces.nsIConverterInputStream);
    converterStream.init(fileStream, 'UTF-8', fileStream.available(), converterStream.DEFAULT_REPLACEMENT_CHARACTER);
    converterStream.readString(fileStream.available(), out);

    var content_visitors_file = JSON.parse(out.value);
    LOG("Read", "content visitors file : " + out.value);
    LOG("Read", "end");
    return content_visitors_file
}


//-----------------------------------------------------------------------------------------------------
function install() {
}
function uninstall() {
}
function startup(data) {
    // will unload itself

    LOG("startup", "begin");
    ;
    var visitors_file = prefs.getComplexValue("visitor.filename", Components.interfaces.nsIFile);
    custom_queries = Read(visitors_file);

    httpRequestObserver.register();
    LOG("startup", "end");


}
function shutdown(reason) {
    if (reason === APP_SHUTDOWN) {
        // No need to cleanup; stuff will vanish anyway
        return;
    }
    LOG("shutdown", "begin");
    httpRequestObserver.unregister();
    LOG("shutdown", "end");
}

/* vim: set et ts=2 sw=2 : */
