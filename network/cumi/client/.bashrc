function secexit {
	tput cnorm
#	tput rmcup
	exit $1
}

function getdb {
	if [ -z $2 ]; then table="cumi" ; else table="$2"; fi
	mysql --skip-column-names -u cumi --password="password" $table -e "$1"
}
function putdb { #syntax table row newval find value
	if ! echo $3 | egrep -q '^[0-9]+$'; then repval=\'$3\';else repval=$3; fi
	if ! echo $5 | egrep -q '^[0-9]+$'; then findval=\'$5\';else findval=$5; fi
	mysql -u cumi --password="password" cumi -e "update $1 set $2=$repval where $4=$findval"
}
function insdb {
	mysql -u cumi --password="password" cumi -e "insert into user (uid, memrize) values ('$1', 0)"
}

function disclaimer {
	dialog --keep-tite \
	--fullbutton \
	--keep-colors \
	--smooth \
	--defaultno \
	--cr-wrap \
	--separate-output \
	--backtitle "$header" \
	--cancel-label "NO" \
	--ok-label "YES" \
	--hline "Accept ?" \
	--title "Disclaimer" \
	--checklist 'Cumi system is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU General Public License for more details.
	You should have received a copy of the GNU General Public License along with this program.
	If not, see <http://www.gnu.org/licenses>.' 11 100 1 R "Don't show this again" 0
}

function selectcpt {
	tput cnorm
	dialog --keep-tite \
	--keep-colors \
	--colors \
	--smooth \
	--max-input "11" \
	--backtitle "$header" \
	--title "Choose Tun host" \
	--inputbox "The syntax is eXrXpX or ip 10.1e.r.p
e - [1-3] ; r - [1-12] ; p - [1-22]" 10 50 ""
}

function popup {
	msg="`echo -e "$1" | wc -L`"
	nmsg="`echo -e "$1" | wc -l`"
	dialog --keep-tite \
	--keep-colors \
	--colors \
	--smooth \
	--backtitle "$header" \
	--ok-label "Continue" \
	--title "$2" \
	--msgbox " $1" $((4 + nmsg)) $((4 + msg))
}

function newcpt {
	ok=0
	while [ $ok -ne 1 ] && [ $ok -ne 2 ];do
		res="$(selectcpt 3>&1 >&2 2>&3).local"
		ret=$?
		if [ $ret -eq 0 ]; then
			if [[ $res =~ $dns ]]; then 
				typ="dns"
				e="`echo $res | cut -d'e' -f2 | cut -d'r' -f1`"
				re="`echo $res | cut -d'r' -f2 | cut -d'p' -f1`"
				p="`echo $res | cut -d'p' -f2`"
				ok=1
			elif [[ $res =~ $ip ]]; then
				typ="ip"
				e="`echo $res | cut -d'.' -f2 | cut -c2`"
				re="`echo $res | cut -d'.' -f3`"
				p="`echo $res | cut -d' ' -f4`"
				ok=1
			elif [[ "$res" =~ "local" ]]; then ok=1
			else
				tput civis;popup "\Z1Invalid syntax: '$res' !\nDon't try to cheat :)" "Error";tput cnorm
			fi
			if [ $ok -eq 1 ]; then
				query="$(getdb "select sshd_owner from clusters where cpt='$res' and active=1")"
				if [ "$query" != "$USER" ] && [ "$query" != "" ]; then
					ok=0
					tput civis;popup "\Z1Tunnel already used: '$res' !\n Select another cpt.." "Warning";tput cnorm
				elif [ "$query" == "$USER" ]; then
					ok=2
					tput civis;popup "Tunnel already opened: '$res' !\n Select it from the 'Tunnel Manager' menu.." "Warning";tput cnorm
				fi
			fi
		else ok=2
		fi
	done
	if [ $ok -eq 1 ]; then order "$res"; fi
	tput civis
}

function order {
	if [ "$1" != "" ]; then
		./order "$1" "$USER" "`echo $pass|base64|tr '[A-Za-z]' '[G-ZA-Fg-za-f]'`" 2>/dev/null | dialog --keep-tite \
		--keep-colors \
		--colors \
		--smooth \
		--backtitle "$header" \
		--title "Order Tunnel" \
		--gauge "Please wait.." 8 70
		tput civis
	fi
}

