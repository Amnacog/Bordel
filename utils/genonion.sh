#!/bin/bash

/usr/local/bin/scallion.exe --skip-sha-test --output=.tmp/genonion "42" >/dev/null 2>&1

output="`echo "cat /XmlMatchOutput/PrivateKey/text()|/XmlMatchOutput/Hash/text()" | xmllint --shell .tmp/genonion | sed '/^\/ >/d' | sed 's/<[^>]*.//g'`"
rm .tmp/genonion
echo ".onion"
echo "`echo "$output" | head -n2 | tail -n1`"
echo "PrivateKey"
echo "`echo "$output" | tail -n +4`"
