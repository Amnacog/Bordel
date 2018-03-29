#!/bin/bash
key="`openssl rand -base64 39 | tr -d '/' | tr -d '+'`"
echo "$key" | tee -a /var/www/joe/index
if [ ! "$1" == "-p" ]; then bash -c "(sleep 120 ; sed -i "/$key/d" /var/www/joe/index)&"; fi
