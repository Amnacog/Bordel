#!/bin/bash 

key="`openssl rand -base64 39 | tr -d '/' | tr -d '+'`"
echo "$key" | tee -a /var/lib/joe/index
bash -c "(sleep 120 ; sed -i "/$key/d" /var/lib/joe/index)&"
