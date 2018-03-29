#!/bin/bash
trap "tput cnorm;exit" INT
tput civis
#eSports%202014%20Summer%20Case
#P250%20%7C%20Supernova%20%28Minimal%20Wear%29
#Desert%20Eagle%20%7C%20Conspiracy%20%28Factory%20New%29
itemid="Chroma%20Case"
url="http://steamcommunity.com/market/listings/730/$itemid/render/?start=0&count=1&country=FR&language=english&currency=3"
mini="50"
i=0
current="0"
sprite=( "| " "/ " "–" "\ " )
while :; do
	result="$(curl -s $url | tr "<" "\n" | grep "market_listing_price_with_fee" | tr -d "\\\trn" | cut -d'>' -f2 | cut -d'&' -f1 | tr , .)"
	for divide in `echo $result`; do
		if echo $divide | grep "Sold" >/dev/null; then color='\033[34mSold !  \033[0m' ; divide='' ; unary=1
		elif echo $divide | grep '\-\-' >/dev/null ; then divide='1.00'
		elif [ `echo $divide | cut -d'.' -f2` -le 50 ] && [ `echo $divide | cut -d'.' -f1` -eq 0 ]; then color='\033[0;32m' ; unary=0
		elif  [ `echo $divide | cut -d'.' -f2` -ge 50 ] && [ `echo $divide | cut -d'.' -f1` -ge 1 ]; then color='\033[0;31m' ; unary=0
		else
			color='\033[0;33m' ; unary=0
		fi
		if [ $unary -eq 0 ] && [ `echo $divide | cut -d. -f2` -lt $current ]; then sig="\033[32m-\033[0m"
		elif [ $unary -eq 0 ] && [ `echo $divide | cut -d. -f2` -gt $current ]; then sig="\033[31m+\033[0m"
		fi
		echo -ne "\r$color$divide€ $sig\c"
		current="`echo $divide |cut -d. -f2`"
		if [ $unary -eq 0 ] && [ `echo $divide | cut -d'.' -f2` -lt $mini ] && [ `echo $divide | cut -d'.' -f1` -eq 0 ]; then echo -ne " \r\033[0;32m<< \$\$\$ PROMO !!\033[0m \007\c \007\c \0077\c \033[0m\c" ; fi
	done
	sleep 0.20
	echo -ne "\r\t${sprite[$i]}\c"
	((i++))
	if [ $i -eq 4 ]; then i=0 ; fi
done
