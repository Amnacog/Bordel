#!/bin/zsh
unset modee pathh repoo pname sav i sub auto addr arg
if [[ ! -z "$1" ]];then
	arg="$1"
	auto="1"
	modee="p"
	pathh="$HOME/42/projects/$1/"
fi
if [[ "`pbpaste`" =~ "vogsphere@vogsphere:"* ]]; then
	repoo=`echo -e "$(pbpaste)\n"`
	if echo $repoo | grep $USER >/dev/null && [[ -z "$auto" ]];then
		modee="p"
	else
		modee="c"
		pathh="$HOME/42/projects/correction/$arg/"
	fi
fi
while [ "$modee" '!=' "c" ] && [ "$modee" '!=' "p" ] || [[ -z "$modee" ]];do
	echo -n "Corrector or Project ? (c/p)"
	read -sk 1 modee
	echo
done
if [ "$modee" '==' "c" ] && [[ -z "$pathh" ]]; then
	pathh="$HOME/42/projects/correction/"
	sav="$pathh"
elif [[ -z "$pathh" ]]; then
	pathh="$HOME/42/projects/"
	sav="$pathh"
fi
if [[ -z "$repoo" ]]; then
	echo -e "Clone path"
	echo -en  "\033[1;34mvogsphere@vogsphere.42.fr:\033[0;33m"
	read addr
	repoo="vogsphere@vogsphere.42.fr:$addr"
fi
if ! cat $(dirname $0)/logins | grep $(echo $(basename $repoo)) >/dev/null 2>&1; then
	echo -e "\033[0;31mRepo is not valid\033[0m"
	sleep 2; exit -1
else
	echo -e "\033[0;32mRepo is valid\033[0m"
fi

if [ "$modee" '==' "p" ] && [[ ! -z "$auto" ]];then
	i=0
	while [ ! -d "$pathh" ];do
		if [ $i -ne 0 ]; then
			echo -e "\033[0;31mInvalid path: \033[033;m$pathh\033[0m"
		fi
		echo -ne "Optional path: $sav"
		read pathh
		pathh="`echo $sav$optpathh | sed "s/~//g"`"
		((i++))
	done
fi
if [ "$modee" '==' "p" ] && [[ -z "$auto" ]];then
	pname="`echo $repoo | cut -d: -f2 | cut -d/ -f4- | sed "s/\/$USER//g"`"
else
	pname="`echo $repoo | cut -d: -f2 | cut -d/ -f4-`"
fi

echo $repoo $pathh$pname
if res=$(git clone $repoo "$pathh$pname/" 2>&1); then
	echo -e "\033[0;32mSuccess\033[0m"
	cd $pathh$pname
	echo -e "`ls -l | tail +4`"
	if echo $res | grep "empty" >/dev/null && echo $repoo | grep $USER >/dev/null; then
		echo -e "empty repository: pushing auteur file\033[0m"
		echo "$USER" > $pathh$pname/auteur
		git add auteur
		git commit -m auth
		git push origin master
	fi
else
	echo -e "\033[0;31mFailed : Permission denied\033[0m"
fi
unset modee pathh repoo pname sav i sub auto addr arg
