#!/bin/bash

# This batch file should be used only if you plan to use a different Master machine.
# Sahi may or may not be installed on the Initiator machine (where this batch file is run). The following directory structure is assumed so that it is applicable for both scenarios (whether Sahi is installed or not)
#
# <TOP_LEVEL_FOLDER>
#		config
#			email.properties
# 		lib
#			ant-sahi.jar
#		logs
#		userdata
#			bin
#				drun_different_master.sh
#				setjava.sh
#			scripts
#				<ALL YOUR SCRIPT FOLDERS AND SCRIPTS>

if [ $# -lt 3 ] 
then
echo "Usage: drun_different_master.sh <sah file|suite file> <startURL> <browserType> <tags>"
echo "File path is relative to userdata/scripts"
echo "tags are used only if the input file is a .csv file, .s.csv file or a .dd.csv file"
echo "Example:" 
echo "$0 demo/demo.suite http://sahitest.com/demo/ firefox"
echo "$0 demo/sahi_demo.sah http://sahitest.com/demo/ firefox"
echo "$0 demo/sahi_demo.sah http://sahitest.com/demo/ firefox+safari"
echo "$0 demo/testcases/testcases_sample.csv http://sahitest.com/demo/ firefox \"(admin||user)&&medium\""
echo "$0 demo/ddcsv/test.dd.csv http://sahitest.com/demo/ firefox \"(admin||user)&&medium\""
echo "$0 demo/framework/sample.xls http://sahitest.com/demo/training/ firefox"
echo "$0 demo/framework/scenario_new.s.csv http://sahitest.com/demo/training/ firefox \"all\""
else

. ./setjava.sh

export TOP_LEVEL_FOLDER=../..

# MASTER_HOST refers to the machine that serves as the Master
# IMPORTANT: Make sure you change MASTER_HOST to the actual machine name.
export MASTER_HOST=machine2
export MASTER_PORT=9999

# initiatorOriginFolder SHOULD be relative to drun_different_master.sh OR an absolute path on the Initiator machine.
# It contains ALL the scripts that are to be run.
export INITIATOR_ORIGIN_FOLDER=$TOP_LEVEL_FOLDER/userdata/scripts

# MASTER_STAGING_PATH refers to the Staging folder on the Master machine to which the contents of INITIATOR_ORIGIN_FOLDER will be first synced to.
# Distribution of scripts to various node machines will happen from MASTER_STAGING_PATH.
# This should be relative to the userdata folder, or an absolute path on the Master machine
export MASTER_STAGING_PATH=temp/scripts/staging

# START_URL refers to the start url against which the suite will be run. This is to be passed as the 2nd parameter to drun.
export START_URL=$2

export BROWSER=$3

# Scripts will be distributed across all the nodes. The nodes may or may not include the Master machine
# SET NODES=machine2:9999,machine3:9999,machine4:9999
export NODES=machine2:9999

export NODES_FILEPATH=

# Set SEND_EMAIL_REPORT to true if email is to be sent at the end of a run
export SEND_EMAIL_REPORT=false
# EMAIL_TRIGGER indicates the trigger when email should be sent. Possible values are success OR failure OR success,failure
export EMAIL_TRIGGER=success,failure

# Set SEND_EMAIL_REPORT_PERIODICALLY to true if email is to be sent after particular interval of time
export SEND_EMAIL_REPORT_PERIODICALLY=
# Set SEND_EMAIL_REPORT_PERIODICALLY_TIME indicates time(minutes) interval after which email will be sent.
export SEND_EMAIL_REPORT_PERIODICALLY_TIME=

# email.properties contains the details needed for sending the email
export EMAIL_PROPERTIES=../config/email.properties
# Set EMAIL_PASSWORD_HIDDEN to true to prevent the password from getting logged
export EMAIL_PASSWORD_HIDDEN=true

# Uncomment the following line to set custom fields. Replace the custom field keys and values as appropriate
# SET CUSTOM_FIELDS=-customField customValue -anotherCustomField "another value"

# Uncomment the following line to set the userDefinedId. Replace the value as appropriate. The key should remain as userDefinedId
# SET USER_DEFINED_ID=-userDefinedId  "Some Id"

# Sahi can set offline logs to be generated in xml,html,junit,tm6 and excel types. The default type is html. These logs will be generated on the Master and pulled back to the Initiator, since the user would want to store the logs on the Initiator.
# If you do not want offline logs, comment out everything between the lines "# Offline logs start" and "# Offline logs end".  
# Offline logs start

export UNIQUE_ID=$(date +"%m_%d_%Y")__$(date +"%I_%M_%S")

# MASTER_HTMLLOGS_DIR should be relative to the userdata folder or it should be an absolute path on the Master machine
export MASTER_HTMLLOGS_DIR=logs/temp/html/$UNIQUE_ID

# LOGS_INFO format is type:filePath,type2,type3:filePath3
export LOGS_INFO=html:$MASTER_HTMLLOGS_DIR

# INITIATOR_OUTPUT_HTMLLOGS_DIR should be relative to drun_different_master.sh OR an absolute path on the Initiator machine.
# This is where the html logs will be copied back to on the Initiator machine
export INITIATOR_OUTPUT_HTMLLOGS_DIR=$TOP_LEVEL_FOLDER/logs/html

# If you intend to log other types, do it on the same lines as the HTML logs
# Offline logs end

export IGNORE_PATTERN=".*(svn|copied).*"

export THREADS=5

# Properties used for creating smart zip.
export CSVSEPARATOR=","
export SCRIPTEXTENSIONS="sah;sahi;js;"
export SCENARIOEXTENSIONS=".s.csv;xls;xlsx"

# SHOW_PERIODIC_SUMMARY enables printing of script status update in the console
export SHOW_PERIODIC_SUMMARY=true

# First sync the scripts to a staging folder on the Master
java -cp $TOP_LEVEL_FOLDER/lib/ant-sahi.jar in.co.sahi.distributed.DSync -originFolder $INITIATOR_ORIGIN_FOLDER -destFolder $MASTER_STAGING_PATH/$UNIQUE_ID -nodes "$MASTER_HOST:$MASTER_PORT" -ignorePattern $IGNORE_PATTERN -suitePath $1 -csvSeparator $CSVSEPARATOR -scriptExtensions $SCRIPTEXTENSIONS -scenarioExtensions $SCENARIOEXTENSIONS

# Now perform the distributed run
java -cp $TOP_LEVEL_FOLDER/lib/ant-sahi.jar in.co.sahi.distributed.DSahiRunner -scriptsPathInitiator $INITIATOR_ORIGIN_FOLDER -scriptsPathMaster $MASTER_STAGING_PATH/$UNIQUE_ID -suite $1 -isDifferentMaster true -ignorePattern $IGNORE_PATTERN $CUSTOM_FIELDS $USER_DEFINED_ID -browserType "$BROWSER" -logsInfo "$LOGS_INFO" -baseURL "$START_URL" -host $MASTER_HOST -port $MASTER_PORT -threads "$THREADS" -nodes "$NODES" -nodesFilePath "$NODES_FILEPATH" -sendEmail $SEND_EMAIL_REPORT -emailTrigger "$EMAIL_TRIGGER" -emailProperties "$EMAIL_PROPERTIES" -sendEmailPeriodically "$SEND_EMAIL_REPORT_PERIODICALLY" -sendEmailPeriodicallyTime "$SEND_EMAIL_REPORT_PERIODICALLY_TIME" -emailPasswordHidden "$EMAIL_PASSWORD_HIDDEN" -showPeriodicSummary "$SHOW_PERIODIC_SUMMARY" -tags $4

# Delete the staging folder on the Master
java -cp $TOP_LEVEL_FOLDER/lib/ant-sahi.jar in.co.sahi.distributed.DDelete -host $MASTER_HOST -port $MASTER_PORT -filePath $MASTER_STAGING_PATH/$UNIQUE_ID

# Pull the HTML logs from the Master onto the Initiator machine
java -cp $TOP_LEVEL_FOLDER/lib/ant-sahi.jar in.co.sahi.distributed.DPull -sourceHost $MASTER_HOST -sourcePort $MASTER_PORT -originFolder $MASTER_HTMLLOGS_DIR -destFolder $INITIATOR_OUTPUT_HTMLLOGS_DIR -ignorePattern $IGNORE_PATTERN

# If you have created logs of other types such as JUnit, add a DPull call for that logs type too

fi
