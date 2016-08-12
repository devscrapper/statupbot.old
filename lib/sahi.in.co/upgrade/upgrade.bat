@echo off
cd /d %~dp0
set UPGRADE_TO=%1
copy upgrade-sahi.jar upgrade-sahi2.jar 
copy ..\extlib\license\truelicense.jar truelicense.jar 
copy ..\extlib\license\truexml.jar truexml.jar
copy ..\extlib\apc\commons-codec-1.3.jar commons-codec-1.3.jar
java -cp upgrade-sahi2.jar;truelicense.jar;truexml.jar;commons-codec-1.3.jar in.co.sahi.upgrade.SahiUpgradeClient %UPGRADE_TO% >log.txt 2>&1
cd /d ..\userdata\bin
start_dashboard.bat