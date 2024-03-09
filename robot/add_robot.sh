#!/bin/sh

if [ $# -lt 2 ]; then
	echo "sh add_robot.sh   [id] "
	echo "eg:"
	echo "sh add_robot.sh 100 match"
	echo "sh add_robot.sh 100 watch"
	echo "sh add_robot.sh 100 team"
	echo "sh add_robot.sh 100 battle"
	echo "sh add_robot.sh 100 chat"
	echo "sh add_robot.sh 100 normal"
	exit 0;
fi

num=$1
testmode=$2
start_pid=$3
ip="127.0.0.1"
port=6666
cmd="start app/service/newrobot $num $testmode $start_pid"

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
