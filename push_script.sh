#!/bin/bash

SERVERS=( tx-app01 tx-app02 tx-app03 tx-app05 tx-app06 tx-app07 tx-app08 tx-app09 tx-app10 tx-app13 tx-app14 tx-app21 tx-app22 tx-chrome-prod01 tx-chrome-prod02 tx-chrome-prod03 tx-chrome-prod04 tx-chrome-prod05 tx-intprod01 tx-intprod02 tx-intprod03 tx-intprod04 tx-websvc01 tx-websvc02 tx-websvc03 tx-websvc04 tx-websvc05 tx-ucm01 tx-ucm02 tx-ucm03 tx-ucm04 tx-ucm05 tx-ucm06 )

for SERVER in "${SERVERS[@]}"
do
	scp /home/sarobot/brasey/p2v_metrics.pl $SERVER:bin/
done
