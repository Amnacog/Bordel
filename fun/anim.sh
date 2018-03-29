#!/bin/bash
tput civis
trap "tput cnorm;exit" INT
if [ "$1" == "-1" ]; then
tput civis
	msg="Loading..."
# Determine the number of lines and columns for the terminal
eval "`resize`"
# Calculate the indent
length=`expr \( $COLUMNS - ${#msg} \) / 2`
indent=`printf "%${length}s"`

a="`echo $msg|sed 's#.#.#g'`"
b="`echo $msg|sed 's#.#o#g'`"
c="`echo $msg|sed 's#.#O#g'`"
d="`echo $msg|sed 's#.#o#g'`"
e="`echo $msg|sed 's#.#\\\b#g'`"

printf "$indent$msg\n"

for n in `jot -r 50`
do
	for x in $a $b $c $d
	do
		printf "$indent%b%b" $x $e
		sleep 0.1
		printf "\r"
	done
done
tput cnorm
elif [ "$1" == "-2" ]; then
	while true
	do
		printf "\r LOADING ... -";
		sleep 0.2 ;
		printf "\r LOADING ... \\";
		sleep 0.2 ;
		printf "\r LOADING ... |";
		sleep 0.2 ;
		printf "\r LOADING ... /";
		sleep 0.2;
	done
elif [ "$1" == "-3" ]; then
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'

elif [ "$1" == "-4" ]; then
anim=( "| " "/ " "--" "\ " "| " "/ " "--" "\ " "| " )
i=0
while :; do
	tput sc ; tput civis
	while [ $i -lt 11 ]; do
		tput cup 0 $(($(tput cols)- 2))
		echo -e "\033[1;33m${anim[$i]}"
		sleep 0.1
		((i++))
	done
	i=0
	tput rc ; tput cnorm
done
elif [ "$1" == "-5" ]; then
tput civis
	anim1=( "| " "/ " "--" "\\ " )
	anim2=( " |" " /" "--" " \\" )
	i=0;x=0;j=0
	while :; do
		if [ $i -eq 19 ]; then j=1; elif [ $i -eq -1 ]; then j=0;fi
		if [ $j -eq 0 ];then
			if [ $x -eq 4 ]; then x=0 ; fi
			col="\033[33;4m"
		echo -ne "\r\t\t\t$(printf "%${i}s")$col${anim1[$x]} \c"
		else
			if [ $x -eq -1 ]; then x=4; fi
			col="\033[35;4m"
		echo -ne "\r\t\t\t$(printf "%${i}s")$col${anim2[$x]} \c"
fi
		if [ $j -eq 0 ]; then ((i++)) ; ((x++)) ;else ((i--)) ; ((x--));fi
		sleep 0.05
	done
tput cnorm
elif [ "$1" == "-6" ]; then
tput civis
	i=0
	x=0
	while :; do
		if [ $i -eq 10 ]; then x=1 ;elif [ $i -eq 0 ];then x=0 ;fi
		echo -e "\r$msginfo Retriew home.. \033[0;33mSynchronize Home $(printf "%$(echo $i)s" | tr ' ' '-') \c"
		if [ $x -eq 0 ]; then ((i++)); else ((i--));fi
		sleep 0.01
	done
tput cnorm
elif [ "$1" == "-7" ];then
tput civis
sprite=( "(<" "(-" "▪" )
i=0
x=0
	echo -ne "\033[33m  ▪ ▪ ▪ ▪  ▪  ▪ ▪ ▪   ▪ ▪ ▪   ▪   ▪   ▪▪  ▪ \033[0m"
	while :;do
		if [ $(($i % 2)) -eq 1 ]; then a=0; else a=1;fi
		echo -ne "\r$(printf "%${x}s")\033[0;33m${sprite[$a]}\033[0m\c"
		if [ $(($i % 2)) -eq 1 ]; then ((x++)); fi
		((i++))
		sleep 0.07
	done
tput cnorm
elif [ "$1" == "-8" ];then
	j=0;a=1;x=1;y=1;xd=1;yd=1
	while true;do
		for i in {1..10};do
			if [[ $x == $LINES || $x == 0 ]]; then
				xd=$(( $xd *-1 ))
			fi
			if [[ $y == $COLUMNS || $y == 0 ]]; then 
				yd=$(( $yd * -1 ))
			fi
			x=$(( $x + $xd ))
			y=$(( $y + $yd ))
			printf "\33[%s;%sH\33[48;5;%sm  \33[0m" $x $y $(( $a % 8 + 16 + $j % 50 )) #>> ~/42/scripts/.tmp/live_anim
			((a++))
		done
		x=$(( x%$COLUMNS + 1 ))
		j=$(( $j + 8 ))
	done
fi
