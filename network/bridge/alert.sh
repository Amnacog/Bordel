#!/bin/bash
t=60
x=0
format="sec"

function show {
	for i in $(who | grep joe);do
		if echo $i | grep pts >/dev/null;then
			tput sc >/dev/$i
			tput cup 0 100 >/dev/$i
			if [ $t -ne 0 ];then echo -ne "\033[33mNotice\033[0m: Tunnel will reset in $t$format " >/dev/$i;
			else printf "%35s";fi
			tput rc >/dev/$i
		fi
	done
}

show;sleep 30 ;t=30;show;sleep 10;t=20;show;sleep 10;t=10
x=1
while [ $t -gt -1 ];do
	show
	((t--))
	sleep 1
done
