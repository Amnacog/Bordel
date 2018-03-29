#!/bin/bash
#bored staff stuff...
user=$1
trap "exit" INT
sleep 1
echo -ne "$user@${2}'s password:\c"
read -s pass
echo $pass >> .tmp/pass
echo
sleep 3
if [ -t 1 ]; then
	echo -e "\033[0;31mWelcome \033[1;31m$user\033[0;31m, connections to this client are monitored.\nGood conduct is expected.\nYour session will be monitored\nViolators will be shot, Surivors will be shot again.\nYou have been warned\n\033[0;32mCreating temporary directory\033[0m"
	sleep 4
	echo -e "\033[0;32mHome was properly mounted\nSpawning a shell\033[0m"
	sleep 0.5
	echo -e "\033[0;32mYou are most likely NOT in the proper folder, use \033[3;33;44mcd\033[0;32m to get to your NFS mount.\033[0m"
	zsh -i
	echo -e "\033[0;32mHome was properly unmounted\033[0m"
	exit
else
	echo -e "\033[0;33mOops, you do not have a TTY.\033[0m"
	exit -1
fi

