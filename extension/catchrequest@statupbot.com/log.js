var EXPORTED_SYMBOLS = ["debug", "info", "error", "alert"];

var Log = function (str) {
    'use strict';
    var prefs = Components.classes["@mozilla.org/preferences-service;1"]. //permet d'accéder au paramétrage localiser dans les préférences
            getService(Components.interfaces.nsIPrefService).getBranch("extensions.urlrewriting@statupbot.com."),
        log_file = prefs.getComplexValue("log.filename", Components.interfaces.nsIFile), //fichier de log
        visitor_id = prefs.getCharPref("visitor.id"), //id du visitor
        debugging = prefs.getBoolPref("debugging"), //niveau de log

        save_to_console = function save_to_console(log_line) {
            var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
            consoleService.logStringMessage("[url_rewriting@statupbot.com] " + log_line);
        },

        save_to_file = function save_to_file(log_line) {
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
        },

        log = function log(type, log_line) {
            save_to_console(" " + type + " " + log_line);
            save_to_file(visitor_id + " " + new Date() + " " + type + " " + log_line + "\n");
        }   ,
        debug = function (funct, text) {
            if (debugging == true) {
                var log_line = funct + " " + text;
                log("DEBUG", log_line)
            }
        },
        info = function (funct, text) {
            var log_line = funct + " " + text;
            log("INFO", log_line)
        },
        error = function (funct, text) {
            var log_line = funct + " " + text;
            log("ERROR", log_line)
        },
        alert = function (funct, text) {
            var log_line = funct + " " + text;
            log("ALERT", log_line);
            var prompts = Components.classes["@mozilla.org/embedcomp/prompt-service;1"]. // permet d'afficher des popup
                getService(Components.interfaces.nsIPromptService);
            prompts.alert(null, funct, log_line);
        };


    return {
        debug: debug,
        info: info,
        error: error,
        alert: alert
    };
};

var info = function (func, text) {
    new Log().info(func, text);

};
var error = function (func, text) {
    new Log().error(func, text);

};
var alert = function (func, text) {
    new Log().alert(func, text);

};
var debug = function (func, text) {
    new Log().debug(func, text);

};
