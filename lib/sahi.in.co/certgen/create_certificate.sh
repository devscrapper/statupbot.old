cd $5
export DOMAIN_NAME=$1
export FILE_NAME=$2
export DEST_PATH=$3
export KEYTOOL_PATH=$4
export KEY_PASSWORD=sahipassword
export STORE_PASSWORD=sahipassword

echo $DOMAIN_NAME
echo $FILE_NAME
echo $DEST_PATH

$KEYTOOL_PATH -genkey -alias $DOMAIN_NAME -keypass $KEY_PASSWORD -storepass $STORE_PASSWORD -keyalg RSA -keystore X509CA/certs/$FILE_NAME -dname "CN=$DOMAIN_NAME, OU=Sahi, O=Sahi, L=Bangalore, S=Karnataka, C=IN" -validity 3650
$KEYTOOL_PATH -certreq -alias $DOMAIN_NAME -file X509CA/certs/$FILE_NAME.csr -keypass $KEY_PASSWORD -keystore X509CA/certs/$FILE_NAME -storepass $STORE_PASSWORD
openssl ca -config X509CA/openssl.cnf -days 3650 -in X509CA/certs/$FILE_NAME.csr -out X509CA/certs/$FILE_NAME.signed -batch -passin pass:$KEY_PASSWORD
openssl x509 -in X509CA/certs/$FILE_NAME.signed -out X509CA/certs/$FILE_NAME.signed_pem -outform PEM
cp X509CA/certs/$FILE_NAME X509CA/certs/$FILE_NAME.orig
$KEYTOOL_PATH -list -keystore X509CA/certs/$FILE_NAME -storepass $STORE_PASSWORD
$KEYTOOL_PATH -noprompt -import -alias sahi_root -keypass $KEY_PASSWORD -file X509CA/ca/new_ca.pem -keystore X509CA/certs/$FILE_NAME -storepass $STORE_PASSWORD
$KEYTOOL_PATH -noprompt -import -alias $DOMAIN_NAME -keypass $KEY_PASSWORD -file X509CA/certs/$FILE_NAME.signed_pem -keystore X509CA/certs/$FILE_NAME -storepass $STORE_PASSWORD
cp X509CA/certs/$FILE_NAME $DEST_PATH
rm X509CA/certs/$FILE_NAME* 
