#!/bin/bash

SERVERS=( tx-websvc01 tx-websvc02 tx-websvc03 tx-websvc04 tx-websvc05 )

for SERVER in "${SERVERS[@]}"
do
	echo $SERVER
	ssh $SERVER ps -ef | grep java | sed -e 's/ \+/\n/g' | grep catalina\.home
	echo
done
