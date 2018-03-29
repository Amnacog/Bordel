#!/bin/bash
i=0

#check connectivity
while read l; do
	if ! echo $l | grep "#" >/dev/null;then
		cpt=$(echo $l | cut -d' ' -f1)
		port=$(echo $l | cut -d' ' -f3)
		if sudo netstat -tulpn | grep "$port" >/dev/null;then
			echo -e "$cpt\t\033[0;32mOK"
			#echo -e "$cpt\t1\t$port"
			on=1
		else
			echo -e "$cpt\t\033[0;31mKO"
			#echo -e "$cpt\t0\t$port"
			on=0
		fi
		echo -en "\033[0m"
		sudo sed -i "/$cpt/c\\$cpt\t$on\t$port" /home/joe/db
	fi
done < /home/joe/db

#check connected users
while read u; do
	if ! echo $u | grep "#" >/dev/null;then
		user=$(echo $u | cut -d' ' -f1)
		tty=$(echo $u | cut -d' ' -f2)
		cpt=$(echo $u | cut -d' ' -f3)
		nb=$(echo $u | cut -d' ' -f4)
		hrs=$(echo $u | cut -d' ' -f5)
		echo -ne "\033[0m"
		if ps -eo tty,args | tr -s " " | grep -v grep | grep $user >/dev/null && [ "$tty" != "-" ];then
			if [ $(echo $hrs | cut -d'.' -f2) -eq 60 ]; then
				echo -ne "\033[0;32m"
				hrs="$(($(echo $hrs | cut -d'.' -f1) + 1)).3"
			else
				echo -ne "\033[0;33m"
				hrs="$(echo $hrs | cut -d'.' -f1).$(($(echo $hrs | cut -d'.' -f2) + 3))"
			fi
			#echo "$user + 0.3m" $tty
		elif ps -eo tty,args | tr -s " " | grep -v grep | grep $user >/dev/null && [ "$tty" == "-" ];then
			tty="$(ps -eo tty,args | tr -s " " | grep -v grep | grep $user | cut -d' ' -f1 | head -n1)"
			echo -ne "\033[0;34m"
		else
			#echo "$user off"
			tty="-"
		fi
		echo -e "$user\t$tty\t$cpt\t$nb\t$hrs"
		sudo sed -i "/$user/c\\$user\t$tty\t$cpt\t$nb\t$hrs" /home/joe/db_user
	fi
done < /home/joe/db_user
