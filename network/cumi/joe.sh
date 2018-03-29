#!/bin/bash
cd "`dirname $0`"
declare -A cumi clusters
debug=2
ncport=`cat masterport | tr '[7-90-6]' '[0-9]'`
header="init-joe>"
trap "down INT;exit" INT

function getdb {
mysql -u cumi --password="password" cumi <<END
	select * from $1;
END
}

function putdb { #syntax table row newval find value
	if ! echo $3 | egrep -q '^[0-9]+$'; then repval=\'$3\';else repval=$3; fi
	if ! echo $5 | egrep -q '^[0-9]+$'; then findval=\'$5\';else findval=$5; fi
	mysql -u cumi --password="password" cumi <<END
		update $1 set $2=$repval where $4=$findval;
END
}

function putsdb {
	mysql --skip-column-names -u cumi --password="password" cumi -e "$1"
}

function insdb { #syntax table cols
if [ "$1" == "clusters" ]; then query="insert into clusters (port, nb_clients, begindate, enddate, active) values ('$2', '$3', now(), '0000-00-00 00:00:00', '$5');";
elif [ "$1" == "reports" ]; then query="insert into reports (from, level, detail, date) values ('$2', '$3', '`date +"%x %X" | tr "/" "-"`');"; fi
mysql -u cumi --password="password" cumi <<END
	$query
END
}

function searchdb { #syntax table coltofind col value
	col=1;row=1;colsearch=1;coltofind=1;i=1
	if [ "$1" == "cumi" ]; then
		while [ "${cumi[$col,1]}" != "$2" ] && [ "${cumi[$col,1]}" != "END" ]; do ((col++)); done
		while [ "${cumi[$coltofind,1]}" != "$3" ] && [ "${cumi[$coltofind,1]}" != "END" ]; do ((coltofind++)); done
		while [ "${cumi[$coltofind,$row]}" != "$4" ] && [ "${cumi[$coltofind,$row]}" != "END" ]; do ((row++)); done
		echo "${cumi[$col,$row]}" | grep -v "END" ; if [ "${cumi[$col,$row]}" == "END" ]; then return 1 ; fi

	elif [ "$1" == "clusters" ]; then
		while [ "${clusters[$col,1]}" != "$2" ] && [ "${clusters[$col,1]}" != "END" ]; do ((col++)); done
		while [ "${clusters[$coltofind,1]}" != "$3" ] && [ "${clusters[$coltofind,1]}" != "END" ]; do ((coltofind++)); done
		while [ "${clusters[$coltofind,$row]}" != "$4" ] && [ "${clusters[$coltofind,$row]}" != "END" ]; do ((row++)); done
		echo "${clusters[$col,$row]}" | grep -v "END" ; if [ "${clusters[$col,$row]}" == "END" ]; then return 1 ; fi
	fi
}

function getarray {
	x=1;i=1
	output=`getdb $1 | tr "\t" " " | sed -e "s/^\-$/NA/g"`
	while [ "`echo "$output" | sed -n "${x}p"`" != "" ]; do
		i=1
		while [ "`echo "$output" | sed -n "${x}p" | cut -d' ' -f$i`" != "" ]; do
			if [ "$1" == "cumi" ]; then
				cumi[$i,$x]=`echo "$output" | sed -n "${x}p" | cut -d' ' -f$i`
			elif [ "$1" == "clusters" ]; then
				clusters[$i,$x]=`echo "$output" | sed -n "${x}p" | cut -d' ' -f$i`
			fi
			((i++))
		done
		if [ "$1" == "cumi" ]; then cumi[$x,12]="END";
		elif [ "$1" == "clusters" ]; then clusters[$x,$i]="END"; fi
		((x++))
	done
	if [ "$1" == "cumi" ]; then cumi[$i,1]="END";
	elif [ "$1" == "clusters" ]; then clusters[$i,1]="END"; fi
}

function getname {
	getarray "cumi" ; i=2 ; name=0
	if [ "$1" != "" ]; then
		name="`searchdb "cumi" "codename" "current" "$1"`"
		if [ "$name" != "" ]; then echo $name ; return; fi
		name="`searchdb "cumi" "codename" "next" "$1"`"
		if [ "$name" != "" ]; then echo $name ; return; fi
	fi
	i=2
	while [ ${cumi[3,$i]} -ne 0 ]; do ((i++)); done
	echo ${cumi[2,$i]}
}

