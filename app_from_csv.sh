#!/bin/bash

if [ -z $1 ]; then echo "No file defined" && exit; fi
FILENAME=$1
HOST=${FILENAME%.csv}

# pull application names from 3rd column and stuff into array
APPS=(`cut -d "," -f 3 $FILENAME | sed -e "s/-PROD-$HOST-[0-9]//" | sed -e "s/-$HOST-[0-9]//" | sort | uniq`)

# output files for each app's memory and cpu utilization
for APP in "${APPS[@]}"
do
	grep $APP $FILENAME | cut -d "," -f 1,4 > "$HOST-$APP-memory.csv"
	grep $APP $FILENAME | cut -d "," -f 1,5 > "$HOST-$APP-cpu.csv"
done

TIMES=(`cut -d "," -f 1 $FILENAME | sort | uniq`)

for TIME in "${TIMES[@]}"
do
	MEMLINE=$TIME
	CPULINE=$TIME
	for APP in "${APPS[@]}"
	do
		MEM=`grep $APP $FILENAME | grep $APP | cut -d "," -f 4`

