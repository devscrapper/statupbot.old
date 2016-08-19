#!/bin/bash

# This shell script is used for registering an external node in the middle of a distributed run.

if [ $# -lt 1 ] 
then
echo "Usage: register_nodes.sh <extnodes> <userDefinedId> <suiteId>"
echo "- extnodes is a comma separated string of host:port combos, example: \"machine1:9999,machine2:9999\". If multiple nodes are specified, enclose them in double quotes."
echo "- userDefinedId is the User defined Id specified while running the original suite"
echo "- suiteId is the SuiteId of the running suite, and can be found from Suite Info section in the Suite Report log"
echo "- NOTE: Only one of suiteId or userDefinedId is required. If both suiteId and userDefinedId are passed, suiteId will be used to identify the running suite."
echo "--"
echo "Example:"
echo "1. Registering one machine using userDefinedId (say abc1234)."
echo
echo $0 machine1:9999 abc1234
echo
echo "2. Registering more than one machine using userDefinedId."
echo
echo $0 \"machine1:9999,machine2:9999\" abc1234
echo
echo "3. Registering one machine using suiteId (say sahi_a0ba301605a8f04cb10881e0ddcd96f9dfbd). NOTE: Some value HAS to be passed for the second parameter - userDefinedId. Pass \"\"."
echo
echo $0 machine1:9999 \"\" sahi_a0ba301605a8f04cb10881e0ddcd96f9dfbd
echo
echo "4. Registering more than one machine using suiteId. NOTE: Some value HAS to be passed for the second parameter - userDefinedId. Pass \"\"."
echo
echo $0 \"machine1:9999,machine2:9999\" \"\" sahi_a0ba301605a8f04cb10881e0ddcd96f9dfbd
echo "--"
else

export SAHI_HOME=../..
. ./setjava.sh

# MASTER_HOST refers to the machine that serves as the Master. This can be different than localhost.
export MASTER_HOST=localhost
export MASTER_PORT=9999

export SUITEID="$3"

if [ $# -ge 2 ]; then
	if [ "$2" ]; then
		export USERDEFINEDID="$2"
	else
		export USERDEFINEDID='""'
	fi
fi

java -cp $SAHI_HOME/lib/ant-sahi.jar in.co.sahi.distributed.DNodeClient -action registerNodes -host $MASTER_HOST -port $MASTER_PORT -extNodes $1 -userDefinedId $USERDEFINEDID -suiteId $SUITEID

fi
