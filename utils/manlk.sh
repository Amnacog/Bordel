wifi=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ BSSID/ {print substr($0, index($0, $2))}')
if [ "$wifi" != "18:87:96:13:8a:7a" ] && ! system_profiler SPUSBDataType | grep "SH19JV805666" >/dev/null; then
	if ! ps aux | grep "lockscreen" | grep -v grep >/dev/null; then
		if [ "$wifi" != "18:87:96:13:8a:7a" ]; then
			echo "\033[0;31mWarning lock in 20 sec"
			i=20
			while [ $i -ge 0 ];
			do
				if [ "$wifi" == "18:87:96:13:8a:7a" ] || system_profiler SPUSBDataType | grep "SH19JV805666" >/dev/null; then
					echo "\033[031mCancelled"
					exit 0
				fi
				sleep 0.8
				echo $i
				((i--))
			done
		fi
		echo "locked"
		open ~/42/scripts/lk.sh
		sleep 6
		exit -1
	fi
	echo "unlocked"
	exit 0
fi
