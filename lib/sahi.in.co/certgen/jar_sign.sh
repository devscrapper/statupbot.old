export ORIG_JAR=$1
export SIGNED_JAR=$2
export KEYSTORE=$3
export DOMAIN=$4
export PASSWORD=$5
export JARSIGNER_PATH=$6
$JARSIGNER_PATH -keystore $KEYSTORE -storepass $PASSWORD -signedjar $SIGNED_JAR $ORIG_JAR $DOMAIN
