#!/bin/sh

if [ $# -lt 1 ]; then
    echo "sh dmesg_time.sh dmesg_time"
    exit 0;
fi

MY_TIME=$1
date -d "1970-01-01 UTC `echo "$(date +%s)-$(cat /proc/uptime|cut -f 1 -d' ')+$MY_TIME"|bc ` seconds" +'%Y-%m-%d %H:%M:%S'
