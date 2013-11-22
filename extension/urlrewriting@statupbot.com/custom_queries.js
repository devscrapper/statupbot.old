var EXPORTED_SYMBOLS = ["customQueries"];
Components.utils.import("chrome://tools/content/log.js");
Components.utils.import("chrome://tools/content/uri.js");

var customQueries = function (visitors_file) {
    // new alert("custom queries", "new");
    var visitors_file = visitors_file,
        content_visitors_file = null ,
        display_header = function (httpChannel) {
            httpChannel.visitRequestHeaders(function (var_http, value) {
                new debug("display_header", var_http + " " + value);
            });
        },
    /*
     retourne true si scheme://host/path appartient aux custom_queries
     */
        does_know_uri = function (uri_str) {
            var uri = new Uri(uri_str);
            new debug("does_know_uri", "scheme://host/path " + uri.protocol() + "://" + uri.host() + uri.path());
            new debug("does_know_uri", "typeof " + typeof content_visitors_file[uri.protocol() + "://" + uri.host() + uri.path()]);
            new debug("does_know_uri", "know ? " + (typeof content_visitors_file[uri.protocol() + "://" + uri.host() + uri.path()] === 'object'));
            return typeof content_visitors_file[uri.protocol() + "://" + uri.host() + uri.path()] === 'object';
        }
        ,
        print = function (o) {
            var out = '';
            for (var p in o) {
                out += p + ': ' + o[p] + '\n';
            }
            alert(out);
        }
    load = function () {
        var out = {};
        //new alert("custom queries", "load");
        new debug("load custom queries", "visitors file name : " + visitors_file.path);
        var fileStream = Components.classes['@mozilla.org/network/file-input-stream;1'].
            createInstance(Components.interfaces.nsIFileInputStream);
        fileStream.init(visitors_file, 1, 0, false);

        var converterStream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].
            createInstance(Components.interfaces.nsIConverterInputStream);
        converterStream.init(fileStream, 'UTF-8', fileStream.available(), converterStream.DEFAULT_REPLACEMENT_CHARACTER);
        converterStream.readString(fileStream.available(), out);

        content_visitors_file = JSON.parse(out.value);
        //print(content_visitors_file);
        new debug("load custom queries", "content visitors file : " + content_visitors_file);
        new info("load custom queries", "content visitors file");

    },
        update_query = function update_query(uri_str) {
            var uri = new Uri(uri_str);
            new debug("update_query", "uri " + uri);
            vars_query = content_visitors_file[uri.protocol() + "://" + uri.host() + uri.path()].var_query;
            new debug("update_query", "vars_query " + vars_query);
            var var_query;
            for (var_query in vars_query) {
                new debug("update_query", "update var_query " + var_query + " by " + encodeURIComponent(vars_query[var_query]));
                uri.replaceQueryParam(var_query, encodeURIComponent(vars_query[var_query]));
            }
            new debug("update_query", "uri updated " + uri);
            return uri;
        },

        update_header = function update_header(httpChannel, uri_str) {
            display_header(httpChannel);
            var uri = new Uri(uri_str);
            new debug("update_query", "uri " + uri);
            vars_http = content_visitors_file[uri.protocol() + "://" + uri.host() + uri.path()].var_http;
            new debug("update_query", "vars_query " + vars_http);
            var var_http;
            for (var_http in vars_http) {

                try {
                    httpChannel.setRequestHeader(var_http, vars_http[var_http], false);
                    new debug("update_header", "update var_http " + var_http + " by " + vars_http[var_http]);
                }
                catch (err) {
                    new error("update_header", "update var http : " + var_http + " : " + err.message);
                }
            }
            display_header(httpChannel);

            return httpChannel;
        };


return {
    does_know_uri: does_know_uri,
    load: load,
    update_query: update_query,
    update_header: update_header
};
}
;