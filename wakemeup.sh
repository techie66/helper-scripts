#!/bin/bash
i=0
TIME=1800
STEPS=64
SLEEP_TIME=$[$TIME/$STEPS]

amixer -q set Master 0
cmus-remote -p
while [ $i -lt $STEPS ]; do
	amixer -q set Master 1+
	let i=i+1
	sleep $SLEEP_TIME
done
sleep 3600
cmus-remote -s
