#!/bin/bash
channels=( e3r2p16 e3r2p15 e3r2p14 e3r2p13 e3r2p12 e3r2p11 e3r2p10 e3r2p9 e3r3p8 e3r3p9 e3r3p10 e3r3p11 e3r3p12 e3r3p13 e3r3p14 )
online=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
esc=$(echo -en "\033")
maxcol=$(tput cols)
maxlin=$(tput lines)
curline=0
curnum=0
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

function selectable {
	tput sc
	i=0
	echo -ne "\r"
	while [ "${channels[$i]}" ]; do
		if [ $i -eq $curnum ] && [ ${online[$i]} -eq 1 ];then
			echo -ne "\033[1;4;32;7m"
		elif [ $i -eq $curnum ] && [ ${online[$i]} -eq 0 ];then
			echo -ne "\033[1;4;31;7m"
		elif [ ${online[$i]} -eq 1 ]; then 
			echo -ne "\033[5;32m"
		elif [ ${online[$i]} -eq 0 ]; then
			echo -ne "\033[0;31m"
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
	if [ "$key" = "$esc[A" ] && [ $((curnum - 7)) -ge 0 ];then tput cup $(($curlin - 1)) $(($curcol - 71)) ; curnum=$((curnum - 7))			#A  up
	elif [ "$key" = "$esc[B" ] && [ $((curnum + 7)) -le $(($i - 1)) ];then tput cup $(($curlin - 1)) $(($curcol + 69)) ; curnum=$((curnum + 7))	#B  down
	elif [ "$key" = "$esc[C" ] && [ $curnum -lt $(($i - 1)) ];then tput cup $(($curlin - 1)) $(($curcol + 9)); nextsel			#C  right
	elif [ "$key" = "$esc[D" ] && [ $curnum -gt 0 ];then tput cup $(($curlin - 1)) $(($curcol - 11)) ; prevsel				#D  left
	elif [ "$key" = "" ]; then selected; fi
} 2>/dev/null

while [ -z "$cpt" ];do
	selectable
	curpos
	readkey
done
tput cnorm
