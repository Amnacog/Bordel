#!/bin/bash
cd `dirname $0`
if [ "$1" == "listen" ];then
	while :;do
		port="`cat masterport | tr '[7-90-6]' '[0-9]'`"
		nc -d localhost $port |while read a;do
			echo -n "U2FsdGVkX1$a" | tr "\`" "\n" | openssl enc -aes-128-cbc -a -d -salt -pass pass:$(date +"%H%M")$port 2>/dev/null
		done
	done
elif [ "$1" == "talk" ];then 
	while read -p "console>" a; do
		port="`cat masterport | tr '[7-90-6]' '[0-9]'`"
		echo "$a" | openssl enc -aes-128-cbc -a -salt -pass pass:$(date +"%H%M")$port | tr "\n" "\`" | awk '{print $0}' | sed "s/U2FsdGVkX1//g" | nc localhost $port
	done
elif [ "$1" == "start" ];then
	if [ -f .console.pid ]; then
		pid=`cat .console.pid 2>/dev/null`
		if ps aux | grep $pid >/dev/null; then echo pid already started ; exit; fi
	fi
	rm .console.pid 2>/dev/null
	./console.sh listen | while read a; do
		if [ ${#a} -ge 80 ]; then a="`echo $a | cut -c1-80`.."; fi
		if echo $a | grep "open\|close" >/dev/null; then carret=5 ;elif echo $a | grep "tunnel" >/dev/null; then carret=4; fi
		if echo $a | grep "open\|close\|tunnel" >/dev/null ; then a="$(echo $a | awk -F ' ' -v OFS=' ' '{$'$carret'="*****"; print }')"; fi
		echo "<div class="log">$a<u>`date +"%H:%M:%S"`<span>`date +"%Y-%m-%d"`</span></u></div>" | grep -v "KeepAlive" >> /var/www/joe/mlog
	done &
	echo -n "$! `pgrep -f $0 | tr "\n" " "`" > .console.pid
	echo pid started
elif [ "$1" == "stop" ]; then
	pid=`cat .console.pid 2>/dev/null`
	if ! kill -9 $pid >/dev/null 2>&1; then echo no such pid;else echo pid stopped; fi
	rm .console.pid 2>/dev/null
else
	echo "Usage: console.sh <listen|talk - start - stop>"
fi
