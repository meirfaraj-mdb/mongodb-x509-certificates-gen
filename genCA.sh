##################################################################################
# x509 certificates generation for MongoDB
# this script will create a CA, server and client certificates
# do not use this in production environments!
##################################################################################

. conf.sh


##################################################################################
mkdir ${DEST}
mkdir  ${DEST_OUT}
cd ${DEST}

echo "######################################################################################"
echo "##### STEP 1: Generate ROOT CA & INTERMEDIATE CA "

# Generate CA config
cat >> mongodb-ca.cfg <<EOF
[ policy_match ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ req ]
default_bits = 4096
default_keyfile = myTestCertificateKey.pem    ## The default private key file name.
default_md = sha256                           ## Use SHA-256 for Signatures
req_extensions = v3_req
x509_extensions = v3_ca # The extentions to add to the self signed cert
distinguished_name = req_dn

[ v3_req ]
subjectKeyIdentifier  = hash
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
nsComment = "OpenSSL Generated Certificate"
extendedKeyUsage  = serverAuth, clientAuth

[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:true
authorityKeyIdentifier=keyid:always,issuer:always

[ req_dn ] 
C=${C}
ST=${ST}
L=${L}
O=${O}
OU=${OU}
EOF

# ca key
openssl genrsa -out mongodb-ca.key 4096

# cert ca gen
openssl req -new -x509 -days $DAYS_ROOT_CA -key mongodb-ca.key -out mongodb-ca.crt -config mongodb-ca.cfg -subj "$dn_prefix/CN=$CA_NAME"

# intermediate key
openssl genrsa -out mongodb-ia.key 4096

# certificate signing request for the intermediate certificate
openssl req -new -key mongodb-ia.key -out mongodb-ia.csr -config mongodb-ca.cfg -subj "$dn_prefix/CN=INTERMEDIATE-CA"

# Create the intermediate certificate
openssl x509 -sha256 -req -days $DAYS_INTERMEDIATE_CA -in mongodb-ia.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -set_serial 01 -out mongodb-ia.crt -extfile mongodb-ca.cfg -extensions v3_ca

# Create the CA PEM file
cat mongodb-ca.crt mongodb-ia.crt  > $CAFILE

cp $CAFILE ../$DEST_OUT/$CAFILE
cd ..

