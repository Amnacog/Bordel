#!/bin/bash
query="$(ldapsearch 2>/dev/null | grep "dn:")"
echo "$query" | uniq > ldapauth
list=""
for user in $(echo $query | cut -d' ' -f2-); do
	if echo $user | grep "uid" >/dev/null; then
		list="$list $(echo -n "$(echo $user | sed 's/\,.*//g' | cut -d'=' -f2)")"
	fi
done
echo "$list" | uniq > logins
echo "$(echo "$query" | uniq | wc -l) entries updated"
