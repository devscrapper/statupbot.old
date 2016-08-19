@ECHO OFF
REM This batch file should be used only if you plan to use a different Master machine.
REM Sahi may or may not be installed on the Initiator machine (where this batch file is run). The following directory structure is assumed so that it is applicable for both scenarios (whether Sahi is installed or not)
REM
REM <TOP_LEVEL_FOLDER>
REM		config
REM			email.properties
REM 	lib
REM			ant-sahi.jar
REM		logs
REM		userdata
REM			bin
REM				drun_different_master.bat
REM				setjava.bat
REM			scripts
REM				<ALL YOUR SCRIPT FOLDERS AND SCRIPTS>

if [%1]==[] goto ERROR
if [%2]==[] goto ERROR
if [%3]==[] goto ERROR

SET TOP_LEVEL_FOLDER=..\..
call setjava.bat

REM MASTER_HOST refers to the machine that serves as the Master
REM IMPORTANT: Make sure you change MASTER_HOST to the actual machine name.
SET MASTER_HOST=machine2
SET MASTER_PORT=9999

REM initiatorOriginFolder SHOULD be relative to drun_different_master.bat OR an absolute path on the Initiator machine.
REM It contains ALL the scripts that are to be run.
SET INITIATOR_ORIGIN_FOLDER=%TOP_LEVEL_FOLDER%/userdata/scripts

REM MASTER_STAGING_PATH refers to the Staging folder on the Master machine to which the contents of INITIATOR_ORIGIN_FOLDER will be first synced to.
REM Distribution of scripts will happen from MASTER_STAGING_PATH.
REM	This should be relative to the userdata folder, or an absolute path on the Master machine
SET MASTER_STAGING_PATH=temp/scripts/staging

REM START_URL refers to the start url against which the suite will be run. This is to be passed as the 2nd parameter to drun.
SET START_URL=%2

REM Scripts will be distributed across all the nodes. The nodes may or may not include the Master machine
REM SET NODES=machine2:9999,machine3:9999,machine4:9999
SET NODES=machine2:9999

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

REM Sahi can set offline logs to be generated in xml,html,junit,tm6 and excel types. The default type is html. These logs will be generated on the Master and pulled back to the Initiator, since the user would want to store the logs on the Initiator.
REM If you do not want offline logs, comment out everything between the lines "REM Offline logs start" and "REM Offline logs end".  
REM Offline logs start

SET UNIQUE_ID=%DATE%__%TIME%
SET UNIQUE_ID=%UNIQUE_ID: =_%
SET UNIQUE_ID=%UNIQUE_ID::=_%
SET UNIQUE_ID=%UNIQUE_ID:/=_%

REM MASTER_HTMLLOGS_DIR should be relative to the userdata folder or it should be an absolute path on the Master machine
SET MASTER_HTMLLOGS_DIR=logs/temp/html/%UNIQUE_ID%

REM LOGS_INFO format is type:filePath,type2,type3:filePath3
SET LOGS_INFO=html:%MASTER_HTMLLOGS_DIR%

REM INITIATOR_OUTPUT_HTMLLOGS_DIR should be relative to the Ant folder (folder containing the Ant xml) OR an absolute path on the Initiator machine.
REM This is where the html logs will be copied back to on the Initiator machine
SET INITIATOR_OUTPUT_HTMLLOGS_DIR=%TOP_LEVEL_FOLDER%/logs/html

REM If you intend to log other types, do it on the same lines as the HTML logs
REM Offline logs end

SET IGNORE_PATTERN=".*(svn|copied).*"

SET THREADS=5

REM Properties used for creating smart zip.
SET CSVSEPARATOR=","
SET SCRIPTEXTENSIONS="sah;sahi;js;"
SET SCENARIOEXTENSIONS=".s.csv;xls;xlsx"

REM SHOW_PERIODIC_SUMMARY enables printing of script status update in the console
SET SHOW_PERIODIC_SUMMARY=true

REM First sync the scripts to a staging folder on the Master
java -cp %TOP_LEVEL_FOLDER%\lib\ant-sahi.jar in.co.sahi.distributed.DSync -originFolder %INITIATOR_ORIGIN_FOLDER% -destFolder %MASTER_STAGING_PATH%/%UNIQUE_ID% -nodes "%MASTER_HOST%:%MASTER_PORT%" -ignorePattern %IGNORE_PATTERN% -suitePath %1 -csvSeparator %CSVSEPARATOR% -scriptExtensions %SCRIPTEXTENSIONS% -scenarioExtensions %SCENARIOEXTENSIONS%

REM Now perform the distributed run
java -cp %TOP_LEVEL_FOLDER%\lib\ant-sahi.jar in.co.sahi.distributed.DSahiRunner -scriptsPathInitiator %INITIATOR_ORIGIN_FOLDER% -scriptsPathMaster %MASTER_STAGING_PATH%/%UNIQUE_ID% -suite %1 -isDifferentMaster true -ignorePattern %IGNORE_PATTERN% %CUSTOM_FIELDS% %USER_DEFINED_ID% -browserType %3 -logsInfo "%LOGS_INFO%" -baseURL "%START_URL%" -host %MASTER_HOST% -port %MASTER_PORT% -threads %THREADS% -nodes "%NODES%" -nodesFilePath "%NODES_FILEPATH%" -sendEmail %SEND_EMAIL_REPORT% -emailTrigger "%EMAIL_TRIGGER%" -emailProperties "%EMAIL_PROPERTIES%" -sendEmailPeriodically "%SEND_EMAIL_REPORT_PERIODICALLY%" -sendEmailPeriodicallyTime "%SEND_EMAIL_REPORT_PERIODICALLY_TIME%" -emailPasswordHidden "%EMAIL_PASSWORD_HIDDEN%" -showPeriodicSummary %SHOW_PERIODIC_SUMMARY% -tags %4

REM Delete the staging folder on the Master
java -cp %TOP_LEVEL_FOLDER%\lib\ant-sahi.jar in.co.sahi.distributed.DDelete -host %MASTER_HOST% -port %MASTER_PORT% -filePath %MASTER_STAGING_PATH%/%UNIQUE_ID%

REM Pull the HTML logs from the Master onto the Initiator machine
java -cp %TOP_LEVEL_FOLDER%\lib\ant-sahi.jar in.co.sahi.distributed.DPull -sourceHost %MASTER_HOST% -sourcePort %MASTER_PORT% -originFolder %MASTER_HTMLLOGS_DIR% -destFolder %INITIATOR_OUTPUT_HTMLLOGS_DIR% -ignorePattern %IGNORE_PATTERN%

REM If you have created logs of other types such as JUnit, add a DPull call for that logs type too

goto :EOF

:ERROR
echo --
echo NOTE: Use this batch file only if you plan to use a different Master machine. Else, use drun.bat instead.
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
echo %0 demo/testcases/testcases_sample.csv http://sahitest.com/demo/ ie "(user||admin)&&medium"
echo %0 demo/ddcsv/test.dd.csv http://sahitest.com/demo/ ie "(user||admin)&&medium"	
echo %0 demo/framework/sample.xls http://sahitest.com/demo/training/ ie
echo %0 demo/framework/scenario_new.s.csv http://sahitest.com/demo/training/ ie "all"
echo --
