#!/bin/bash
gra=$(cat /var/log/ipfm/all-4 | sed '/^#/ d' | tr -s ' ')
i=1
cl=$(echo $gra | wc -l)
inet=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d' ' -f1)

function cpu {
	A=($(sed -n '2,5p' /proc/stat))
	B0=$((${A[1]}  + ${A[2]}  + ${A[3]}  + ${A[4]}))
	B1=$((${A[12]} + ${A[13]} + ${A[14]} + ${A[15]}))
	B2=$((${A[23]} + ${A[24]} + ${A[25]} + ${A[26]}))
	B3=$((${A[34]} + ${A[35]} + ${A[36]} + ${A[37]}))
	sleep 0.2
	C=($(sed -n '2,5p' /proc/stat))
	D0=$((${C[1]}  + ${C[2]}  + ${C[3]}  + ${C[4]}))
	D1=$((${C[12]} + ${C[13]} + ${C[14]} + ${C[15]}))
	D2=$((${C[23]} + ${C[24]} + ${C[25]} + ${C[26]}))
	D3=$((${C[34]} + ${C[35]} + ${C[36]} + ${C[37]}))
	E0=$((100 * (B0 - D0 - ${A[4]}  + ${C[4]})  / (B0 - D0)))
	E1=$((100 * (B1 - D1 - ${A[15]} + ${C[15]}) / (B1 - D1)))
	E2=$((100 * (B2 - D2 - ${A[26]} + ${C[26]}) / (B2 - D2)))
	E3=$((100 * (B3 - D3 - ${A[37]} + ${C[37]}) / (B3 - D3)))
	echo $(( (E0 + E1 + E2 + E3) / 4))
}

function memory {
	a=$(cat /proc/meminfo | tr -s ' ' | cut -d' ' -f2)
	echo $(( 100 - ($(echo "$a" | sed -n 2p) * 100) / $(echo "$a" | sed -n 1p) ))
}

echo -e "{
\t\"hostname\": \"$(hostname)\",
\t\"inet\": \"$inet\",
\t\"cpu\": \"$(cpu)\",
\t\"memory\": \"$(memory)\",
\t\"bandwitdh\": ["

IFS="
"

for lines in $(echo "$gra" | grep $inet); do	
	echo -e "\t\t\"$(echo $lines | cut -d' ' -f1)\": {
\t\t\t\"in\": $(echo $lines | cut -d' ' -f2),
\t\t\t\"out\": $(echo $lines | cut -d' ' -f3),
\t\t\t\"total\": $(echo $lines | cut -d' ' -f4)
\t\t}$([ $i -lt $cl ] && echo ,)"
	((i++))
done
echo -e "\t]\n}"
