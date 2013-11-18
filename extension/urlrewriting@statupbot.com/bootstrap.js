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
/*
 Declarations Globales
 */
const TE_INFO = "INFO", TE_DEBUG = "DEBUG", TE_ERROR = "ERROR";

var prompts = Components.classes["@mozilla.org/embedcomp/prompt-service;1"]. // permet d'afficher des popup
    getService(Components.interfaces.nsIPromptService);
var prefs = Components.classes["@mozilla.org/preferences-service;1"]. //permet d'accéder au paramétrage localiser dans les préférences
    getService(Components.interfaces.nsIPrefService).
    getBranch("extensions.urlrewriting@statupbot.com.");
var log_file = prefs.getComplexValue("log.filename", Components.interfaces.nsIFile); //fichier de log
var visitor_id = prefs.getCharPref("visitor.id"); //id du visitor
var debugging = prefs.getBoolPref("debugging"); //id du visitor
var uri_redirected = {};   //hash contenant les requetes qui ont été customisées, pour éviter qu'elles soient à nouveau capter
var custom_queries = null; //le contenu du fichier de customisation pour chaque visitor


/* function d'affichage du contenu des header http
 Input : l'objet requete
 Output : display du contenu dans la log et la console
 */
function display_header(type_log, httpChannel) {
    httpChannel.visitRequestHeaders(function (var_http, value) {
        LOG(type_log, "display_header", var_http + " " + value);
    });
}

/* Function de logging
 input : le nom de la fonction qui loggue, le type de l'evenment (: INFO, DEBUG, ERROR), le commentaire
 Output : dans la console et dans le fichier de log
 */
function LOG(type, funct, text) {
    // en mode debug on logue tout
    // en mode non debug, on logue que info et error
    if (debugging == true || type != TE_DEBUG) {
        var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
        consoleService.logStringMessage("LOG url_rewriting@statupbot.com : " + type + " " + funct + " " + text);
        var log_line = visitor_id + " " + new Date() + " " + type + " " + funct + " " + text + "\n";
        var foStream = Components.classes["@mozilla.org/network/file-output-stream;1"].
            createInstance(Components.interfaces.nsIFileOutputStream);

        // 0x02 for write only
        // 0x10 to open file for appending.
        // 0x08 to create file if not existe
        // -1 default permissions
        foStream.init(log_file, 0x02 | 0x08 | 0x10, -1, 0);

        var converter = Components.classes["@mozilla.org/intl/converter-output-stream;1"].
            createInstance(Components.interfaces.nsIConverterOutputStream);
        converter.init(foStream, "UTF-8", 0, 0);
        converter.writeString(log_line);
        converter.close();
    }
}


/*  function de remplacement des variables d'une query http
 Input : l'url dans laquelle ont fait la subsitution, la variable à valoriser, la nouvelle valeur
 Outpout : l'url customisée
 */
function replaceQueryString(url, param, value) {
    LOG(TE_DEBUG, "replaceQueryString", "replace param : " + param + " by " + value + " in " + url);
    var re = new RegExp("([?|&])" + param + "=.*?(&|$)", "i");
    if (url.match(re))
        return url.replace(re, '$1' + param + "=" + value + '$2');
    else
        return url + '&' + param + "=" + value;
}

/* function update_header_http  remplace ou ajoute les variables du header http par les var http de custom_queries
 input : L'objet Requete, l'uri qui est la clé de recherche dans custom_queries
 var Globale : custom_queries
 output : L'objet Requete mis a jour
 */
function update_header(http_channel, uri) {
    if (debugging == true) {
        LOG(TE_DEBUG, "update_header", "header before update");
        display_header(TE_DEBUG, http_channel);
    }
    var query;
    for (query in custom_queries) {
        var custom_query = custom_queries[query];
        if (query == "*" || // soit c'est une query qui s'applique à toutes les URI
            uri.spec.search(query) > -1) {// soit c'est une query qui s'applique à une URI en particulier
            var var_http;
            for (var_http in custom_query["var_http"]) {
                try {
                    http_channel.setRequestHeader(var_http, custom_query["var_http"][var_http], false);
                    LOG(TE_DEBUG, "update_header", "replace var http : " + var_http + " by " + custom_query["var_http"][var_http]);
                }
                catch (err) {
                    LOG(TE_ERROR, "update_header", "replace var http : " + var_http + " : " + err.message);
                }
            }
            break; // on sort des données de paramétrage quand on a cuqtomize la requete.
        }
        if (debugging == true) {
            LOG(TE_DEBUG, "update_header", "header after update");
            display_header(TE_DEBUG, http_channel);
        }

        return http_channel;
    }
}
/* function update_query affecte les valeurs pour chaque variable de la cusom query pour la query http cournate
 input : l'objet uri avec l'url encodée, toutes les règles de customisation
 output : l'objet uri avec l'url encodée & updatée
 */
