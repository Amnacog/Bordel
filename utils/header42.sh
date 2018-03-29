#!/bin/zsh
###For 42 purpose###

##Credientals for intra##
login=nsaintot
password=password

lock="`dirname $0`/.tmp/.tmpheax05392"
function getpos {
#	old_settings=$(stty -g) || exit
#	stty -icanon -echo min 0 time 3 || exit
#	printf '\033[6n'
#	pos=$(dd count=1 2> /dev/null)
#	pos=${pos%R*}
#	pos=${pos##*\[}
#	col=${pos##*;} ; row=${pos%%;*}
#stty "$old_settings"
}

function chkkrb5 {
	while [ $ok -eq 0 ] && [ $ct -ne 2 ]; do
		tput cup $((row + i)) $grid
		if klist 2>/dev/null >&2; then ok=1
		else ((ct++)); ((i++)) ; echo -ne "\033[0;33mkrb5\033[0m: \033[0;31mKO\033[0m No ticket -> Password:\c" ; kinit -a 2>/dev/null; fi
	done
	tput cup $((row + i)) $grid
	if klist 2>/dev/null >&2; then echo -ne "\033[0;33mkrb5\033[0m: \033[0;32mOK\033[0m -> expire $(klist -v | grep "krbtgt/42.FR" -A 5 | tail -n1 | cut -d' ' -f5-7)\c"
	else echo -e "\033[0;33mkrb5\033[0m: \033[0;31mKO\033[0m -> U Can't proper work without ticket" ; fi
}

