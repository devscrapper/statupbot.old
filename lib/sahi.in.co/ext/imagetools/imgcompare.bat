@echo off
cd /d %~dp0
CALL set_graphicsmagick.bat
"%GM%" composite -compose difference %1 %2 %3
"%GM%" compare -metric MAE %1 %2
