#!/bin/bash

usage="Usage: backup.sh <option> <config file>\n"
recommend="See 'backup.sh -help' for more information."
invalid="Invalid syntax on "
options="<option>\nAdd\t\t\tCette opération permet d’ajouter\n\t\t\t l’exécution d’une sauvegarde pour un fichier de configuration\n\t\t\t donné en paramètre. Ce fichier\n\t\t\t doit se trouver dans le répertoire\n\t\t\t prédéfini dans le script\nDelete\t\t\tCette opération permet de supprimer l’exécution\n\t\t\t d’une sauvegarde pour un fichier de configuration\nRun\t\t\tCette opération permet de réaliser la\n\t\t\t sauvegarde pour un fichier de configuration donné en paramètre.\n\t\t\t Ce fichier doit se trouver dans le répertoire\n\t\t\t prédéfini dans le script backup.sh.\n\t\t\t Elle est l’opération à exécuter dans\n\t\t\t les entrées de sauvegardes cron.\nDry-Run\t\t\tCette opération permet de réaliser un essai\n\t\t\t de sauvegarde pour un fichier de configuration donné en paramètre.\n\t\t\t Ce fichier doit se trouver dans le répertoire\n\t\t\t prédéfini dans le script backup.sh.\n\t\t\t Elle est donc sans effet et permet simplement\n\t\t\t de valider le bon fonctionnement de la sauvegarde."
help="$headhelp\n$usage\n$options"
e=0
w=0
b=0
chkcon=0
chkdel=0
chkfull=0
msginfo="\033[0;34mInfo\033[0m:"
msgwar="\033[0;33mWarning\033[0m: in config '"
msgerr="\033[1;31mError\033[m: in config '"
msgerrs="\033[1;31mError\033[m: "
msgsuccess="$msginfo \033[0;32mSuccess\033[m"

#functions######################################################################################
function chkserv
{
	addr="$1"
	key="$2"
	port="22"
	cip="1"
	cdns="1"
	#valid ip/dns
	if [ $cip -eq 0 ]; then
		if [ $cdns -eq 0 ]; then
			echo -e "$msgerr$config': at '$key': Not a valid address"
			((e++))
			chkcon=1
		fi
	fi
	if [ ! $chkcon -eq 1 ]; then
		if [ $transfer == "rsync" ]; then
			$port="187 22"
		fi
		echo -ne "$msginfo Check server-side connectivity..."
		con="0"
		if [ $con -eq 1 ]; then
			echo -ne "\b\033[0;33mServer Timeout\033[0m\n"
			echo -e "$msgwar$config': at '$key': The server returned an error"
			((w++))
		else
			echo -ne "\b\033[0;32mSuccess\033[0m\n"
		fi
	fi
}

function chkconfile
{
	#check config file exist
	if [ ! -f $config ]; then
		echo -e "$msgerr$config': Config file '$config' doesn't exist"
		((e++))
		exit
	#check empty fields
	elif [ ! $(cat "$config" | grep -c \"\") -eq 0 ]; then
		echo -e "$msgerr$config': At least one of the keys has not been filled.."
		((e++))
	fi
	source $config
}

function chksyntax
{
	echo -e "$msginfo Checking config file '$config'.."

#test keys

##files
	if [ $chkfull -eq 1 ]; then
		nfiles=$(echo "$files" | wc -w)
		for (( i=1; i<=$nfiles; i++ ))
		do
			cfile=$(echo "$files" | cut -d' ' -f$i)
			if [ ! -d $cfile ]; then
				if [ ! -f $cfile ]; then
					echo -e "$msgwar$confname' at '\$files': $cfile not found"
					((w++))
				fi
			fi
		done
	fi

##save
	if [ $(echo "$save" | grep -c "[0-9]") -eq 0 ]; then
		echo -e "$msgerr$confname' at '\$save': Not numeric value set"
		((e++))
	fi

##compression method
	if [ $compression != "gzip" ] && [ $compression != "bzip2" ]; then
		echo -e "$msgerr$confname' at '\$compression' Must be => 'gzip' or 'bzip2' value"
		((e++))
	fi

##backup method
	if [ $method != "full" ] && [ $method != "incremental" ]; then
		echo -e "$msgerr$confname' at '\$method' Must be => 'total' or 'incremental' value"
		((e++))
	fi

##transfer method (also check child keys)
	if [ $transfer != "local" ] && [ $transfer != "scp" ] && [ $transfer != "rsync" ] && [ $transfer != "Dropbox" ]; then
		echo -e "$msgerr$confname' at '\$transfer' Must be => 'local' , 'scp' , 'rsync' or 'Dropbox' value"
		((e++))
	fi

	if [ $chkfull -eq 1 ]; then
		case "$transfer" in
        		local)	if [ ! -d "$path" ]; then echo -e "$msgwar$config' at '\$path': $path not found.."
					((w++))
				fi;;
        		scp)	chkserv $scp_server \$scp_server;;
      			rsync)	chkserv $rsync_server \$rsync_server;;
        		Dropbox)
        	esac
	fi
}

