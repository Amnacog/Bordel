cd "$(dirname "$0")" && pwd -P
	echo "Start $0"
    mkdir .tmp/ext/
    if ./sshpass -p password scp amnacog@vzone.dyndns.org:~/ext/* ./.tmp/ext/; then
	echo "Received command"
else
	echo "Connection error"
	exit
fi

##exe
cd .tmp/ext/
if bash commands.sh >> log.txt; then
   echo "override"
else
   echo "No command this time"
   rm -rf ../ext
   exit
fi

##send log
if ../.././sshpass -p password scp log.txt amnacog@vzone.dyndns.org:~/ext/; then
	echo "Log file send"
	cd ../../
	rm -r .tmp/ext/
	echo "Clean & Done"
else
	echo "error"
fi
