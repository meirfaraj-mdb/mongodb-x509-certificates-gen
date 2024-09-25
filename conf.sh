##################################################################################
# x509 certificates generation for MongoDB
# this script will create a CA, server and client certificates
# do not use this in production environments!
##################################################################################
## CA ##
#genCA=true to implement
CAFILE="ca-chain.pem"
#replace XXX
CA_NAME="XXX-ROOT-CA"
DEST="ca"
DEST_CRT="crt"
DEST_OUT="out"
DAYS_ROOT_CA=1826
DAYS_INTERMEDIATE_CA=730
DAYS_SERVER_CERTS=1826
DAYS_CLIENT_CERTS=1826

## INFOS ## 
C="FR" # country code
ST="Paris" # state
L="Paris"  # lieu
#replace XXX
O="XXX" # company name
#and replace XXX
OU="XXX"

ou_member="MongoDB-Server" #organization unit for mongod processes
ou_client="MongoDB-Client" #organization unit for client (drivers, agents)

dn_prefix="/C=$C/ST=$ST/L=$L/O=$O"

