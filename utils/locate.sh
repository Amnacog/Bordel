#!/bin/zsh
##nsaintot
user="$@"
if [ "$user" = "-all" ]; then user=$(cat logins); fi
w=0
if [ ! "$user" ]; then echo "Usage: locate.sh <students> [ -all (for all promo) ]" ; exit -1 ; fi
crawler="https://dashboard.42.fr/crawler/pull/"
nuser=$(echo "$user" | wc -w)
lenght=$(expr $COLUMNS - 13)
lc=$(expr $lenght - 40)
for (( i=1; i<=$nuser; i++ ))
do
   parseuser=$(echo "$user" | cut -d' ' -f$i)
   crawl=$(curl $crawler$parseuser/ -s | tr ',\|}' '\n' | tr '\"' '.')
   login=$(echo $crawl | grep login | cut -d'.' -f4)
   t=''
   if [ `printf "$login" | wc | tr -d " "` -le 5 ]; then t="\t"; fi
   poste=$(echo $crawl | grep last_host | cut -d'.' -f4)
   active=$(echo $crawl | grep last_activity | cut -d'.' -f3 | cut -d' ' -f2)
   if [ $active ]; then
      if [ $active -le 1 ]; then active=$(printf "%*s\n" $lenght "\t\e[0;32m$active\e[0m minutes ago")
      elif [ $active -le 10 ]; then active=$(printf "%*s\n" $lenght "\t\e[0;33m$active\e[0m minutes ago")
      else active=$(printf "%*s\n" $lenght "\t\e[0;31m$active\e[0m minutes ago")
      fi
      echo $login "\e[4m" $poste "\e[0m" $active
   else
      ((w++))
      echo -n "\e[0;31mNo data found for user : $parseuser\e[0m \t$t"
      if [ $w -ge 1 ]; then printf "%*s\n" $lc "$w"; fi
   fi
done
resultoff=$(($w * 100 / $i))
resulton=$((100 - $resultoff))
if [ $i -gt 2 ]; then echo "\e[0;32m$resulton%\e[0m Students Found/Online"; fi