function summary {
	i=0
	if [ -f .tmp/42.cook ]; then
		echo -e "\033[4;32mSUMMARY\033[0m :\n"
		query=$(curl -skL -b .tmp/42.cook https://profile.intrav2.42.fr/)
		correc=$(echo "$query" | sed -n "/Profile/,/answers/p")
		echo $correc | sed -n "/Profile/,/overflowable-item/p" | grep -Ev "<.*>" | grep -v "Profile\|Projets\|E-learning\|Forum\|Meta" | sed '/^\s*$/d'
		#echo $correc | sed -n "/Manage slots/,/overflowable-item/p" | grep -v "slots\|</a\|<b\|class\|</div\|<a\|forever\|action" | tr -d '\n' | sed "s/<span data-cal-date='/ /g" | sed "s/\/+0100'\>//g" | perl -p -e 's/<\/span>/\n/' | tr -d "<>\/'" | sed "s/span//g" | sed "s/data-long-date=//g"
	elif [ ! -f .tmp/42.cook ] || curl -skL -b .tmp/42.cook https://profile.intrav2.42.fr/ | grep "login-main" >/dev/null 2>&1; then
		token=$(curl -skLc .tmp/42.cook https://profile.intrav2.42.fr/ | grep "csrf-token" | cut -d'"' -f2)
		curl -skLb .tmp/42.cook -X POST --data "utf8=✓&authenticity_token=$token&user[url_referer]=https://profile.intrav2.42.fr&user[login]=nsaintot&user[password]=password&commit=Sign in" -H "application/x-www-form-urlencoded" https://signin.intrav2.42.fr/sessions >/dev/null
		if curl -skLb .tmp/42.cook https://profile.intrav2.42.fr/ | grep "n-navbar-user-nav" >/dev/null; then
			summary
		else
			rm .tmp/42.cook
			echo "ERROR: IntraV2 throw an error"
		fi
	fi
}

function connectivity {
	i=1 ; ok=0 ; ct=0
	site=( "dashboard.42.fr" "vogsphere.42.fr" "ldap.42.fr" "scam.42.fr" )
	port=( "80" "22" "389" "80" )
	tput cup $((row - 1)) $grid
	echo -ne "\033[4;36mCONNECTIVITY\033[0m:\c"
	while [ $i -ne 5 ]; do
		tput cup $((row + i)) $grid
		if [ ${#site[$i]} -le 10 ]; then c="     " else unset c ;fi
		if nc -zw 1 ${site[$i]} ${port[$i]} >/dev/null 2>&1; then
			echo -ne "`echo "$site[$i]" | perl -nE 'say ucfirst' | cut -d'.' -f1`$c is \033[0;32mUP\033[0m\c"
		else
			echo -ne "`echo "$site[$i]" | perl -nE 'say ucfirst' | cut -d'.' -f1`$c is \033[0;31mDOWN\033[0m\c"
		fi
		((i++))
	done
	if [ $krb5 -eq 1 ]; then chkkrb5 ; else echo; fi
}

function system {
	i=1 ; x=1
	if uname -a | grep "Darwin" >/dev/null; then
		tput cup $((row - 1)) $grid
		echo -ne "\033[4;33mSYSTEM\033[0m:\c"
		cpu=`ps aux  | awk 'BEGIN { sum = 0 }  { sum += $3 }; END { print sum }' | cut -d'.' -f1`
		getmem=`top -l 1 | head -n 10 | grep PhysMem: | tr -d "Physem:used()wired,n.M" | tr -s " "`
		memformat=`echo $getmem | cut -d' ' -f2`
		memtotal=`echo $getmem | cut -d' ' -f4`
		mem=$(( 100 * memformat / memtotal))
		disk=`df -h | head -n2 | tail -n1 | tr -s " " | rev | cut -d' ' -f2 | rev | cut -d'%' -f1`
		home=`du -sh ~ | rev | cut -f2- -s | rev`
		stats=( $cpu $mem $disk $home )
		while [ $x -le ${#stats[@]} ];do
			if echo $stats[$x] | grep "M" >/dev/null; then stats[$x]="\033[0;32m"
			elif echo $stats[$x] | grep "G" >/dev/null;then stats[$x]="\033[0;33m"
			elif [ $stats[$x] -ge 70 ]; then stats[$x]="\033[0;31m"
			elif [ $stats[$x] -ge 50 ];then stats[$x]="\033[0;33m"
			else stats[$x]="\033[0;32m" ; fi
			((x++))
		done
		tput cup $((row + i)) $grid
		echo -ne "CPU:  $stats[1]$cpu%\033[0m\c"
		((i++)) ; tput cup $((row + i)) $grid
		echo -ne "MEM:  $stats[2]$mem%\033[0m\c"
		((i++)) ; tput cup $((row + i)) $grid
		echo -ne "DISK: $stats[3]$disk%\033[0m\c"
		((i++)) ; tput cup $((row + i)) $grid
		echo -e "HOME: $stats[4]$home\033[0m"
	fi
}

function help {
	echo "Usage: header42.sh [ --summary [ --krb5 --connectivity ] --system --time=seconds ]"
	echo '--summary: gives the user a summary of the day'
	echo '--connectivity: gives the user a list of services online'
	echo -e '\\   --krb5: check for krb5 tickets (if --connectivity is set)'
	echo '--system: gives the user some system stats'
	echo '--time=seconds: if this parameter is set the program can not be launched during the lap of time (for multiples session login)'
}
if [ -f $lock ] && [ $(($(date +%s) - $(stat -f %m $lock))) -ge 120 ]; then rm $lock; fi
if [ ! "$2" = "--persis" ] && [ -f $lock ]; then exit ;fi
if [ `tput cols` -lt 80 ]; then echo "Term Screen too small !";exit -1;fi
if [ $# -eq 0 ]; then help ; exit -1; fi
curpwd=`pwd`
cd `dirname $0`
grid=0 ; krb5=0 ; n=0 ; big=0
if [ ! "$1" = "--pos" ];then getpos; fi
for arg in $@; do
	if echo $arg | grep "time" >/dev/null; then time=`echo $arg | cut -d'=' -f2`; if [[ ! -z "${time//[0-9]/}" ]] && [ $time -le 10 ]; then time=0 ; fi
	elif [ "$arg" = "--krb5" ] && uname -a | grep "Darwin" >/dev/null 2>&1; then krb5=1
	elif [ "$arg" = "--summary" ] && [ `tput cols` -ge $grid ]; then summary ; ((n++)) ; ((grid=grid+90))
	elif [ "$arg" = "--connectivity" ] && [ `tput cols` -ge $grid ] && [ `tput lines` -ge $((row + 6)) ]; then connectivity ; ((n++)) ; ((grid=grid+20))
	elif [ "$arg" = "--system" ] && [ `tput cols` -ge $grid ] && [ `tput lines` -ge $((row + 10)) ]; then system ; ((n++)) ; ((grid=grid+20)); fi
	if [[ ! -z $time ]] && [ $time -gt 10 ]; then touch $lock ; bash -c "(sleep $time; rm $lock 2>/dev/null) &" & ; fi
	if [ $n -eq 1 ] && [ ! "$1" = "--pos" ]; then tput sc ;fi
done
oldrow=$row
if [ ! "$1" = "--pos" ]; then getpos ; fi
if [ $n -gt 1 ] && [ $oldrow -ge $row ] && [ ! "$1" = "--pos" ]; then tput rc ; fi
cd $curpwd
