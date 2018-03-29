#!/bin/bash
cd $(dirname $0)
color=0
login=nsaintot
password=password
par="https://intra.42.fr/module/2014/PISC-0-001/PAR-0-1"
begin="570"
day=`date +"%d"`
hour=`date +"%H"`
i=0
if [ $# -ne 0 ]; then
	for arg in $@; do
		arg=$(echo "$arg" | sed "s/--//g")
		if [ "$arg" == "color" ]; then color=1 ; fi
	done
fi
if [ $color -eq 1 ]; then
	reset="\033[0m"
	green="\033[0;32m"
	red="\033[0;31m"
	yellow="\033[0;33m"
fi
if [ `echo $day | cut -c 1` -eq 0 ]; then
	day=`date +"%d" | cut -c 2`
fi
if [ `echo $hour | cut -c 1` -eq 0 ]; then
	hour=`date +"%H" | cut -c 2`
fi
	echo Day: $day Hour: $hour

if header=$(curl -skL -c .tmp/42.cook -d "login=$login&password=$password" https://intra.42.fr/ | grep -i "Bienvenue" | tr -d "\t" | cut -d'<' -f1);then
	echo "Succes login: $header"
	while [ $i -ne 10 ];do
		acti=$(( $begin + day + i - 4))
		response=$(curl -skL -b .tmp/42.cook $par/acti-$acti/project | head -n266)
		name=$(echo "$response" | grep -i "<title>" | sed "s/title/@/g" | cut -d'@' -f2 | cut -d'-' -f1)
		if echo "$response" | tr "<" "\n" | grep -i "button unregister\|Vous êtes inscrit" >/dev/null || echo "$response" | grep "vogsphere@vogsphere" | grep "$login" >/dev/null; then
			status="${green}Registered$reset"
			if echo "$response" | grep -i "Il vous reste <strong" >/dev/null; then
				delay="Remaining: $(echo $response | grep -i "Il vous reste <strong" | sed "s/strong title=\"/@/g" | cut -d'@' -f2 | cut -d'>' -f2 | cut -d'<' -f1)"
			else
				delay="Finished: $(echo $response | grep -i "La date de fin d'inscription" | sed "s/strong title/@/g" | cut -d'@' -f2  | cut -d'>' -f2 | cut -d'<' -f1)"
			fi
			repo=$(echo "$response" | grep -i "vogsphere@vogsphere" | grep "$login" | cut -d'>' -f2 | cut -d'<' -f1)
			id=0
		elif echo $response | grep "register\|inscrire" >/dev/null; then
			status="${yellow}Not Registered yet$reset"
			if echo "$response" | grep "Le projet commencera" >/dev/null;then
				delay="Begin: $(echo $response | grep -i "Le projet commencera" | sed "s/<div>Le projet commencera/@/g" | cut -d'@' -f2 | cut -d'>' -f2 | cut -d'<' -f1)"
			elif echo "$response" | grep "Il vous reste" >/dev/null;then
				delay="Remaining: $(echo $response | grep -i "Il vous reste" | sed "s/strong title=\"/@/g" | cut -d'@' -f2 | cut -d'>' -f2 | cut -d'<' -f1)"
			else
				delay="NA"
			fi
			id=1
		elif echo $response | grep -i "Vous pouviez vous inscrire jusqu'au" >/dev/null; then
			status="${red}Was not registered$reset"
			delay="Failed"
			id=3
		else
			delay="NA"
			status="${yellow}Project not available$reset"
			id=2
		fi
		echo -e "${reset}Register project: $acti-$name($delay) -> $status\c"
		if [ $id -eq 1 ]; then
			response=$(curl -skL -b .tmp/42.cook -d "login=$login&password=$password" $par/acti-$acti/project/register)
			if echo "$response" | grep "project/register.php" >/dev/null; then
				response="${green}Ok Registered$reset"
			else
				response="`echo "$response" | sed "s/<h1>/@/g" | grep "@" | cut -d'@' -f2 | cut -d'<' -f1`"
			fi
			echo -e " -> $response"
		else
			if ! grep "$repo" .tmp/vogsphere >/dev/null;then
				echo "$repo" >> .tmp/vogsphere
			fi
			echo
		fi
		((i++))
	done
fi
