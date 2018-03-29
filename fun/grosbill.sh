#!/bin/bash
url="http://www.grosbill.com/4-asus_n550jk_cm181h_-613839-univers_informatique-univers_informatique"
find="<!-- delivery_container -->"
mail="Subject: Computer reaprovisionned from grosbill !\nFrom: toto@42sh.fr\nTo: someone@whowants.pc\n\nMr. Your N550JK-CM180H was reaprovisionned from our stock,\nand we hope you will buy one in few weeks.\n url: $url"
if [ -f .apr ] && curl -sL $url | grep "$find" >/dev/null; then
	rm .apr
	echo -e "\033[1;32mN550JK Reaprovisioned !!\033[0m"
	echo -e "$mail" | sendmail -t
fi
