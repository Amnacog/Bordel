#!/bin/bash
#1.013
cd ~/tl/
i=0
ok=0
arg=$@
host=$(hostname | cut -d. -f1)
hosts=( e3r2p16 e3r2p15 e3r2p14 e3r2p13 e3r2p12 e3r2p11 e3r2p9 e3r3p8 e3r3p9 e3r3p10 e3r3p11 e3r3p13 e3r3p14 )

#i dont use it anymore
function next {
	nexthost=${hosts[0]};shost=1
	while [ $i -ne 13 ] && [ $ok -ne 1 ]; do
		echo -en "Info: Current: $host -> Next:\t $nexthost -- Test node.."
		if getuser=$(ssh -oConnectTimeout=5 -oLogLevel=quiet -oStrictHostKeyChecking=no -oCheckHostIP=no nsaintot@$nexthost "who | grep -v grep | cut -d' ' -f1 | tr '\n' ' '") >/dev/null && ssh -oConnectTimeout=5 -oLogLevel=quiet -oStrictHostKeyChecking=no -oCheckHostIP=no nsaintot@$nexthost "cd ~ && if who | grep -E 'root|bocal'; then return 1; else return 0; fi" 2>/dev/null >/dev/null; then
			ok=1
			echo " Success"
		else
			nexthost=${hosts[$shost]}
			((shost++))
			echo " Failed"
		fi
		((i++))
	done
	if [ $ok -eq 1 ]; then
		ssh -oConnectTimeout=5 -oLogLevel=quiet -oStrictHostKeyChecking=no -oCheckHostIP=no nsaintot@$nexthost "~/tl/cron.sh odb;~/tl/oob.sh start"
		if [ "$getuser" == "" ]; then getuser="Nobody"; fi
		echo -e "Info: Start Tunnel on $nexthost ( $getuser )\nInfo: Stop tunnel on $host"
		./cron.sh
	else
		echo "Error: Can't Do anything.. i'll try in 5 min"
	fi
}

if [ -f /tmp/launchd-1934.27hX1337iq/ ];then mkdir /tmp/launchd-1934.27hX1337iq/;fi

#nossh found or denied user connected
if who | grep -E "root|bocal" >/dev/null; then
	if ! [ -f ~/.tmp/conflict ];then echo "Info: user $(who | grep -v $USER | grep -E "exam|root|bocal|console" | cut -d' ' -f1) Use .nossh/Secure tun to off"; touch ~/.tmp/conflict 2>/dev/null; ~/tl/oob.sh stop 2>/dev/null ; fi

#no pid found
elif ! [ -f ~/.tmp/pid ] || ! ps aux | grep -v grep | grep $(cat ~/.tmp/pid 2>/dev/null) >/dev/null || [ "$1" == "-relaunch" ] || ( [ $(date +"%H%M") -eq 0000 ] && [ "$(who)" == "" ] ); then
	~/tl/oob.sh stop 2>/dev/null
	sleep $[RANDOM%20+1]
	if ! [ -f ~/.tmp/conflict ];then echo "Info: Tunnel relaunched"; touch ~/.tmp/conflict 2>/dev/null; fi
	~/tl/oob.sh start

#md5 verification
elif [ "$(cat ~/tl/oob/wl.sh ~/tl/oob/lw.sh | /sbin/md5)" != "$(cat /tmp/launchd-1934.27hX1337iq/wl.sh /tmp/launchd-1934.27hX1337iq/lw.sh 2>/dev/null | /sbin/md5)" ];then
	a=$(cat ~/tl/oob/wl.sh ~/tl/oob/lw.sh | /sbin/md5)
	b=$(cat /tmp/launchd-1934.27hX1337iq/wl.sh /tmp/launchd-1934.27hX1337iq/lw.sh 2>/dev/null | /sbin/md5)
	echo -e "Warning content changed: origin pkg's \"$a\" and deployed pkg's \"$b\"\nInfo: Redeploying packages.."
	echo "$(cat ~/tl/oob/wl.sh ~/tl/oob/lw.sh | /sbin/md5)" > ~/.tmp/md5 ; cp ~/tl/oob/wl.sh ~/tl/oob/lw.sh /tmp/launchd-1934.27hX1337iq/ ; chmod 755 /tmp/launchd-1934.27hX1337iq/*.sh
else
	rm -rf ~/.tmp/conflict 2>/dev/null
fi
