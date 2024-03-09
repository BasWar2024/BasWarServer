#!/bin/sh
PID_ROOT=.
if [ -f $PID_ROOT/debug_console.txt ]; then
    . $PID_ROOT/debug_console.txt
fi
if [ $# -gt 1 ]; then
    serverid=$1
fi

sh stop.sh && sleep 10 && sh start.sh $serverid
