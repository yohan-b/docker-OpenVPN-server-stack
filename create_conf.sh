#!/bin/bash
mkdir -p conf
cd conf
openssl req -nodes -days 3650 -new -x509 -keyout ca.key -out ca.crt -subj "/C=FR/O=scimetis/CN=scimetis.net" 
openssl dhparam -out dh1024.pem 1024

openssl req -nodes -new -keyout server.key -out server.csr -subj "/C=FR/O=scimetis/CN=ovh1.scimetis.net" -reqexts server -config ../openssl.conf
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -extensions server -extfile ../openssl.conf -in server.csr -out server.crt

openssl req -nodes -new -keyout client.key -out client.csr -subj "/C=FR/O=scimetis/CN=serveur.scimetis.net" -reqexts usr_cert -config ../openssl.conf
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -extensions usr_cert -extfile ../openssl.conf -in client.csr -out client.crt

openssl req -nodes -new -keyout client2.key -out client2.csr -subj "/C=FR/O=scimetis/CN=serveur-appart.scimetis.net" -reqexts usr_cert -config ../openssl.conf
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -extensions usr_cert -extfile ../openssl.conf -in client2.csr -out client2.crt

chcon -R -u system_u -r object_r -t svirt_sandbox_file_t ./
mkdir keys
mkdir ccd
cp -a ca.crt ca.srl dh1024.pem server.crt server.key keys/
echo "ifconfig-push 192.168.102.10 255.255.255.0" > "ccd/serveur.scimetis.net"
echo "ifconfig-push 192.168.102.3 255.255.255.0" > "ccd/serveur-appart.scimetis.net"
cd ..
