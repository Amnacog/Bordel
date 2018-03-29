#!/bin/bash
declare -A cumi incident clusters
function getdb {
mysql -u cumi --password="password" cumi <<END
select * from $1;
END
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

getarray "clusters"
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

row=1;col=1
while [ "${clusters[$row,$col]}" != "" ];do
	row=1
	while [ "${clusters[$row,$col]}" != "" ]; do
		echo -ne "${clusters[$row,$col]}\t" ; ((row++))
	done
	echo
	((col++))
done

while read arr; do
	i=`echo $arr | cut -d, -f1`
	j=`echo $arr | cut -d, -f2`
	echo "${clusters[$i,$j]}"
done
