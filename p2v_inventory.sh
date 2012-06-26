#!/bin/bash

SERVERS=( tx-websvc01 tx-websvc02 tx-websvc03 tx-websvc04 tx-websvc05 tx-chrome-prod01 tx-chrome-prod02 tx-chrome-prod03 tx-chrome-prod04 tx-chrome-prod05 ) 

for SERVER in "${SERVERS[@]}"
do
	echo ------------------
	echo      $SERVER
	echo ------------------
	echo
	ssh $SERVER cat /etc/SuSE-release
	echo
	ssh $SERVER SPident
	echo
	ssh $SERVER grep Total /proc/meminfo
	echo
	ssh $SERVER grep "model\ name" /proc/cpuinfo
	echo
	ssh $SERVER grep cores /proc/cpuinfo | uniq
	echo
	ssh $SERVER ip address show | grep 'inet ' | grep -v '127.0.0.'
	echo
	ssh $SERVER mount
	echo
	echo
done