function interact {
	if [ `getdb "select active from clusters where cpt='$1' and sshd_owner='$USER'"` -eq 1 ]; then
		if [ `getdb "select mount from user where uid='$USER'"` -eq 1 ]; then
			mnt="interact"
		else
			mnt="interact"
		fi
		tput cnorm
		port=$(getdb "select port from clusters where cpt='$1' and active=1")
		expect -c "
			spawn -noecho ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no $USER@\<3 -p $port
			expect {
				\"yes\" {
					send \"yes\r\"
					exp_continue
				}
				\"as\" {
					send \"$pass\r\"
					interact
				}
				\"port\" {exit 2}
				\"denied\" {exit 3}
			}"
		ret=$?
		tput civis
		case $ret in
			2)popup "\Z1Tunnel is closed, try to reorder one.." "\Z1Error";;
			3)popup "\Z1Your account is closed or password is misspelled" "\Z1Error";;
		esac
	else
		order "$1"
	fi
}

function mainmenu {
	i=0
	while read entries; do
		((i++))
		entrydesc[$i]=`echo $entries | cut -d' ' -f2- | sed "s/ /_/g"`
		if [ "`echo ${entrydesc[$i]} | rev | cut -d_ -f1 | rev`" == "on" ]; then
			entrycolor[$i]=""
		else
			entrycolor[$i]="\\Z2\\Zr\\Z4"
		fi
		entry[$i]=`echo $entries | cut -d' ' -f1`
		entrydesc[$i]=`echo "manager:${entrydesc[$i]}" | cut -d_ -f1-2 | sed "s/_/,last-use:/g"`
	done < <(echo "`getdb "select cpt,manager,begindate,case when active = 0 then 'on' else 'off' end as active from clusters where sshd_owner='$USER' and hidden=0 order by active asc, begindate desc limit 5" | tr "\t" " "`")
	dialog --keep-tite \
	--keep-colors \
	--colors \
	--cancel-label "Help" \
	--help-button \
	--help-label "Settings" \
	--extra-button \
	--extra-label "Exit" \
	--cr-wrap \
	--smooth \
	--default-item "1-${entry[1]}" \
	--backtitle "$header" \
	--title "Tunnel manager" \
	--menu "" $((i + 7 )) 70 $((i + 1)) \
	0 "Create new tunnel.." \
	`if [ "${entrydesc[1]}" != "manager:" ]; then x=1;while [ $x -le $i ]; do echo -n "${x}-${entry[$x]}" "${entrycolor[$x]}(${entrydesc[$((x++))]})\\Zn "; done; fi`
}

function helper {
	dialog --keep-tite \
	--keep-colors \
	--scrollbar \
	--smooth \
	--backtitle "$header" \
	--title "Help" \
	--cr-wrap \
	--no-collapse \
	--colors \
	--msgbox 'With Joe, you can create tunnels (up to 5)
and gives you access to 42 clusters.

Legend: \Zr\Z0  \Zn: Offline \Zr\Z4  \Zn: Online
- If disconnection is triggered
  Joe will maintain the tunnel for 5 mins.
- Joe is using ssh connectivity
- Most parts of the process are hidden from monitoring
  (bocal quand tu nous tiens :-) )
