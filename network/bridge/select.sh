#!/bin/bash
channels=( x x x x x x x x x x x x x x x )
online=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
esc=$(echo -en "\033")
maxcol=$(tput cols)
maxlin=$(tput lines)
curline=0
if ! cat /home/joe/db_user | grep nsaintot >/dev/null; then curnum=0;else curnum=-1;fi
otime=0
tput civis

#build db
i=0
while read f ;do
	if ! echo $f | grep "#" >/dev/null; then
		channels[$i]="$(echo $f | cut -d' ' -f1)"
		online[$i]=$(echo $f | cut -d' ' -f2)
		((i++))
	fi
done < /home/joe/db

if ! echo ${online[@]} | grep "1" >/dev/null;then colorb=1;elif ! echo ${online[@]} | grep "0" >/dev/null;then colorb=2;else colorb=3;fi
. /home/joe/include/00-header

function selectable {
	tput sc
	i=0
	echo -ne "\r"
	while [ "${channels[$i]}" ]; do
		if [ "${channels[$i]}" == "$favcpt" ];then
			favc=33
			fav=4
			if [ $otime -eq 0 ];then
				curnum=$i;
				otime=1
			fi
		else
			favc=32
			fav=0
		fi
		if [ $i -eq $curnum ] && [ ${online[$i]} -eq 1 ];then
			echo -ne "\033[1;32;7m"
		elif [ $i -eq $curnum ] && [ ${online[$i]} -eq 0 ];then
			echo -ne "\033[1;31;7m"
		elif [ ${online[$i]} -eq 1 ]; then
			echo -ne "\033[$fav;$favc\0m"
		elif [ ${online[$i]} -eq 0 ]; then
			echo -ne "\033[$fav;31m"
		fi
		echo -ne "${channels[$i]}"
		curchan=${channels[$i]}
		echo -ne "\033[0m$(printf %$((10 - ${#curchan}))s)"
		((i++))
	done
	echo -ne "\c"
	tput rc
}

function selected {
	if [ ${online[$curnum]} -eq 1 ];then
		tput cnorm
		cpt=${channels[$curnum]}
	fi
}

function curpos {
	echo -en "\E[6n"
	read -sdR cur
	cur=${cur#*[}
	curlin=$(echo $cur | cut -d';' -f1)
	curcol=$(echo $cur | cut -d';' -f2)
	#tput sc ; tput cup 0 $(($maxcol - 10)) ; echo "$curnum $cur    " ; tput rc
}

function prevsel {
	((curnum--))
	while [ ${online[$curnum]} -ne 1 ];do
		((curnum--))
	done
}

function nextsel {
	((curnum++))
	while [ ${online[$curnum]} -ne 1 ];do
		((curnum++))
	done
}

function readkey {
	read -s -n3 key 2>/dev/null >&2 
	if [ "$key" = "$esc[A" ] && [ $((curnum - 5)) -ge 0 ];then curnum=$((curnum - 7))				#A  up
	elif [ "$key" = "$esc[B" ] && [ $((curnum + 5)) -le $(($i - 1)) ];then curnum=$((curnum + 7))	#B  down
	elif [ "$key" = "$esc[C" ] && [ $curnum -lt $(($i - 1)) ];then nextsel							#C  right
	elif [ "$key" = "$esc[D" ] && [ $curnum -gt 0 ];then prevsel									#D  left
	elif [ "$key" = "" ]; then selected; fi
} 2>/dev/null

while [ -z "$cpt" ];do
	selectable
	if ! echo ${online[@]} | grep "1" >/dev/null;then
		echo -e "\n\033[31mError\033[0m: No unit available"
		exit -1
	fi
	curpos
	readkey
done
tput cnorm
