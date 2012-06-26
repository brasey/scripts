#!/bin/bash

SERVERS=( tx-app01 tx-app02 tx-app03 tx-app05 tx-app06 tx-app07 tx-app08 tx-app09 tx-app10 tx-app13 tx-app14 tx-app21 tx-app22 tx-intprod01 tx-intprod02 tx-intprod03 tx-intprod04 tx-websvc01 tx-websvc02 tx-websvc03 tx-websvc04 tx-websvc05 )
#SERVER=( tx-app01 )

for SERVER in "${SERVERS[@]}"
do
	echo $SERVER
	ssh $SERVER ps -eo cmd | grep java
	echo
done