function send {
	if [ "$2" == "" ]; then in=$header ; else in=$2; fi
	scond="`date +"%S"`"
	if [ $scond -ge 56 ]; then sleep $((60 - scond + 4)); fi
	if [ $scond -ge 04 ] && [ $scond -le 02 ]; then sleep $((4 - scond)); fi
	echo "$in$1" | openssl enc -aes-128-cbc -a -salt -pass pass:$(date +"%H%M")$ncport | tr "\n" "\`" | awk '{print $0}' | sed "s/U2FsdGVkX1//g" | nc localhost $ncport
	if [ $debug -eq 1 ]; then echo "$in$1"; fi
}

function print {
	if [ "$2" == "" ]; then in=$header ; else in=$2; fi
	if [ $debug -eq 2 ]; then echo "$in$1"; fi
}

function decode {
	while [ $decstat -eq 1 ]; do sleep 0.5 ; done
	export decstat=1
	echo -n "U2FsdGVkX1$1" | tr "\`" "\n" | openssl enc -aes-128-cbc -a -d -salt -pass pass:$(date +"%H%M")$ncport 2>/dev/null
	export decstat=0
}

function down {
	kill -9 $pidchk
	send "shutdown (killed by $USER [$1])" $header
}

function chkcumi {
	while :; do
		if [ `date +"%S"` -eq 56 ]; then
			getarray "cumi"; onlinecumi=( ); v=1; i=2
			while [ "${cumi[3,$i]}" != "END" ]; do
				if [ "${cumi[3,$i]}" != "0" ]; then
					onlinecumi[$((v++))]="${cumi[2,$i]}"
				fi
				((i++))
			done
			ok=1
		fi
		if [ `date +"%S"` -eq 04 ] && [ $ok -eq 1 ]; then
			ncport=`cat masterport | tr '[7-90-6]' '[0-9]'`
			fullres="$(nc -q 0 localhost $ncport < <(sleep 8) | while read -r res; do res="$(decode $res)";echo $res | grep "KeepAlive" | cut -d'>' -f1 | cut -d'-' -f2; done)"
			for res in `echo "$fullres"`; do
				v=1
				while [ "${onlinecumi[$v]}" != "" ]; do
					if [ "${onlinecumi[$v]}" == "$res" ]; then
						if [ `searchdb "cumi" "online" "codename" "${onlinecumi[$v]}"` -eq 2 ]; then
							putdb "cumi" "online" "1" "codename" "${onlinecumi[$v]}"
						fi
						onlinecumi[$v]="-"
					fi
					((v++))
				done
			done
			v=1
			while [ "${onlinecumi[$v]}" != "" ]; do
				if [ "${onlinecumi[$v]}" != "-" ]; then
					if [ `searchdb "cumi" "online" "codename" "${onlinecumi[$v]}"` -eq 2 ]; then
						putdb "cumi" "online" "0" "codename" "${onlinecumi[$v]}"
						print "${onlinecumi[$v]} off"
					else
						print "${onlinecumi[$v]} is unknow"
						putdb "cumi" "online" "2" "codename" "${onlinecumi[$v]}"
					fi
				fi
				((v++))
			done
			i=2
			while [ "${cumi[3,$i]}" != "END" ]; do
				if [ "${cumi[3,$i]}" == "1" ] || [ "${cumi[3,$i]}" == "2" ]; then
					putdb "cumi" "ttl" "$((`echo ${cumi[6,$i]}` + 60))" "codename" "${cumi[2,$i]}"
				fi
				((i++))
			done
			#checking tunnels
			getarray "clusters" ; tocheck=( ); v=1; i=2
			while [ "${clusters[3,$i]}" != "" ]; do
				if [ "${clusters[4,$i]}" == "1" ]; then
					tocheck[$((v++))]="${clusters[3,$i]}"
				fi
				((i++))
			done
			for chkp in ${tocheck[@]}; do
				if ! nc -z localhost $chkp 2>/dev/null 2>&1; then
					print "unexpected closed tunnel [$chkp]" "debug>"
					putsdb "update clusters set active=0,idle=0 where port=$chkp"
				elif ! ps aux | grep -v "expect" | grep -v grep | grep $chkp >/dev/null ; then
					idle="$(searchdb "clusters" "idle" "port" "$chkp")"
					if [ $idle -le 5 ]; then
						print "increment idle time $idle for [$chkp]" "debug>"
						putsdb "update clusters set idle = idle + 1 where port=$chkp"
					else
						print "closing tunnel by timeout [$chkp]" "debug>"
						putdb "clusters" "idle" "0" "port" "$chkp"
						close="$(putsdb "select manager,cpt,sshd_port,sshd_owner,sshd_pass,sshd_path from clusters where port=$chkp" | tr "\t" " ")"
						send "close $(echo $close | cut -d' ' -f2-)" "joe:$(echo $close | cut -d' ' -f1)>"
					fi
				elif [ `searchdb "clusters" "idle" "port" "$chkp"` -ne 0 ]; then
					print "reset idle time [$chkp]" "debug>"
					putdb "clusters" "idle" "0" "port" "$chkp"
				fi
			done
			ok=0
		fi
		sleep 1
	done
}

