#!/bin/bash
if [ $# -lt 3 ] 
then
echo "Usage: ./testrunner.sh <sah file|suite file> <startURL> <browserType> <tags>"
echo "File path is relative to userdata/scripts"
echo Multiple browsers can be specified using +. Eg. firefox+safari
echo tags are used only if the input file is a .csv file, .s.csv file or a .dd.csv file
echo "Example:" 
echo "$0 demo/demo.suite http://sahitest.com/demo/ firefox"
echo "$0 demo/sahi_demo.sah http://sahitest.com/demo/ firefox"
echo "$0 demo/sahi_demo.sah http://sahitest.com/demo/ firefox+safari"
echo "$0 demo/demo.dd.csv http://sahitest.com/demo/ firefox \"linux||all\""
echo "$0 demo/testcases/testcases_sample.csv http://sahitest.com/demo/ firefox \"(admin||user)&&medium\""
echo "$0 demo/ddcsv/test.dd.csv http://sahitest.com/demo/ firefox \"(admin||user)&&medium\""
echo "$0 demo/framework/sample.xls http://sahitest.com/demo/training/ firefox"
echo "$0 demo/framework/scenario_new.s.csv http://sahitest.com/demo/training/ firefox \"all\""
else

export SAHI_HOME=../..
export USERDATA_DIR=../
export SCRIPTS_PATH=scripts
export BROWSER=$3
export START_URL=$2
export THREADS=5
export SINGLE_SESSION=false
export LOGS_INFO=html
export SEND_EMAIL_REPORT=false
export EMAIL_TRIGGER=success,failure
export EMAIL_PROPERTIES=../config/email.properties
export EMAIL_PASSWORD_HIDDEN=true

# Set SEND_EMAIL_REPORT_PERIODICALLY to true if email is to be sent after particular interval of time
export SEND_EMAIL_REPORT_PERIODICALLY=
# Set SEND_EMAIL_REPORT_PERIODICALLY_TIME indicates time(minutes) interval after which email will be sent.
export SEND_EMAIL_REPORT_PERIODICALLY_TIME=

# SHOW_PERIODIC_SUMMARY enables printing of script status update in the console
export SHOW_PERIODIC_SUMMARY=true

. ./setjava.sh
#export CUSTOM_FIELDS=-customField customValue -anotherCustomField "another value"
java -cp $SAHI_HOME/lib/ant-sahi.jar in.co.sahi.distributed.DSahiRunner $CUSTOM_FIELDS -isNonDistributedRun true -scriptsPathMaster $SCRIPTS_PATH -suite $1 -browserType "$BROWSER" -logsInfo "$LOGS_INFO" -baseURL $START_URL -host localhost -port 9999 -threads $THREADS -useSingleSession $SINGLE_SESSION -sendEmail $SEND_EMAIL_REPORT -emailTrigger "$EMAIL_TRIGGER" -emailProperties "$EMAIL_PROPERTIES" -sendEmailPeriodically "$SEND_EMAIL_REPORT_PERIODICALLY" -sendEmailPeriodicallyTime "$SEND_EMAIL_REPORT_PERIODICALLY_TIME" -emailPasswordHidden "$EMAIL_PASSWORD_HIDDEN" -showPeriodicSummary "$SHOW_PERIODIC_SUMMARY" -tags $4
fi
