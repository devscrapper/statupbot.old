@echo off
cd /d %~dp0
CALL set_graphicsmagick.bat
"%GM%" convert %1 -trim %1