function update_query(uri) {
    var uri_string = decodeURI(uri.spec);
    LOG(TE_DEBUG, "update_query", "uri decoded before update: " + uri_string);
    var query;
    for (query in custom_queries) {
        var custom_query = custom_queries[query];
        if (query == "*" || // soit c'est une query qui s'applique à toutes les URI
            uri.spec.search(query) > -1) { // soit c'est une query qui s'applique à une URI en particulier
            var var_query;
            for (var_query in custom_query["var_query"]) {
                uri_string = replaceQueryString(uri_string, var_query, custom_query["var_query"][var_query])
            }
            break; // on sort des données de paramétrage quand on a cuqtomize la requete.
        }
    }
    LOG(TE_DEBUG, "update_query", "uri decoded after update: " + uri_string);

    var uri_string = encodeURI(uri_string);
    var ios = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
    var uri_update = ios.newURI(uri_string, null, null);

    return uri_update;
}

/* function d'écoute des requetes émises et application du fichier de customisation du visitor
 input : L'objet requete, le fichier de parametrage stocké en mémoire (custom_queries)
 output : l'objet requete customisé (Redirect)
 */
var httpRequestObserver =
{
    observe: function (subject, topic, data) {

        if (topic == "http-on-modify-request") {
            // la customisation se fait en 2 temps :
            // dans un premier temps, on reconstruit une url en customisant les variables de la query et on redirige la requqte sortant
            // dans un deuxième temps, on customise les variables du header http
            var httpChannel = subject.QueryInterface(Components.interfaces.nsIHttpChannel);

            //est que la requete a déjà été redirigée/customisée ?
            if (uri_redirected[subject.URI.spec] == null) {
                // la requete n'a jamais été redirigée/customisée
                // alors on customise la query
                var uri_update = update_query(subject.URI);
                // A t on customizé la requete ?
//                prompts.alert(null, "uri =  ", uri_update.spec);
//                prompts.alert(null, "subject.URI =  ",  subject.URI.spec);
//                prompts.alert(null, "subject.URI =  ", uri_update.spec != subject.URI.spec);
                if (uri_update.spec != subject.URI.spec) {
                    // la requete a été customisé alors on la redirige pour traiter les headers
                    try {
                        httpChannel.redirectTo(uri_update);
                        uri_redirected[uri_update.spec] = true;
                        LOG(TE_INFO, "observe", "topic : http-on-modify-request -> redirect To " + uri_update.spec);
                    }
                    catch (err) {
                        LOG(TE_ERROR, "observe", "topic : http-on-modify-request -> redirect To : " + err.message);
                    }
                }
                else {
                    // la requete n'a pas été customisée on l'envoie en l'état
                    LOG(TE_DEBUG, "observe", "topic : http-on-modify-request ->  no redirect for " + uri_update.spec);
                }

            }
            else {
                // la requete a déjà été redirigée/customisée
                // alors on customise les headers
                httpChannel = update_header(httpChannel, subject.URI);
                display_header(TE_INFO, httpChannel);
                uri_redirected[subject.URI.spec] = null;
            }
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
};


//-----------------------------------------------------------------------------------------------------
function Read(visitors_file) {
    var out = {};
    LOG(TE_DEBUG, "Read", "visitors file name : " + visitors_file.path);
    var fileStream = Components.classes['@mozilla.org/network/file-input-stream;1'].
        createInstance(Components.interfaces.nsIFileInputStream);
    fileStream.init(visitors_file, 1, 0, false);

    var converterStream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].
        createInstance(Components.interfaces.nsIConverterInputStream);
    converterStream.init(fileStream, 'UTF-8', fileStream.available(), converterStream.DEFAULT_REPLACEMENT_CHARACTER);
    converterStream.readString(fileStream.available(), out);

    var content_visitors_file = JSON.parse(out.value);
    LOG(TE_DEBUG, "Read", "content visitors file : " + out.value);
    LOG(TE_INFO, "Read", "content visitors file");
    return content_visitors_file
}


//-----------------------------------------------------------------------------------------------------
function install() {
}

function uninstall() {
}

function startup(data) {
    // will unload itself
    var visitors_file = prefs.getComplexValue("visitor.filename", Components.interfaces.nsIFile);
    custom_queries = Read(visitors_file);

    httpRequestObserver.register();
}

function shutdown(reason) {
    if (reason === APP_SHUTDOWN) {
        // No need to cleanup; stuff will vanish anyway
        return;
    }
    httpRequestObserver.unregister();
}

/* vim: set et ts=2 sw=2 : */
