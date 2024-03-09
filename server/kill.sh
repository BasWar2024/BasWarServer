#!/bin/sh

PID_ROOT=.
status=`sh status.sh`
if [ "$status" != "start" ]; then
	echo "aready stop"
	exit;
fi
pidfile=$PID_ROOT/skynet.pid
kill -9 `cat $pidfile`
