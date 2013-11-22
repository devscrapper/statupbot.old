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
Components.utils.import("chrome://tools/content/custom_queries.js");


/*
 Declarations Globales
 */
var prefs = Components.classes["@mozilla.org/preferences-service;1"]. //permet d'accéder au paramétrage localiser dans les préférences
    getService(Components.interfaces.nsIPrefService).
    getBranch("extensions.urlrewriting@statupbot.com.");

var uri_redirected = {};   //hash contenant les requetes qui ont été customisées, pour éviter qu'elles soient à nouveau capter
var custom_queries = null; //le contenu du fichier de customisation pour chaque visitor


/* function d'écoute des requetes émises et application du fichier de customisation du visitor
 input : L'objet requete, le fichier de parametrage stocké en mémoire (custom_queries)
 output : l'objet requete customisé (Redirect)
 */
var httpRequestObserver =
    {
        observe: function (subject, topic, data) {
            if (topic == "http-on-modify-request") {
                /*
                 si l'uri est connu des custom queries alors il faut la customiser
                 sinon on la laisse passer
                 */
                var httpChannel = subject.QueryInterface(Components.interfaces.nsIHttpChannel); // doit rester là pour recuperer le contenu, sinon URI n'est pas défini
                new debug("observe", "subject.URI.spec " + subject.URI.spec) ;

                if (custom_queries.does_know_uri(subject.URI.spec) === true) {
                    // la customisation se fait en 2 temps :
                    // dans un premier temps, on reconstruit une url en customisant les variables de la query et on redirige la requqte sortant
                    // dans un deuxième temps, on customise les variables du header http

                    //est que la requete a déjà été redirigée et sa query customisée ?
                    if (uri_redirected[subject.URI.spec] == null) {
                        // la requete n'a jamais été redirigée
                        // alors on customise la query
                        var uri_updated ;
                        if ((uri_updated  = custom_queries.update_query(subject.URI.spec)) != null) {
                            // la requete a été customisé alors on la redirige pour traiter les headers
                            try {
                                new debug("observe", "topic : http-on-modify-request -> uri_updated " + uri_updated);
                                var ios = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
                                var URI_updated = ios.newURI(uri_updated, null, null);
                                httpChannel.redirectTo(URI_updated);
                                uri_redirected[URI_updated.spec] = true;
                                new info("observe", "topic : http-on-modify-request -> redirect To " + URI_updated.spec);
                            }
                            catch (err) {
                                new error("observe", "topic : http-on-modify-request -> redirect To : " + err.message);
                            }
                        }
                        else {
                            // la query de l'uri n'a pas été customisée alors on ne la redirige pas
                            // on customise directement les headers
                            httpChannel = custom_queries.update_header(httpChannel, subject.URI.spec);
                        }
                    }
                    else {
                        // la requete a déjà été redirigée/customisée
                        // alors on customise les headers
                        httpChannel = custom_queries.update_header(httpChannel, subject.URI.spec);
                        uri_redirected[subject.URI.spec] = null;
                    }
                }
                else {
                    // la requete n'a pas être customisée on l'envoie en l'état
                    new debug("observe", "topic : http-on-modify-request ->  no redirect for " + subject.URI.spec);
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
    var visitors_file = prefs.getComplexValue("visitor.filename", Components.interfaces.nsIFile);
    custom_queries = new customQueries(visitors_file);
    custom_queries.load() ;
    httpRequestObserver.register();
}


function shutdown(reason) {
    if (reason === APP_SHUTDOWN) {
        // No need to cleanup; stuff will vanish anyway
        return;
    }
    httpRequestObserver.unregister();
}
//       prompts.alert(null, "save to log ", status);
/* vim: set et ts=2 sw=2 : */