function updatecumi {
	getarray "cumi"
	if [ "$arg2" != "$arg1" ]; then
		if [ `searchdb "cumi" "online" "codename" "$arg2"` -eq 1 ]; then
			ticket="`openssl rand -base64 39 | tr -d '/' | tr -d '+'`"
			echo "$ticket" >> /var/www/joe/index
			bash -c "(sleep 120 ; sed -i "/$ticket/d" /var/www/joe/index)" &
			send "updateself $ticket" "$head:$arg2>"
		else
			send "cannot update $arg2 (offline)" $header
		fi
	else
		i=2
		while [ "${cumi[3,$i]}" != "END" ]; do
			if [ "${cumi[3,$i]}" == "1" ]; then
				ticket="`openssl rand -base64 39 | tr -d '/' | tr -d '+'`"
				echo "$ticket" >> /var/www/joe/index
				bash -c "(sleep 120 ; sed -i "/$ticket/d" /var/www/joe/index)" &
				send "updateself $ticket" "$head:${cumi[2,$i]}>"
			fi
			((i++))
		done
	fi
}

function tunnel {
	manager="`mysql -u cumi --password="password" --skip-column-names cumi -e "select codename from cumi where online=1 order by rand() limit 1"`"
	revport="$((RANDOM%63000+2001))"
	arg3="`echo "$args"|cut -d' ' -f3`"
	arg4="`echo "$args"|cut -d' ' -f4`"
	if [ "$manager" != "" ]; then
		if [ "`putsdb "select cpt from clusters where sshd_owner='$arg3' and cpt='$arg2'"`" != "" ]; then
			putsdb "update clusters set active=0, port=$revport, manager='$manager', sshd_owner='$arg3', sshd_pass='$arg4', hidden=0 where sshd_owner='$arg3' and cpt='$arg2'"
		else
			putsdb "insert into clusters (cpt, port, active, begindate, manager, sshd_owner, sshd_pass, sshd_path) values ('$arg2', '$revport', 0, now(), '$manager', '$arg3', '$arg4', '-')"
		fi
		send "manager for tunnel is $manager" "$head:console>"
		send "open $arg2 $revport $arg3 $arg4" "$head:$manager>"
	else
		send "no manager available to process the request" "$head:console>"
	fi
}

function updatetun {
	if [ $1 -eq 1 ]; then
		putsdb "update clusters set active=$1, sshd_path='$5', sshd_port='$4' where cpt='$2' and port='$3'"
	elif [ $1 -eq 0 ]; then
		putsdb "update clusters set active=$1, sshd_pass='-' where cpt='$2' and sshd_port='$3'"
	fi
}

function putoncumi {
	getarray "cumi"
	res=`searchdb "cumi" "online" "codename" "$name"`
	if [ $1 -eq 1 ]; then
		if [ $res -eq 0 ] || [ $res -eq 2 ]; then
			putdb "cumi" "online" "1" "codename" "$name"
		fi
	elif [ $1 -eq 0 ]; then
		if [ $res -eq 1 ] || [ $res -eq 2 ]; then
			putdb "cumi" "online" "0" "codename" "$name"
		fi
	fi
}

function count {
	if kill -0 $2 >/dev/null 2>&1; then
		ct=0
		while kill -0 $2 >/dev/null 2>&1; do
			((ct++)) ; sleep 1
		done
		send "$1 (${ct} seconds)" $3
	fi
}

