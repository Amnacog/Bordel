#!/bin/bash
##nsaintot
cd `dirname $0`
logins="`cat ../logins`"
crawler="https://dashboard.42.fr/crawler/pull/"
takecpt="" ; total=`echo $logins | wc -w` ; i=0
for uid in $logins; do
	res=`curl -sLk "${crawler}$uid"`
	if ! echo $res | grep "error" >/dev/null; then takecpt="$takecpt `echo $res | cut -d '"' -f6 | cut -d'.' -f1`"; fi
	echo -ne "\r$((100 * i / total))%\c"
	((i++))
done
echo $takecpt | tr '[a-z]' '[g-za-f]' | tr '[0-9]' '[5-90-4]' | tr ' ' '@' | tr " " "\n" | sort | tr "\n" " " | tee usedcpt >/dev/null && echo >> usedcpt
