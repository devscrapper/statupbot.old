@ECHO OFF
REM This batch file should be used only if you are running it on the Master machine.

if [%1]==[] goto ERROR
if [%2]==[] goto ERROR
if [%3]==[] goto ERROR

SET SAHI_HOME=..\..
call setjava.bat

REM SOURCE_SCRIPTS_PATH should be relative to the userdata folder OR it should be an absolute path. It contains ALL the scripts that are to be run.
SET SOURCE_SCRIPTS_PATH=scripts

REM START_URL refers to the start url against which the suite will be run. This is to be passed as the 2nd parameter to drun. 
SET START_URL=%2

REM Scripts will be distributed across all the nodes. The nodes may or may not include the Master machine, i.e. localhost
REM SET NODES=localhost:9999,othermachine:9999,thirdmachine:9999
SET NODES=localhost:9999

SET NODES_FILEPATH=

REM Set SEND_EMAIL_REPORT to true if email is to be sent at the end of a run
SET SEND_EMAIL_REPORT=false
REM EMAIL_TRIGGER indicates the trigger when email should be sent. Possible values are success OR failure OR success,failure
SET EMAIL_TRIGGER=success,failure

REM Set SEND_EMAIL_REPORT_PERIODICALLY to true if email is to be sent after particular interval of time
SET SEND_EMAIL_REPORT_PERIODICALLY=
REM SEND_EMAIL_REPORT_PERIODICALLY_TIME indicates time(minutes) interval after which email will be sent.
SET SEND_EMAIL_REPORT_PERIODICALLY_TIME=

REM email.properties contains the details needed for sending the email
SET EMAIL_PROPERTIES=..\config\email.properties
REM Set EMAIL_PASSWORD_HIDDEN to true to prevent the password from getting logged
SET EMAIL_PASSWORD_HIDDEN=true

REM Uncomment the following line to set custom fields. Replace the custom field keys and values as appropriate
REM SET CUSTOM_FIELDS=-customField customValue -anotherCustomField "another value"

REM Uncomment the following line to set the userDefinedId. Replace the value as appropriate. The key should remain as userDefinedId
REM SET USER_DEFINED_ID=-userDefinedId  "Some Id"

REM LOGS_INFO format is type:filePath,type2,type3:filePath3
REM SET LOGS_INFO=html:D:/html,xml
SET LOGS_INFO=html

REM SHOW_PERIODIC_SUMMARY enables printing of script status update in the console
SET SHOW_PERIODIC_SUMMARY=true

SET THREADS=5

java -cp %SAHI_HOME%\lib\ant-sahi.jar in.co.sahi.distributed.DSahiRunner -scriptsPathMaster %SOURCE_SCRIPTS_PATH% -ignorePattern ".*(svn|copied).*" %CUSTOM_FIELDS% %USER_DEFINED_ID% -suite %1 -browserType %3 -logsInfo "%LOGS_INFO%" -baseURL "%START_URL%" -host localhost -port 9999 -threads %THREADS% -nodes "%NODES%" -nodesFilePath "%NODES_FILEPATH%" -sendEmail %SEND_EMAIL_REPORT% -emailTrigger "%EMAIL_TRIGGER%" -emailProperties "%EMAIL_PROPERTIES%" -sendEmailPeriodically "%SEND_EMAIL_REPORT_PERIODICALLY%" -sendEmailPeriodicallyTime "%SEND_EMAIL_REPORT_PERIODICALLY_TIME%" -emailPasswordHidden "%EMAIL_PASSWORD_HIDDEN%" -showPeriodicSummary %SHOW_PERIODIC_SUMMARY% -tags %4
goto :EOF

:ERROR
echo --
echo NOTE: Use this batch file only if you are running it on the Master machine. If you wish to use a different Master, use drun_different_master.bat instead.
echo --
echo Usage: %0 ^<sah file^|suite file^> ^<startURL^> ^<browserType^> ^<tags^>
echo File path is relative to userdata/scripts
echo Multiple browsers can be specified using +. Eg. ie+firefox
echo tags are used only if the input file is a .csv file, .s.csv file or a .dd.csv file
echo --
echo Example:
echo %0 demo/demo.suite http://sahitest.com/demo/ firefox
echo %0 demo/sahi_demo.sah http://sahitest.com/demo/ ie
echo %0 demo/sahi_demo.sah http://sahitest.com/demo/ ie+firefox
echo %0 demo/demo.dd.csv http://sahitest.com/demo/ firefox "win||all"
echo %0 demo/testcases/testcases_sample.csv http://sahitest.com/demo/ ie "(user||admin)&&medium"
echo %0 demo/ddcsv/test.dd.csv http://sahitest.com/demo/ ie "(user||admin)&&medium"	
echo %0 demo/framework/sample.xls http://sahitest.com/demo/training/ ie
echo %0 demo/framework/scenario_new.s.csv http://sahitest.com/demo/training/ ie "all"
echo --