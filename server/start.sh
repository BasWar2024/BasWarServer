#!/bin/sh

SKYNET_ROOT=.
PID_ROOT=.
if [ $# -lt 1 ]; then
    current_dirname=`pwd`
    servername=`basename $current_dirname`
    if [ "$servername" = "server" ]; then
        path=`readlink -f $current_dirname/../`
        servername=`basename $path`
    fi
else
    servername=$1
fi

config=$servername.config
if [ ! -f src/config/$config ]; then
    echo "config file not exist: src/config/$config"
    exit 0;
fi

status=`sh status.sh`
if [ "$status" = "start" ]; then
    echo $servername "aready start"
    exit;
elif [ "$status" = "killed" ]; then
    rm $PID_ROOT/skynet.pid
fi

mkdir -p log
if [ -f log/skynet.log ]; then
    mkdir -p log/skynetlog
    cp log/skynet.log log/skynetlog/skynet`date +"%Y-%m-%d-%H-%M-%S"`.log
fi

ulimit -c unlimited
#ulimit -n 1024000
cd $SKYNET_ROOT
chmod +x skynet
./skynet src/config/$config >/dev/null &
sleep 1
tail -20 log/skynet.log