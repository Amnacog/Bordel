#!/bin/bash
PROFILE=$(system_profiler SPSoftwareDataType | grep -v 'Normal\|Enabled' | tr -s " " | cut -d':' -f2 | cut -d' ' -f2- | sed '/^$/d' | sed '$d')
INET=$(ifconfig | grep "inet 10" | cut -d' ' -f2)
NW=$(netstat -ib)
PRO=`sysctl -n machdep.cpu.brand_string`
SN=`ioreg -l | grep IOPlatformSerialNumber | awk '{ print $4 }'`
DISK=`df -hl | awk '{print $1" "$4"/"$2" free ("$5" used)"}'`
echo -e "$PROFILE\n$INET\n$PRO\n\n$DISK\n\n$NW"
