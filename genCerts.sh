##################################################################################
# x509 certificates generation for MongoDB
# this script will create a CA, server and client certificates
# do not use this in production environments!
##################################################################################
## CA ##
#genCA=true to implement
. conf.sh
## INFOS ## 

## LIST OF THE CLIENTS IN NEED OF A CERTIFICATE
# mongodb_client_hosts=( "mongodb-node1" "mongodb-node2" "mongodb-node3" "ilians-macbook" )

## SERVER LIST FOR CERTIFICATE GENERATION
## The configuration is JSON based in order to manage subject alternative names in a dynamic way, modify it accordingly to your needs

##################################################################################
mkdir ${DEST_CRT}
cp hosts ${DEST_CRT}/
cd ${DEST_CRT}



echo "######################################################################################"
echo "##### STEP 2: Create server certificates"

# Now create & sign keys for each mongod server 
# Pay attention to the OU part of the subject in "openssl req" command
# You may want to use FQDNs instead of short hostname


while read p; do
  host=$(echo "$p")
  alt=$(echo "${p%%.*}")
  echo "######################################################################################"
  echo "Generating certificate for server $host"
  cat > "csr_details_${host}.cfg" <<-EOF
		[req]
		default_bits = 2048
		prompt = no
		default_md = sha256
		distinguished_name = req_dn
		req_extensions = v3_req

		[ req_dn ] 
		C=${C}
		ST=${ST}
		L=${L}
		O=${O}
		OU=${ou_member}
		CN=${host}

		[ v3_req ]
		subjectKeyIdentifier  = hash
		basicConstraints = CA:FALSE
		keyUsage = critical, digitalSignature, keyEncipherment
		nsComment = "OpenSSL Generated Certificate for TESTING only.  NOT FOR PRODUCTION USE."
		extendedKeyUsage  = serverAuth, clientAuth
		subjectAltName=@alt_names

		[ alt_names ]
		DNS.1 = ${alt}
		DNS.2 = ${host}
	EOF
    # Create the key file mongodb-test-server1.key.
    openssl genrsa -out ${host}.server.key 4096

    # Create the  certificate signing request 
    openssl req -new -key ${host}.server.key -out ${host}.server.csr -config csr_details_${host}.cfg

    # Create the server certificate 
    openssl x509 -sha256 -req -days 365 -in ${host}.server.csr -CA ../ca/mongodb-ia.crt -CAkey ../ca/mongodb-ia.key -CAcreateserial -out ${host}.server.crt -extfile csr_details_${host}.cfg -extensions v3_req

    # combine all together
    cat ${host}.server.crt ${host}.server.key > ${host}.server.pem

    mkdir ../$DEST_OUT/$alt
    cp ../$DEST_OUT/$CAFILE ../$DEST_OUT/$alt
    cp  ${host}.server.pem ../$DEST_OUT/$alt/server.pem

done < hosts