function result
{
	echo -en "$msginfo '$config': You have \033[0;31m$e\033[0m errors and \033[0;33m$w\033[0m warnings"
	if [ $e -eq 0 ] && [ $w -eq 0 ]; then
		echo -en ": \033[0;32mConfig is valid\033[0m\n"
	elif [ $e -eq 0 ]; then
		echo -en "\n"
	else
		echo -en ": \033[1;31mConfig is not valid\033[0m\n" ; exit 1
	fi

}

###

function chkcron
{
	dirpath=$(cd "$(dirname "$0")" && pwd -P)
	crupdate=$(crontab -l | grep -ci $config)

	if [ $chkdel -eq 1 ];then
		if [ $crupdate -eq 0 ]; then
			 echo -e "\033[1;31mError\033[m: No job entry for $confname"
		else
			(crontab -l | grep -Fv $config) | crontab
                        echo -e "$msginfo Cron job removed"
		fi
	else
		if [ $crupdate -eq 0 ]; then
			(crontab -l | grep -Fv $config ; printf -- "$frequency bash $dirpath/backup.sh Run $config\n") | crontab
			echo -e "$msginfo Cron job added"
		else
			echo -e "$msginfo Cron job already exist\n$msginfo Cron job updated"
		fi
	fi
}

###

function createback
{
   fileformat="$confname $(date +"%Y-%m-%d %H:%M:%S") $(echo "$method")"
   if [ "$transfer" == "local" ]; then
      occback=$(find $path -name "$confname*.tgz" -o -name "$confname*.tgz.bz2" | wc -l)
	  oldestback=$(ls -t1 $path$confname*.{tgz,tgz.bz2} 2> /dev/null | tail -n1)
	  if [ $occback -ge $save ]; then
		 rm "$oldestback"
		 echo -e "$msginfo Backup limit exceed.\n$msginfo Deleted oldest Backup"
	  fi
   else
	  path="./.tmp/"
	  method="full"
	  if [ ! -d $path ]; then mkdir $path; fi
   fi

   if [ "$method" == "full" ]; then
	  if [ "$compression" == "gzip" ]; then
		 tar -cpzhf "$path$fileformat.tgz" $files
	  elif [ "$compresson" == "bzip2" ]; then
		 tar -cpjhf "$path$fileformat.tgz.bz2" $files
	  fi
   elif [ "$method" == "incremental" ]; then
	  if [ "$compression" == "gzip" ]; then
		 tar --listed-incremental="$path$confname.lst" -cpzhf "$path$fileformat.tgz" $files
	  elif [ "$compression" == "bzip2" ]; then
		 tar --listed-incremental="$path$confname.lst" -cpzhf "$path$fileformat.tgz.bz2" $files
	  fi
   fi
   latestback=$(ls -tr1 $path$condname*.{tgz,tgz.bz2} 2> /dev/null | tail -n1)
   echo -e "$msginfo Sending backup.."
}

function createdbcon
{
	dbcookie="$path/tmp-dbcookie.txt"
	dbrcookie="$path/tmp-dbrcookie.txt"
	logindblink="https://www.dropbox.com/login"
	curl -b a -c $dbcookie -o $dbrcookie -d "t=$(curl -c a $logindblink | sed -rn 's/.*TOKEN: "([^"]*).*/\1/p')&login_email=$db_login&login_password=$db_pass" $logindblink

		if [ $? -ne 0 ]; then
			echo -e "$msgerrs Login info:\n $(cat $dbrcookie)"
		else
			echo -e "$msginfo Logged on Dropbox"
		fi
}

function runback
{
	case "$transfer" in
		local)  createback;;
		scp)  createback
			if ./sshpass -p $scp_pass scp -rp "$latestback" $scp_login@$scp_server:$scp_dir; then
				echo -e "$msgsuccess"
			else
				echo -e "$msgerrs$?"
			fi
			rm $path/*
			;;
		rsync)	if ./sshpass -p $rsync_pass rsync -iz "$files" $rsync_login@$rsync_server:$rsync_dir; then
				echo -e "$msgsuccess"
			else
				echo -e "$msgerrs$?"
			fi
			;;
		ropbox)	createback
			createdbcon
			;;
	esac

}

###Actions parameter functions call

function Test-config
{
	chkconfile
	chksyntax
	result
}

function Add
{
	Test-config
	chkcron
}

function Delete
{
	chkdel=1
	chkcron
}

function Run
{
	chkfull=1
	Test-config
	if [ $w -eq 0 ]; then runback; fi
}

function Dry-Run
{
	chkfull=1
	Test-config
}



#################################SCRIPT START HERE###################################
cd "$(dirname "$0")" && pwd -P
#Control the start
if [ "$1" = "-help" ]; then
	echo -e $help
	exit 0
elif [ $# -ne 2 ]; then
	echo -e $usage$recommend
	exit 0
fi

#test parameters
a="$msginfo '$1' option choosed.."
config="$2"
confname=$(basename $config | cut -d'.' -f1)
case "$1" in
	Test-config) echo -e $a
		Test-config
		;;
	Add) echo -e $a
		Add
		;;
	Delete) echo -e $a
		Delete
		;;
	Run) echo -e $a
		Run
		;;
	Dry-Run) echo -e $a
		Dry-run
		;;
	*) echo -e "Bad Option '$1'\n$recommend"
		exit 1
		;;
	esac
	exit 0
