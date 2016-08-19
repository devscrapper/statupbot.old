#!/bin/bash
if [ $# -ne 4 ] 
then
echo "Usage: ./dload.sh <noise sah file> <subject sah file> <startURL> <browserType>"
echo "File path is relative to userdata/scripts"
echo "--"
echo "Example:" 
echo "./dload.sh demo/load/noise.sah demo/load/subject.sah http://sahitest.com/demo/training/ firefox"
echo "--"

else
export SAHI_HOME=../..
export USERDATA_DIR=../
. ./setjava.sh
export ORIG_SCRIPTS_PATH=scripts
export START_URL=$3
# SET NODES=localhost:9999,othermachine:9999,thirdmachine:9999
export NODES=localhost:9999

# LOGS_INFO format is type:filePath
# SET LOGS_INFO=html:D:/logs/html
export LOGS_INFO=html

java -cp $SAHI_HOME/lib/ant-sahi.jar in.co.sahi.distributed.DLoadRunner -scriptsPathMaster $ORIG_SCRIPTS_PATH -noise $1 -noiseBrowserType phantomjs -min 1 -max 9 -incrementBy 2 -interval 5 -subject $2 -subjectRepeatCount 3 -browserType $4 -logsInfo "$LOGS_INFO" -baseURL "$START_URL" -host localhost -port 9999 -nodes "$NODES" -ignorePattern ".*(svn|copied).*"
fi
