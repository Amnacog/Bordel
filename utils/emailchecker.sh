#!/usr/bin/env bash

while read email; do
	sleep 0.5
	(
	domain=$(echo $email | cut -d'@' -f2)
	mxdomain=$(nslookup -q=mx $domain | grep mail\ exchanger | head -n 1 | rev | cut -d'.' -f2- | cut -d' ' -f1 | rev)
	expect <<-POUET
	log_user true
	set timeout 5
	spawn telnet $mxdomain 25
	expect "220" {
		send "HELO $domain\r"
		expect {
			"250" {
				send "mail from:<test@emailchecker.io>\r"
				expect {
					"250" {
						send "rcpt to:<$email>\r"
						expect {
							"250" { exit 5 }
							% { exit 4 }
						}
					}
					% { exit 3 }
				}
			}
			% { exit 2 }
		}
	}
POUET
	ret=$?
	case $ret in
		1) echo "$email -> Internal error u_u"
		;;
		2) echo "$email -> Failed to connect to the delegated server"
		;;
		3) echo "$email -> Failed to talk to the delegated server"
		;;
		4) echo "$email -> Failed to verify the email account"
		;;
		5) echo "$email -> good"
		;;
		*) echo "$email -> Internal error u_u"
	esac
) &
done
