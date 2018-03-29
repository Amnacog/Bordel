#!/bin/bash
url="ratp.fr/horaires/fr/ratp/bus/prochains_passages/PP/B107/107_1476_1523/R"
pat="<td>Ecole Veterinaire-Metro</td><td>"
min=$(curl $url -s | grep "$pat" | head -n 1 | cut -d'>' -f4 | cut -d' ' -f1)
if [ "$min" == "A" ]; then min="1" ; mess="A l'approche" ; fi
if [ ! "$min" ]; then echo "No info"; exit ; fi
if [ $min -ge 10 ]; then col="\033[0;32m"
elif [ $min -ge 5 ]; then col="\033[0;33m"
else col="\033[0;31m" ; echo -ne '\007\c' | awk '{printf $0 "\033[0;31m⚠ Hurry Up ⚠ \033[0m"}' ; fi
if [ "$mess" ]; then min=$mess; fi
echo -e "Prochain bus dans: $col$min \033[0mMinutes"
#| awk '{printf $0 \"⚠ Hurry Up ⚠ \"}'