function genticket {
	ticket="`openssl rand -base64 39 | tr -d '/' | tr -d '+'`"
	echo "$ticket" | tee -a /var/www/joe/index
	[[ -f $1 ]] && bash -c "(sleep 120 ; sed -i "/$key/d" /var/www/joe/index)" &
}

function joe {
	while read -r all; do
		if ! echo $all | grep "\`" >/dev/null; then
			send "bad packet received $all"
			./master.sh >/dev/null
			break
		fi
		all="$(decode "$all")"
		ct=0
		while ! echo $all | grep ">" >/dev/null && [ $ct -ne 2 ]; do all="$(decode "$all")"; ((ct++)); done
		bac=$all
		from="`echo "$all"|cut -d'>' -f1|cut -d':' -f1`"
		typ="`echo "$from"|cut -d'-' -f1`"
		name="`echo "$from"|cut -d'-' -f2`"
		level="`echo "$from"|cut -d':' -f2`"
		args="`echo "$all"|cut -d '>' -f2`"
		arg1="`echo "$args"|cut -d' ' -f1`"
		arg2="`echo "$args"|cut -d' ' -f2`"
		head="`echo $header | cut -d'>' -f1`"

					############UNAUTHENTIFICATED CUMI'S############
		if [ "$typ" == "cumi" ] && [ "$name" == "cumi" ]; then
			case "$arg1" in
				Hello)send "$from up" $header;;
				Goodbye)send "$from down" $header;;
				ping)send "pong" $header;;
				request)case "$arg2" in
							codename)send "send codename `getname "$tmpunauth"`" $header;;
						esac;;
				send)case "$arg2" in
						hostname)export tmpunauth="`echo $args | cut -d' ' -f3`";;
					 esac;;
			esac
					####################CONSOLE#####################
		elif [ "$typ" == "console" ]; then
			case "$arg1" in
				ping)send "pong" $header;;
				clear)cat /var/www/joe/mlog | sed -e "s/<div .*log>//g" -e "s/<\/u>.*/\]/g" -e "s/<u>/ \[/g" > /var/log/cumi/mlog.old.$(($(ls -1t /var/log/cumi | head -n1 | rev | cut -d. -f1) + 1))
						echo "<div class=\"log\">Screen Cleared</div><div class=\"log\">" > /var/www/joe/mlog;;
				tunnel)tunnel;;
				update)updatecumi;;
			esac
					#############AUTHENTIFICATED CUMI'S#############
		elif [ "$typ" == "cumi" ] && [ "$name" != "cumi" ]; then
			case "$arg1" in
				KeepAlive)putoncumi 1;;
				Hello)putoncumi 1 ; send "request hostname" "$head:$name>";;
				Goodbye)putoncumi 0 ;;
				pong)putoncumi 1;;
				ping)send "pong" "$head:$name>";;
				jumped)putsdb "update cumi set jumps = jumps + 1 where codename='$name'";;
				request)case "$arg2" in
							list)send "send usedcpt `cat usedcpt | tr '[a-z]' '[g-za-f]' | tr '[0-9]' '[5-90-4]' | tr ' ' '@'`" "$head:$name>";;
							token)send "send token `genticket`" "$head:$name>"
						esac;;
				send)case "$arg2" in
						hostname)putdb "cumi" "current" "`echo $args | cut -d' ' -f3`" "codename" "$name";;
						nextcpt)putdb "cumi" "next" "`echo $args | cut -d' ' -f3`" "codename" "$name";;
						tuninfo)updatetun "1" "`echo $args | cut -d' ' -f3`" "`echo $args | cut -d' ' -f4`" "`echo $args | cut -d' ' -f5`" "`echo $args | cut -d' ' -f6`";;
						closeinfo)updatetun "0" "`echo $args | cut -d' ' -f3`" "`echo $args | cut -d' ' -f4`"
					 esac;;
			esac
		fi
	done
}

##------Script start here-------##

sleep 987 & boot="$!" ; count "uptime" $boot "joe>" &
decstat=0;resmaster=0;ok=0;timeout=( );idle=( )
send "boot" $header
send "fetching db" $header
getarray "cumi" ; getarray "clusters" ; getarray "reports"
send "start checking network" $header
header="joe>"
chkcumi &
pidchk=$! ; kill -9 $boot

while :; do
	ncport=`cat masterport | tr '[7-90-6]' '[0-9]'`
	nc -d localhost $ncport | joe
	send "reconnect to master.." $header
done
