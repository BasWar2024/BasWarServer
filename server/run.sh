#!/bin/sh

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

mkdir -p log
ulimit -c unlimited
chmod +x ./skynet
config=$servername.config
rlwrap -a ./skynet ./src/config/$config
