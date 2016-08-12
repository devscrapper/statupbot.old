SFL - Sahi Flex Library

To automate flex applications, you need to compile your swf with the correct version of sfl.swc
If your application is compiled with Flex 4.0 use sfl4.swc
If your application is compiled with Flex 3.5 use sfl35.swc


Use the command below to compile yourapp.mxml (Change sfl version as needed)

mxmlc yourapp.mxml -include-libraries+=sfl4.swc --output=yourapp.swf

Refresh the browser cache, to make sure that the modified yourapp.swf is available.
