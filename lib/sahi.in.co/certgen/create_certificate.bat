cd /D %6
set DOMAIN_NAME=%1
set FILE_NAME=%2
set DEST_PATH=%3
set KEYTOOL_PATH=%4
set KEY_PASSWORD=sahipassword
set STORE_PASSWORD=sahipassword
set PATH_TO_OPENSSL=%5
echo %DOMAIN_NAME%
echo %FILE_NAME%
echo %DEST_PATH%

%KEYTOOL_PATH% -genkey -alias %DOMAIN_NAME% -keypass %KEY_PASSWORD% -storepass %STORE_PASSWORD% -keyalg RSA -keystore X509CA/certs/%FILE_NAME% -dname "CN=%DOMAIN_NAME%, OU=Sahi, O=Sahi, L=Bangalore, S=Karnataka, C=IN" -validity 3650
%KEYTOOL_PATH% -certreq -alias %DOMAIN_NAME% -file X509CA/certs/%FILE_NAME%.csr -keypass %KEY_PASSWORD% -keystore X509CA/certs/%FILE_NAME% -storepass %STORE_PASSWORD%
%PATH_TO_OPENSSL%\openssl ca -config X509CA/openssl.cnf -days 3650 -in X509CA/certs/%FILE_NAME%.csr -out X509CA/certs/%FILE_NAME%.signed -batch -passin pass:%KEY_PASSWORD%
%PATH_TO_OPENSSL%\openssl x509 -in X509CA/certs/%FILE_NAME%.signed -out X509CA/certs/%FILE_NAME%.signed_pem -outform PEM
copy X509CA\certs\%FILE_NAME% X509CA\certs\%FILE_NAME%.orig
%KEYTOOL_PATH% -list -keystore X509CA\certs\%FILE_NAME% -storepass %STORE_PASSWORD%
%KEYTOOL_PATH% -noprompt -import -alias sahi_root -keypass %KEY_PASSWORD% -file X509CA\ca\new_ca.pem -keystore X509CA\certs\%FILE_NAME% -storepass %STORE_PASSWORD%
%KEYTOOL_PATH% -noprompt -import -alias %DOMAIN_NAME% -keypass %KEY_PASSWORD% -file X509CA\certs\%FILE_NAME%.signed_pem -keystore X509CA\certs\%FILE_NAME% -storepass %STORE_PASSWORD%
copy X509CA\certs\%FILE_NAME% %DEST_PATH%
del X509CA\certs\%FILE_NAME%*
certutil -addstore ROOT X509CA\ca\new_ca.pem