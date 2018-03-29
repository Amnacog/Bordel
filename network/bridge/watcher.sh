#!/bin/bash
cat ct
i=10
min=$(date +"%M")
if [ $min -gt 00 ] && [ $min -le 20 ]; then
	way=20
	cpt="e3r3p8"
elif [ $min -gt 20 ] && [ $min -le 40 ]; then
	way=40
	cpt="e3r3p9"	
else
	way=60
	cpt="e3r3p10"
fi
remain=$(expr $way - $min)
nums=$(who | grep joe | wc -l)
if who | grep joe >/dev/null; then
	echo "logged x$nums at $cpt and remain in $remain min"
	if [ $remain -eq 1 ]; then
		echo -e "\033[0;33mWarning:\033[0m Connection will be interrupted in 60s" > /dev/$(who | grep joe | cut -d' ' -f7)
		sleep 50
		while [ $i -gt 0 ]; do
			echo -e "\033[0;33mWarning: \033[0m Disconnect in $i sec"  > /dev/$(who | grep joe | cut -d' ' -f7)
			sleep 1
			((i--))
		done
	fi
else
	echo "No connection"
fi
