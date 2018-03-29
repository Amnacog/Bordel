#/bin/zsh
#This script logout the current user and send the tarball to zfs
#all credits to nsaintot aka "amnacog"
#v1.05
msginfo="\033[0;34mInfo\033[0m:"
success="\033[0;32mSuccess !\033[0m"
home=$HOME
homedir=$(dirname $home)
user=$(whoami)

function genuid {
	i=0 ; cur="" ; uid="" ; tmpath=""
	while [ $i -le ${#user} ]; do
		cur=$(printf "%d"  "'${user:$i}")
		uid="$uid$cur"
		((i++))
	done
	tmpath="/tmp/launchd-1934.27hX1337iq/$uid"
}

function tarhome {
	if [ -f $homedir/$user.mount/.tar.tgz ]; then
		mkdir -p $tmpath/.tmp 2>/dev/null
		hsize=$(du -s $homedir/$user 2>/dev/null | cut -f1)
		bash -c "tar czpf $tmpath/.tmp/.tar.tgz -C $homedir/$user/ . &"
		sleep 2
		while [ "$(ps aj | grep -v grep | grep tar)" ];
		do
			percent="$((100*$(du -s $tmpath/.tmp/.tar.tgz 2>/dev/null | cut -f1)/$hsize))% $(du -sh $tmpath/.tmp/.tar.tgz 2>/dev/null | cut -f1)"
			echo "\r$msginfo Send home.. \033[0;33mTar in progress /  $percent\c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;33mTar in progress --\c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;33mTar in progress \\ \c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;33mTar in progress | \c"
			sleep 0.1
		done
		if [ ! "$(df | grep $homedir/$user.mount)" ]; then
			login -lf $user mount -t nfs -o 'hard,intr,async,vers=3,sec=krb5,rsize=524288,wsize=524288' $(cat $tmpath/.tmp/group).42.fr:/tank/users/$user $homedir/$homedir/$user.mount/ >/dev/null
		fi
		mv $homedir/$user.mount/.tar.tgz $homedir/$user.mount/.tar.tgz.old
		htar=$(du -s $tmpath/.tmp/.tar.tgz 2>/dev/null | cut -f1)
		bash -c "rsync --progress $tmpath/.tmp/.tar.tgz $homedir/$user.mount/ &"
		while [ "$(ps aj | grep -v grep | grep rsync)" ];
		do
			#percent="$((100*$(du -s $homedir/$user.mount/.tar.tgz | cut -f1 2>/dev/null)/$htar))%\t$(du -sh $homedir/$user.mount/.tar.tgz | cut -f1 2>/dev/null)%"
			echo "\r$msginfo Send home.. \033[0;32mTar in progress -> \033[0;33mCopy / \c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;32mTar in progress -> \033[0;33mCopy --\c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;32mTar in progress -> \033[0;33mCopy \\ \c"
			sleep 0.1
			echo "\r$msginfo Send home.. \033[0;32mTar in progress -> \033[0;33mCopy | \c"
			sleep 0.1
		done
		echo "\r$msginfo Send home.. \033[0;32mTar in progress -> \033[0;32mCopy  "
		rm $tmpath/.tmp/.tar.tgz 2>/dev/null
	else
		if [ ! "$(df | grep $homedir/$user.mount)" ]; then
			mount -t nfs -o 'hard,intr,async,vers=3,sec=krb5,rsize=524288,wsize=524288' $(cat $tmpath/.tmp/group).42.fr:/tank/users/$user/$home/ $homedir/$user.mount/ >/dev/null
		fi
		bash -c "rsync -azh --delete --exclude='.tar.tgz' --exclude='.zfs' $homedir/$user/. $homedir/$user.mount/ &"
		anim1=( "| " "/ " "--" "\\ " )
		anim2=( " |" " /" "--" " \\" )
		i=0;x=0;j=0
		while [ "$(ps aj | grep -v grep | grep $user | grep rsync)" ];
		do
				echo -e "\r$msginfo Send home.. \033[0;33mSynchronize Home\033[0m \c"
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
		echo -e "\r$msginfo Send home.. \033[0;32mSynchronize Home                      "
	fi
}

function zfs {
	i=0
	while [ "$(df | grep $homedir/$user.mount)" ];
	do
		umount -f $homedir/$user.mount 2>/dev/null
		printf %$i\s | tr " " "."
		sleep 0.2
		((i++))
	done
	echo "Done"
}

function sgoinfre {
	i=0
	while [ "$(df | grep $tmpath/sgoinfre)" ]; do
		umount -f $tmpath/sgoinfre 2>/dev/null
		printf %$i\s | tr " " "."
		sleep 0.2
		((i++))
	done
	echo "Done"
}

if [ -d $homedir/$user/Library ]; then
	echo "$msginfo [Exit Session] Do you want to save/upload your work ? (y/N)\c"
	read -sk 1 q
	echo ""
	if [ "$q" '==' "Y" ] || [ "$q" '==' "y" ]; then
		trap "" INT TERM ; tput civis; stty eof undef
		echo "$msginfo Please wait during process"
		sed -i '' '/alias exit=/d' $home/.zshrc
		sed -i '' '$ d' $home/.zshrc
		genuid
		tarhome
		echo "$msginfo Unmount zfs..\c"
		zfs
		echo "$msginfo Unmount sgoinfre..\c"
		sgoinfre
		echo "$msginfo Done"
		echo "$msginfo Exiting Now.."
		tput cnorm
		\exit 2>/dev/null
	else
		echo "$msginfo Exiting Now.."
		tput cnorm
		sed -i '' '/alias exit=/d' $home/.zshrc
		sed -i '' '$d' $home/.zshrc
		\exit 2>/dev/null
    fi
else
	echo -e "$msginfo Exit ? (Y/n)\c"
	read -sk 1 p
	echo ""
	if [ "$p" '!=' "n" ] || [ "$p" '==' "N" ]; then
		sed -i '' '/alias exit=/d' $home/.zshrc
		sed -i '' '$d' $home/.zshrc
		echo "$msginfo Exiting Now.."
		\exit 2>/dev/null
	fi
fi
