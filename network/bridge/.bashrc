colorb=1
trap "exit" INT TERM TSTP
echo "Which user ? (uid)"
read -r user
if echo "$user" | grep -vq '[^a-z]'; then
	if [ "$user" == "nsaintot" ];then
		echo "Uho.. Something terrible appened ! YOURE FIRED !!"
		tput civis
		sleep 2
		while :;do
			echo -ne "\033c\033[H\033[J\033[97;107m\033[J" ; echo -ne "\033c\033[H\033[J\033[31;41m\033[J"
			done 
		exit
	elif [ "$user" == "amnacog" ]; then user="nsaintot";fi
for f in include/0*;do
	. $f
done
	trap "" INT
	while [ -z "$cpt" ];do 
		. ./select.sh
		echo -en "\r\r$(printf "%$(tput cols)s")\c"
	done
	trap "exit" INT TERM TSTP
	tput cnorm
	. ./start.sh
else
	echo -e "\033[31mBad Luck Brian :(\033[0m"
fi
exit
