/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

/*
 Cette extension capte les requetes sortantes pour les customiser avec le fichier de paramètrage visitor uuid.json localisé dans
 le répertoire statupbot\visitors
 */

"use strict";
Components.utils.import("resource://gre/modules/NetUtil.jsm");
Components.utils.import("resource://gre/modules/FileUtils.jsm");
Components.utils.import("chrome://tools/content/log.js");
Components.utils.import("chrome://tools/content/uri.js");

const SEP = "|";
/*
 Declarations Globales
 //       prompts.alert(null, "save to log ", status);
 */
var prompts = Components.classes["@mozilla.org/embedcomp/prompt-service;1"]. // permet d'afficher des popup
    getService(Components.interfaces.nsIPromptService);

var filePath = "D:\\referentiel\\dev\\statupbot\\doc\\liste_query.txt";
var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
var foStream = Components.classes["@mozilla.org/network/file-output-stream;1"].createInstance(Components.interfaces.nsIFileOutputStream);
/* function d'écoute des requetes émises et application du fichier de customisation du visitor
 input : L'objet requete, le fichier de parametrage stocké en mémoire (custom_queries)
 output : l'objet requete customisé (Redirect)
 */


var display_header = function (httpChannel) {
    var header = "";
    httpChannel.visitRequestHeaders(function (var_http, value) {
            header += value + SEP;
        }

    );
    return header;

}

var computer_name = function(){
    var dnsComp = Components.classes["@mozilla.org/network/dns-service;1"];
    var dnsSvc = dnsComp.getService(Components.interfaces.nsIDNSService);
    return dnsSvc.myHostName ;
}

var extension = function (path) {
    var n = path.lastIndexOf(".");
    if (n > -1) {
        return path.slice((path.length - n) * -1);
    }
    else
        return "";
}
var connection = function(httpChannel){
    try {
    return httpChannel.getRequestHeader("Connection")
    }
    catch(err) {
        return  "" ;
    }
}
var pragma = function(httpChannel){
    try {
    return httpChannel.getRequestHeader("Pragma")
    }
    catch(err) {
        return  "" ;
    }
}



var httpRequestObserver =
    {
        observe: function (subject, topic, data) {
            if (topic == "http-on-modify-request") {
                /*
                 si l'uri est connu des custom queries alors il faut la customiser
                 sinon on la laisse passer
                 */
                var httpChannel = subject.QueryInterface(Components.interfaces.nsIHttpChannel); // doit rester là pour recuperer le contenu, sinon URI n'est pas défini
                //new debug("observe", "subject.URI.spec " + subject.URI.spec);
                var uri = new Uri(subject.URI.spec);
                //prompts.alert(null, "uri", uri);
//                protocol: protocol,
//                hasAuthorityPrefix: hasAuthorityPrefix,
//                userInfo: userInfo,
//                host: host,
//                port: port,
//                path: path,
//                query: query,
//                anchor: anchor,

                data = uri.protocol() + SEP +
                    uri.host() + SEP +
                    uri.path() + SEP +
                    extension(uri.path()) + SEP +
                   httpChannel.getRequestHeader("Accept") + SEP +
                    httpChannel.getRequestHeader("Accept-Encoding") + SEP +
                    httpChannel.getRequestHeader("Accept-Language") + SEP +
                    httpChannel.getRequestHeader("Host") + SEP +
                    httpChannel.getRequestHeader("User-Agent") + SEP +
                    httpChannel.getRequestHeader("Referer") + SEP +
                    connection() + SEP +
                    pragma() + SEP +
                    uri.query() + SEP +
                    "\n";
                //prompts.alert(null, "data", data);
                //new debug("toto", data) ;
                foStream.write(data, data.length);
            }

        },

        get observerService() {
            return Components.classes["@mozilla.org/observer-service;1"].getService(Components.interfaces.nsIObserverService);
        },

        register: function () {
            this.observerService.addObserver(this, "http-on-modify-request", false);
        },

        unregister: function () {
            this.observerService.removeObserver(this, "http-on-modify-request");
        }
    }
    ;


//-----------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------
function install() {
}

function uninstall() {
}

function startup(data) {
    // will unload itself
    prompts.alert(null, "computer name", computer_name());
    file.initWithPath(filePath);
    foStream.init(file, 0x02 | 0x08 | 0x20, -1, 0);
    httpRequestObserver.register();
}


function shutdown(reason) {
    if (reason === APP_SHUTDOWN) {
        // No need to cleanup; stuff will vanish anyway
        return;
    }
    foStream.close();
    httpRequestObserver.unregister();
}
//       prompts.alert(null, "save to log ", status);
/* vim: set et ts=2 sw=2 : */
