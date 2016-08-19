Reports are generated using XSLs.
XSL files are by default in subfolders of sahi/config/reports/.
They can be overridden in sahi/userdata/config/reports/ folder

Sahi will first look for any report xsl in sahi/userdata/config/reports/. 
If it is not found, it will default to sahi/config/reports/

For example, xsls for html reports are in sahi/config/reports/html folder.

To modify existig xsl, copy it over into this folder (userdata/config/reports) 
with the same subfolder name.

Eg. if you want to modify suites_list.xsl, copy it here such that you have
userdata/config/reports/html/suites_list.xsl.
Now modify this copied file as needed.

More information is available http://sahipro.com/docs/using-sahi/sahi-reports.html