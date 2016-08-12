cd $(dirname $0)
UPGRADE_TO=$1
cp upgrade-sahi.jar upgrade-sahi2.jar
cp ../extlib/license/truelicense.jar ../extlib/license/truexml.jar ../extlib/apc/commons-codec-1.3.jar . 
java -cp upgrade-sahi2.jar:truelicense.jar:truexml.jar:commons-codec-1.3.jar in.co.sahi.upgrade.SahiUpgradeClient $UPGRADE_TO >log.txt
rm upgrade-sahi2.jar truelicense.jar truexml.jar commons-codec-1.3.jar
cd ../userdata/bin
./start_dashboard.sh
