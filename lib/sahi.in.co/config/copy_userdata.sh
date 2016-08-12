echo Copying necessary files ...
export SAHI_JAVA_HOME=$JAVA_HOME
export PATH=$SAHI_JAVA_HOME/bin:$PATH
export SAHI_HOME=$1
export SOURCE=$SAHI_HOME/config/userdata_template
export DESTINATION=$SAHI_HOME/userdata
java -cp $SAHI_HOME/lib/sahi.jar net.sf.sahi.installer.PostInstall $SOURCE $DESTINATION
echo Done