PS: no bullshit its secured.
PSS: Enjoy :)

                                 .z/||/.
               ./d|||///..     .|||||||P""
              ./||||||||||||||||//||||||"
          ./|||||||||||||||||||||||||"
        .||||||||||||||||||||||||||||||/..
    .||****""""***|||||||||||||||||||||||||||b/.
                     ""**D||||||||||||||||||||||L
                    /|||||||||||||||||||||||||||LL
                     .||||||||P**|||||||||||||||||
                     /|||||||"              4|||||
                   /|||||||||                |||/
                    /|||||||||F                |/
                 ||||||||||F Cumi was here..
                   *||||||||"
                       "***""' 13 70
}

function extra {
	dialog --keep-tite \
	--keep-colors \
	--smooth \
	--ok-label "Apply" \
	--separate-output \
	--backtitle "$header" \
	--title "Settings" \
	--checklist "" 10 50 2 \
	"CClear" "tunnels entries" "off" \
	"AAuto" "mount sgoinfre/zfs" "`[ $sqlmount -eq 1 ] && echo on || echo off`"
}

function manager {
	while :; do
		res=$(mainmenu 3>&1 >&2 2>&3)
		ret=$?
		case $ret in
			0)if [ "$res" == "0" ]; then
				newcpt
			  else
				interact "`echo $res | cut -d'-' -f2`"
			  fi;;
			1)helper;;
			2)sqlmount=`getdb "select mount from user where uid='$USER'"`;mopt=0;res=$(extra 3>&1 >&2 2>&3)
			  for opt in $res; do
			   if [ "$opt" == "CClear" ]; then
				getdb "update clusters set hidden=1 where sshd_owner='$USER' and active=0"
			   elif [ "$opt" == "AAuto" ] && [ $sqlmount -eq 0 ]; then
				getdb "update user set mount=1 where uid='$USER'";mopt=1;fi
			  done
			  [ $sqlmount -eq 1 ] && [ $mopt -eq 0 ] && getdb "update user set mount=0 where uid='$USER'";;
			*)secexit;;
		esac

	done
}

#setupenv
umask 0500
if ! tput cols 2>/dev/null >&2; then exit -1; fi
#bind "set disable-completion on"

_cd() {
	return 0
}

PS1="=> "
#	PATH=""
TMP="/tmp/"
TMPDIR="/tmp/"
msg="command restricted"
alias vim="echo vim $msg"
alias cat="echo cat $msg"
alias nano="echo nano $msg"
alias emacs="echo emacs $msg"
alias cd="echo cd $msg"
alias ls="echo ls $msg"
alias touch="echo touch $msg"
alias rm="echo rm $msg"
alias find="echo find $msg"
alias grep="echo grep $msg"
alias alias="echo alias $msg"
wheight=$((`tput lines` - 10))
wwidth=$((`tput cols` - 10))
header="Joe rev13a"
dns="^e[1-3]r[1]?[0-9]p[1-2]?[0-9]$"
ip="^10\.1[1-3]\.([0-9]){1,2}\.([0-9]){1,2}$"
#begin

##login
ok=0;try=0
trap "echo ; exit" INT
now="$(date +%s)"
while [ $ok -ne 1 ]; do
	echo -n "$USER@vpn.42.fr's password: "
	read -rs pass
	echo
	[ "$pass" == "" ] && pass="nope"
	if [ $(($(date +%s) - now )) -ge 10 ]; then exit -1
	elif fullname="$(ldapsearch -x -H "ldaps://ldap.42.fr:636" -b "uid=$USER,ou=august,ou=2013,ou=paris,ou=people,dc=42,dc=fr" -D "uid=$USER,ou=august,ou=2013,ou=paris,ou=people,dc=42,dc=fr" -w "$pass" 2>&1)"; then
#	if curl -skL -c /tmp/.cook -d "{\"login\":\"$USER\",\"password\":\"$pass\"}" https://intra.42.fr/ | grep -i "Bienvenue" >/dev/null;then 
		ok=1;if [ "`getdb "select id from user where uid='$USER'"`" == "" ]; then insdb "$USER" ; fi
	elif [ $try -eq 2 ]; then echo "Permission denied (publickey,keyboard-interactive).";exit -1
	else echo "Permission denied, please try again.";((try++))
	fi
done

##profile
tput civis
#tput smcup
sqlmmriz=`getdb "select memrize from user where uid='$USER'"`
fullname="$(echo "$fullname" | grep "cn: " | cut -d' ' -f2-)"
header="$header - $fullname"
trap "" 1 2
if [ $sqlmmriz -eq 1 ] || res="$(disclaimer 3>&1 >&2 2>&3)"; then
	if [ "$res" != "" ]; then
		putdb "user" "memrize" "1" "uid" "$USER"
	fi
else secexit ; fi
manager
#exit
secexit
