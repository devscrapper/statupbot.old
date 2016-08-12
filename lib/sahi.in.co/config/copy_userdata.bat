@echo off
echo Copying necessary files ...
set SAHI_JAVA_HOME=C:\Program Files\Java\jre6
set PATH=%SAHI_JAVA_HOME%\bin;%PATH%
SET SAHI_HOME=%1
SET SOURCE=%SAHI_HOME%\config\userdata_template
SET DESTINATION=%SAHI_HOME%\userdata
java -cp %SAHI_HOME%\lib\sahi.jar net.sf.sahi.installer.PostInstall %SOURCE% %DESTINATION%
echo Done
