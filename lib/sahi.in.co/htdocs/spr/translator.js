var b = new net.sf.sahi.client.Browser();
b.setTranslationMode(true);
var s = '' + <java_string>;
if (s == 'null' || s == 'undefined') s = b.getSteps().join(';\n');
s;