#! /bin/sh
pidfile=skynet.pid
if ! [ -f $pidfile ]; then
    echo "robot not start"
    exit 0;
fi
pid=`cat $pidfile`
tempdate=`ps -p $pid -o lstart | grep -v STARTED`
starttime=`date -d "$tempdate" +%s`


# now timestamp
stoptime=`date +%s`
printf "starttime=%d,stoptime=%d\n" $starttime $stoptime
stopdate=`date +"%Y-%m-%d %H:%M:%S" -d @$stoptime`
startdate=`date +"%Y-%m-%d %H:%M:%S" -d @$starttime`
printf "startdate=%s,stopdate=%s\n" "$startdate" "$stopdate"

if ! [ -f report.txt ]; then
    echo "no report.txt"
    exit 0;
fi
. ./report.txt
# todo report
