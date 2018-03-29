#!/bin/sh

rm ssl 2>/dev/null
mkdir ssl
cd ssl
openssl genrsa 2048 > host.key
openssl req -new -x509 -nodes -sha256 -days 3650 -key host.key > host.cert
openssl x509 -noout -fingerprint -text < host.cert > host.info
cat host.cert host.key > host.pem
chmod 400 host.key host.pem
