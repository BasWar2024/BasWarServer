#!/bin/sh

rm -rf report.txt
cd 3rd/skynet
mkdir -p ../../log
ulimit -c unlimited
#ulimit -n 1024000
chmod +x skynet
./skynet ../../app/config/robot.config &
