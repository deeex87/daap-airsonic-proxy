#!/bin/bash

ITUNES_TOUCH_FILE="/tmp/itunes-dns-sd.txt"
ITUNES_STRINGS="txtvers=1 iTSh73 Version=196610"

if [ -f $HOME/.daap-airsonic-proxy.conf ]; then
	source $HOME/.daap-airsonic-proxy.conf
else
	#SSH_USER=PUT SSH USER HERE
	#SSH_HOST=PUT SSH PASSWORD HERE
	#SSH_PORT=PUT SSH PORT HERE

	#ITUNES_LOCAL_DAAP_PORT=3690
	#ITUNES_REMOTE_DAAP_PORT=3689
	#ITUNES_SERVER_NAME="PUT SERVER NAME HERE"
fi

function start() { 
	test -f $ITUNES_TOUCH_FILE && kill -9 $(cat $ITUNES_TOUCH_FILE) && echo "Killed old dsn-sd iTunes"
	dns-sd -P "$ITUNES_SERVER_NAME" _daap._tcp local "$ITUNES_LOCAL_DAAP_PORT" localhost 127.0.0.1 "$ITUNES_STRINGS" 1>/dev/null &
	echo $! > $ITUNES_TOUCH_FILE

	echo "Starting ssh tunnel..."
	ssh -N $SSH_USER@$SSH_HOST -p $SSH_PORT -L $ITUNES_LOCAL_DAAP_PORT:localhost:$ITUNES_REMOTE_DAAP_PORT &
	echo $! >> "$ITUNES_TOUCH_FILE"
}

function stop() {

	test -f $ITUNES_TOUCH_FILE && cat $ITUNES_TOUCH_FILE | while read line; do
		kill -9 $line;
	done && rm -rf $ITUNES_TOUCH_FILE
	
}

$1
