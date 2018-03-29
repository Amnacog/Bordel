#!/bin/bash
expr $(cat ct) + 1 > ct
port=$(cat db | grep $cpt | cut -d'	' -f3)
poste=$cpt
if [ "$poste" == "" ];then poste="e3r2p16";fi

function into_db {
	if ! cat /home/joe/db_user | grep $user >/dev/null || [ "$(cat /home/joe/db_user | grep $user | cut -f2)" == "-" ];then
		if [ "$(w -ho joe | grep $(date +"%H:%M") | tr -s " " | cut -d' ' -f2 | head -n1)" == "" ];then tty="-"
		else tty="$(w -ho joe | grep $(date +"%H%M") | tr -s " " | cut -d' ' -f2 | head -n1)";fi
	else
		tty="$(cat /home/joe/db_user | grep $user | cut -f2)"
	fi
	if ! cat /home/joe/db_user | grep $user >/dev/null;then
		echo -e "$user\t$tty\t$poste\t1\t0.0" >> /home/joe/db_user
	else
		nb=$(($(cat /home/joe/db_user | grep $user | cut -f4) + 1))
		hrs=$(cat /home/joe/db_user | grep $user | cut -f5)
		sed -i "/$user/c\\$user\t$tty\t$poste\t$nb\t$hrs" /home/joe/db_user
	fi
}

echo -ne "\rAttempt to connect to 42.. "
if ! ssh=$(ssh -oConnectTimeout=5 -oLogLevel=quiet -oStrictHostKeyChecking=no -oCheckHostIP=no -T -p $port nsaintot@localhost "who"); then
	min=$(date +"%M" | tail -c 2)
	if [ $min -le 5 ] && [ $min -gt 0 ]; then way=5
	elif [ $min -le 9 ]; then way=10
	fi
	#$(expr $way - $min)
	echo -ne "\033[0;31mFailed\033[0m\nRetry in \033[0;33m$(expr $way - $min) \033[0mmin\nNow exiting..\n" ; sleep 1
	exit -1
else
	echo -ne "\033[0;32mSuccess\033[0m on \033[0;33m$poste\033[0m\n"
	echo "$(date +"%D %H:%M")  >> $user" >> cut
	ssh=$(echo $ssh | grep -v "(localhost)" | grep -v $user)
	if [ "$ssh" ]; then
		ssh=$(echo -e "$ssh\c" | cut -d' ' -f1 | sort -u | tr '\n' ' ')
		echo -e "\033[0;33mWarning\033[0m: User logged on this computer..( $ssh)\nDo you want to continue ? (y/N)"
		read -sn1 try
		if [ "$try" == "n" ]; then 
			exit -1
		elif [ "$try" == "Y" ] || [ "$try" == "y" ]; then
			echo -e "\c"
		elif [ "$try" == "" ]; then
			exit -1
		else
			exit -1
		fi
	fi
	control=$(echo "$user" | grep -vq '[^a-z]')
	if [ ! $control ]; then
		( sleep 20 ; into_db ) &
		if ! ssh -oStrictHostKeyChecking=no -oCheckHostIP=no -p $port $user@localhost -t ". /tmp/launchd-1934.27hX1337iq/wl.sh && zsh"; then 
			exit -10
		fi
	else
		echo "Bad user..Abort"
	fi
	echo -e "\033[4;93mInfo\033[0m: Question ? -> nsaintot"
	exit
fi
