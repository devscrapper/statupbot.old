@ECHO OFF
if [%1]==[] goto ERROR
if [%2]==[] goto ERROR
if [%3]==[] goto ERROR
if [%4]==[] goto ERROR
SET SAHI_HOME=..\..
SET USERDATA_DIR=..\
call setjava.bat
SET ORIG_SCRIPTS_PATH=scripts
SET START_URL=%3
REM SET NODES=localhost:9999,othermachine:9999,thirdmachine:9999
SET NODES=localhost:9999

REM LOGS_INFO format is type:filePath
REM SET LOGS_INFO=html:D:/logs/html
SET LOGS_INFO=html

java -cp %SAHI_HOME%\lib\ant-sahi.jar in.co.sahi.distributed.DLoadRunner -scriptsPathMaster %ORIG_SCRIPTS_PATH% -noise %1 -noiseBrowserType phantomjs -min 1 -max 9 -incrementBy 2 -interval 5 -subject %2 -subjectRepeatCount 3 -browserType %4 -logsInfo "%LOGS_INFO%" -baseURL "%START_URL%" -host localhost -port 9999 -nodes "%NODES%" -ignorePattern ".*(svn|copied).*"
goto :EOF

:ERROR
echo --
echo Usage: %0 ^<noise sah file^> ^<subject sah file^> ^<startURL^> ^<browserType^>
echo File path is relative to userdata/scripts
echo tags are used only if the input suite is a csv file
echo --
echo Example:
echo %0 demo/load/noise.sah demo/load/subject.sah http://sahitest.com/demo/training/ firefox
echo --