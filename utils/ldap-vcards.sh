while read uid
do
touch $uid.vcf
ldapsearch -x -D uid=nsaintot,ou=august,ou=2013,ou=paris,ou=people,dc=42,dc=fr -w password -LLL uid=$uid > tmp
first=$(cat tmp | grep -E "^first-name:" | sed "s/first-name: //g" | tr -d '\n');
last=$(cat tmp | grep -E "^last-name:" | sed "s/last-name: //g" | tr -d '\n');
birth=$(cat tmp | grep -E "^birth-date:" | sed "s/birth-date: //g" | sed "s/000000Z$//g");
mobile=$(cat tmp | grep -E "^mobile-phone:" | sed "s/mobile-phone: //g" | tr -d '\n');
ldapsearch -x -D uid=nsaintot,ou=august,ou=2013,ou=paris,ou=people,dc=42,dc=fr -w password -LLL uid=$uid picture > tmp
pic=$(cat tmp | grep -v "dn:" | sed "s/picture:: //g" | tr '\n' ' ' | sed "s/ //g");

echo "BEGIN:VCARD
VERSION:3.0
N:$last;$first;;;
FN:42 $first $last
NICKNAME:$uid
EMAIL;type=INTERNET;type=HOME;type=pref:$uid@student.42.fr
TEL;type=CELL;type=VOICE;type=pref:$mobile
BDAY:$birth
CATEGORIES:42
PHOTO;ENCODING=b;TYPE=JPEG:$pic
END:VCARD" >> $uid.vcf

done
rm tmp

