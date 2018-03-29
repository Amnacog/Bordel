trap "exit -1 ; exit" INT
ok=0
if [ "$1" != "-no" ] && [ "$1" == "-n" ]; then osascript -e 'tell application "System Events" to key code 103'; fi
if [ "$1" != "-n" ] &&  [ "$1" != "-no" ]; then ~/42/scripts/lockscreen/loc/lockscreen "~~~AFK~~~"; fi
#lock
#~/42/scripts/switchdevice -s "Built-in Output" 1>/dev/null
#osascript -e "set Volume 7"
#mpg123 ~/Music/Lock.mp3 2>/dev/null
#osascript -e "set Volume 0"
#~/42/scripts/switchdevice -s "Unknown USB Audio Device" 1>/dev/null
#sleep 0.1
#osascript -e "set Volume 0"
mada(){
	sleep 120 && ~/home.sh umount space 2>/dev/null
#   sleep 1200
#   if ps aux | grep -v grep | grep lockscreen ; then /Volumes/DATA/42/madagascar ; fi
}
mada &
while [ $ok -eq 0 ] ;do
	if ! kill -0 `pgrep lockscreen` 2>/dev/null >&2 ; then /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend ; ok=1 ; fi
	wifi=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ BSSID/ {print substr($0, index($0, $2))}')
	if system_profiler SPUSBDataType | grep "SH19JV805666\|FA386W900068" >/dev/null || [ "$wifi" == "84:7a:88:67:bc:f" ] || [ $ok -eq 1 ]; then
	ok=1
	echo "\033[0;32mHtc One Detected !"
	kill -9 $(pgrep sleep) 2>/dev/null >&2
#      kill -9 $(pgrep madagascar) 2>/dev/null
while kill -0 $(pgrep lockscreen) 2>/dev/null >&2;do kill -9 $(pgrep lockscreen) 2>/dev/null >&2;done
      #unlock
#      ~/42/scripts/switchdevice -s "Built-in Output" 1>/dev/null
#      osascript -e "set Volume 7"
#      mpg123 ~/Music/Unlock.mp3 2>/dev/null
#      osascript -e "set Volume 1"
#      ~/42/scripts/switchdevice -s "Unknown USB Audio Device" 1>/dev/null
#      osascript -e "set Volume 1"
	~/home.sh
	if [ "$1" == "-n" ]; then osascript -e 'tell application "System Events" to key code 103'; fi
		exit
	fi
done
trap - INT
