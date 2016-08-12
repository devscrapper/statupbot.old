openssl req -x509 -new -config X509CA/openssl.cnf -days 3650 -out X509CA/ca/new_ca.pem -keyout X509CA/ca/new_ca_pk.pem
openssl x509 -in X509CA/ca/new_ca.pem -inform PEM -out X509CA/ca/new_ca.crt
openssl x509 -in X509CA/ca/new_ca.pem -inform PEM -out X509CA/ca/new_ca.der -outform DER
