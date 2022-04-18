#!/usr/bin/bash
DIR="$(mktemp -d)"
cd "${DIR}"

# Record the ip address (If a Domain Name is going to be used that could work)
ip route get 1 # ifconfig is another option

LOCALIP="192.168.1.17"
NAME="ryansPC"
DESC="MyPC"

# Create a key
openssl genrsa -out "${NAME}.key" 2048

# Create the Certificate (to work with iOS)
openssl req -new -x509 -sha256     \
    -key "${NAME}.key"                 \
    -out "${NAME}.cer"                 \
    -days 800                      \
    -subj /CN=${DESC}                \
    -addext  "subjectAltName = IP:${LOCALIP}" # No Port number
    

echo -e "\n\nSuccessfully created ssl/key/value pair.\n"
echo -e "${DIR}:\n$(ls ${DIR})"
