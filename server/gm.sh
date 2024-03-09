#!/bin/sh

PID_ROOT=.
. $PID_ROOT/debug_console.txt
cmdline=$@
if [ "$cmdline" = "" ]; then
	echo 'sh gm.sh ID  ...'
	echo ':'
	echo 'sh gm.sh #'
	echo 'sh gm.sh 0 help help'
	echo 'sh gm.sh 0 exec '"'"'print(\"hello\")'"'"
	echo 'curl '"'"'http://127.0.0.1:18888/call/8 "gm","0 exec print(\"hello\")"'"'"
    echo 'sh gm.sh 0 hotfix "'"app.game.client.login gg.base.util.table"'"'                   # app.game.client.login+gg.base.util.table
    echo 'sh gm.sh 0 hotfix "'"src/app/game/client/login.lua src/gg/base/util/table.lua"'"'   # app.game.client.login+gg.base.util.table
	exit 0;
fi

filename=log/gm/gm`date +"%Y-%m-%d"`.log
before_lines=0
if [ -f $filename ]; then
	before_lines=`wc -l $filename | awk '{print $1}'`
fi

ip=127.0.0.1

cmd="call $address \"gm\",\"$cmdline\""
os=`uname -s`
if [ "$os" = "Darwin" ]; then
	# macosx
	echo $cmd | nc -i 1 $ip $port
elif [ "$os" = "Linux" ]; then
	if [ -f /etc/redhat-release ]; then
		# centos
		echo $cmd | nc -d 1 $ip $port
	else
		# ubuntu
		echo $cmd | nc -q 1 $ip $port
	fi
fi

after_lines=0
if [ -f $filename ]; then
	after_lines=`wc -l $filename | awk '{print $1}'`
fi
if [ $before_lines = $after_lines ]; then
	# ,2s
	sleep 2;
	if [ -f $filename ]; then
		after_lines=`wc -l $filename | awk '{print $1}'`
	fi
fi
lines=$(expr $after_lines - $before_lines)
tail -$lines $filename
