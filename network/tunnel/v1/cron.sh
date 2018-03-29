#!/bin/bash
ways=("0 20 40")
aw=($ways)
rand=${aw[$((RANDOM%3))]}
cron=$(crontab -l | grep "MAILTO")
arg="$@"
if [ ! "$arg" ]; then (printf -- "") | crontab ; echo -e "Crontab deleted" ; exit 0 ; fi
if [ "$cron" == "" ]; then
   cat <(crontab -l) <(echo -e "MAILTO=nsaintot@student.42.fr") | crontab -
   noptions=$(echo "$arg" | wc -w)
   for (( i=1; i<=$noptions; i++ ))
   do
      out=$(echo "$arg" | cut -d' ' -f$i)
      if [ "$out" == "backup" ]; then cat <(crontab -l) <(echo "0 * * * * bash /nfs/zfs-student-3/users/2013/nsaintot/42/scripts/backup.sh Run 42.conf") | crontab - ; fi
      if [ "$out" == "ext" ]; then cat <(crontab -l) <(echo "0/30 * * * * bash /nfs/zfs-student-3/users/2013/nsaintot/42/scripts/ext.sh") | crontab - ; fi
      if [ "$out" == "oob" ]; then cat <(crontab -l) <(echo "$rand * * * * bash /nfs/zfs-student-3/users/2013/nsaintot/tl/oob.sh auto") | crontab - ; fi
      if [ "$out" == "odb" ]; then cat <(crontab -l) <(echo "0/5 * * * * bash /nfs/zfs-student-3/users/2013/nsaintot/tl/odb.sh") | crontab - ; fi
  done
   echo -e "Crontab installed"
   echo "$(crontab -l)"
else
   (printf -- "") | crontab
   echo -e "Crontab deleted"
fi
