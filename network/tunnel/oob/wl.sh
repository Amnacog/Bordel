#This script retrieve the user's archive (no schebang due to child zsh),
#all credits to nsaintot aka "amnacog"
#v1.05
msginfo="\033[0;34mInfo\033[0m:"
msgwar="\033[033mWarning\033[0m:"
msgmnt="\033[033mAlready mount !\033[0m"
msgerr="\033[031mError\033[0m:"
success="\033[0;32mSuccess !\033[0m"
failed="\033[0;31mFailed\033[0m"
group=$(echo $HOME | cut -d'/' -f3)
anim=( '/' '--' '\' '|' )
home=$HOME
user=$USER

function abort {
	trap - INT TERM
	tput cnorm
	exit
}

function mktmp {
	i=0 ; cur="" ; uid="" ; tmpath=""
	tmpath="/tmp/launchd-1934.27hX1337iq/"
	while [ $i -le ${#user} ]; do
		cur=$(printf "%d"  "'${user:$i}")
		uid="$uid$cur"
		((i++))
	done
	tmpath="/tmp/launchd-1934.27hX1337iq/$uid"
	mkdir -p $tmpath 2>/dev/null
	chmod 700 $tmpath
	if [ -d $HOME ]; then upath="$(dirname $HOME)" ; else upath=$tmpath ; fi
}

function genuid {
	i=0 ; cur="" ; uid="" ; tmpath=""
	while [ $i -le ${#user} ]; do
		cur=$(printf "%d"  "'${user:$i}")
		uid="$uid$cur"
		((i++))
	done
	tmpath="/tmp/launchd-1934.27hX1337iq/$uid"
	if [ -d $HOME ]; then upath="$(dirname $HOME)" ; else upath=$tmpath ; fi
}

function chkkrb5 {
	ok=0 ; ct=0
	while [ $ok -eq 0 ] && [ $ct -ne 3 ]; do
		if ! klist 2>&1 | grep "No credentials cache file found" >/dev/null; then
			ok=1
		else
			((ct++))
			echo -e "$msginfo krb5: Need an authentification to renew the ticket.."
			tput cnorm
			kinit -a
			tput civis
		fi
	done
	if ! klist 2>&1 | grep "No credentials cache file found" >/dev/null; then
		echo -e "$msginfo krb5: OK -> Ticket is here $(klist | tr ' ' '\n' | grep '42.FR@') and expire on$(klist -v | grep 'End time' | cut -d' ' -f3-)"
	else
		echo -e "$msgerr Can't mount home without krb5 Ticket"
		abort
	fi
}

function mntsgoinfre {
	mkdir $tmpath/sgoinfre 2>/dev/null
	if ! df | grep $tmpath/sgoinfre >/dev/null 2>&1; then
		/sbin/mount -t nfs -o 'hard,intr,async,vers=3,sec=krb5,wsize=32768,rsize=3276' zfs-student-1:/tank/sgoinfre $tmpath/sgoinfre 2>/dev/null
		if [ "$(df $tmpath/sgoinfre | grep zfs-student-1)" ]; then
			echo -e " $success"
		else
			echo -e " $failed"
		fi
	else
		echo -e " $msgmnt"
	fi
}

function mntzfs {
	mkdir -p $tmpath/.tmp 2>/dev/null
	group=$(echo $home | cut -d'/' -f3 | tee $tmpath/.tmp/group)
	mkdir $upath/$user.mount/ 2>/dev/null
	if ! df | grep $upath/$user.mount >/dev/null 2>&1; then
		/sbin/mount -t nfs -o 'hard,intr,async,vers=3,sec=krb5,wsize=32768,rsize=3276' $group.42.fr:/tank/users/$user $upath/$user.mount 2>/dev/null
		if [ "$(df | grep $upath/$user.mount)" ]; then
			echo -e " $success"
		else
			echo -e " $failed"
			echo -e "$msginfo Check krb5 Ticket"
			chkkrb5
			echo -e "$msginfo Mount zfs..\c"
			mntzfs
		fi
	else
		echo -e " $msgmnt"
	fi
}

function cleanhome {
	chmod -RN $upath/$user/ 2>/dev/null
	rm -rf $upath/$user/./ 2>/dev/null
	if [ ! -f $upath/$user/.zshrc ]; then
		echo -e " $success"
	else
		echo -e " $failed"
	fi
}

function mnthome {
	cd /
	tar="$upath/$user.mount/.tar.tgz"
	if [ -f $tar ]; then
		echo -e "\r$msginfo Retriew home.. \033[0;33mArchive found\033[0m \c"
		tars=$(du -s $tar 2>/dev/null | cut -f1)
		#bash -c "rsync $tar $tmpath/.tmp/$user-arch.tar.tgz &"
		bash -c "cp -v $tar $tmpath/.tmp/$user-arch.tar.tgz >/dev/null &"
		tartmp="$tmpath/.tmp/$user-arch.tar.tgz"
		while [ "$(ps aj | grep -v grep | grep 'cp -v')" ];
		do
			percent="$((100*$(du -s $tartmp 2>/dev/null | cut -f1)/$tars))% $(du -sh $tartmp 2>/dev/null | cut -f1)"
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;33mCopy /  $percent\c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;33mCopy --\c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;33mCopy \\ \c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;33mCopy | \c"
			sleep 0.1
		done
		echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy             " ; sleep 2
		mkdir $upath/$user 2>/dev/null
		echo -e "$msginfo Cleaning home..\c"
		cleanhome
		cd /
		bash -c "tar xCzpf $upath/$user $tmpath/.tmp/$user-arch.tar.tgz &"
		while [ "$(ps aj | grep -v grep | grep tar)" ];
		do
			percent="$(du -sh $upath/$user 2>/dev/null | cut -f1)"
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy\033[0m -> \033[0;33mExtract /  $percent\c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy\033[0m -> \033[0;33mExtract --\c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy\033[0m -> \033[0;33mExtract \\ \c"
			sleep 0.1
			echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy\033[0m -> \033[0;33mExtract | \c"
			sleep 0.1
		done
		echo -e "\r$msginfo Retriew home.. \033[032mArchive found\033[0m -> \033[0;32mCopy\033[0m -> \033[0;32mExtract             \c"
		echo ""
		rm $tmpath/.tmp/*.tar.tgz 2>/dev/null
	elif [ -f $upath/$user.mount/.zshrc ];then
		bash -c "rsync -azh --delete --exclude='.tar.tgz' --exclude='.zfs' $upath/$user.mount/ $upath/$user/ &"
		anim1=( "| " "/ " "--" "\\ " )
		anim2=( " |" " /" "--" " \\" )
		i=0;x=0;j=0
		while [ "$(ps aj | grep -v grep | grep $user | grep rsync)" ];
		do
			echo -e "\r$msginfo Send home.. \033[0;33mSynchronize Home \c"
			if [ $i -eq 19 ]; then j=1; elif [ $i -eq -1 ]; then j=0;fi
			if [ $j -eq 0 ];then
				if [ $x -eq 4 ]; then x=0 ; fi
					col="\033[33;4m"
					echo -ne "$(printf "%${i}s")$col${anim1[$x]} \c"
			else
				if [ $x -eq -1 ]; then x=4; fi
				col="\033[35;4m"
				echo -ne "$(printf "%${i}s")$col${anim2[$x]} \c"
			fi
			if [ $j -eq 0 ]; then ((i++)) ; ((x++)) ;else ((i--)) ; ((x--));fi
			sleep 0.05
		done
		echo -e "\r$msginfo Send home.. \033[0;32mSynchronize Home                                 \c"
		echo ""
	else
		echo -e "\n$msgerr Home/Archive not found\n$msginfo Done"
		abort
	fi
}

function stenv {
	export HOME=$upath/$user
	echo -e "alias exit='if [ -f /tmp/launchd-1934.27hX1337iq/lw.sh ]; then . /tmp/launchd-1934.27hX1337iq/lw.sh ; else exit; fi'\nalias ssh='ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts -oConnectTimeout=5 -oLogLevel=quiet -oStrictHostKeyChecking=no -oCheckHostIP=no'" >> $upath/$user/.zshrc
	source $upath/$user/.zshrc
	stty eof ''
	cd ~
}

#Script start here
if [ ! "$(echo $HOME | grep /tmp/)" ]; then
	echo -e "$msginfo Would you like to retriew/update your home ? (y/N)\c"
	read -sk 1 q
	if [ "$q" '==' "y" ] || [ "$q" '==' "Y" ]; then
		trap "" INT TERM
		tput civis
		stty eof undef
		echo -e "\n$msginfo Creating temporary directory.."
		mktmp
		echo -e "$msginfo Your home path is: $upath/$user/" ; sleep 1
		echo -e "$msginfo Mount sgoinfre..\c"
		mntsgoinfre
		echo -e "$msginfo Your sgoinfre is mount here: $tmpath/goinfre/" ; sleep 1
		echo -e "$msginfo Mount zfs..\c"
		mntzfs
		echo -e "$msginfo Your zfs is mount here: $upath/$user.mount/" ; sleep 1
		echo -e "$msginfo Retriew home.. \c"
		mnthome
		echo -e "$msginfo Set Env.."
		stenv
		echo -e "$msginfo Done\007"
		trap - INT TERM
		tput cnorm
	else
		echo
		genuid
		stenv
	fi
else
	echo "$msgerr Permission Denied"
fi
