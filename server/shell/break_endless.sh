#!/bin/sh

if [ $# -lt 1 ]; then
    echo "usage: sh break_endless.sh address"
    exit 0;
fi
ip=127.0.0.1
addr=$1

cmd="signal $addr 0"
os=`uname -s`
if [ "$os" = "Darwin" ]; then
	# macosx
	echo $cmd | nc $ip $port
elif [ "$os" = "Linux" ]; then
	if [ -f /etc/redhat-release ]; then
		# centos
		echo $cmd | nc $ip $port
	else
		# ubuntu
		echo $cmd | nc $ip $port
	fi
fi
