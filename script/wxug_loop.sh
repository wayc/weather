#!/bin/bash

PATH_TO_SEND_WEATHER=$(pwd)/wxug_send_weather.sh
VERBOSE=0

case "$1" in
-v|--v|--ve|--ver|--verb|--verbo|--verbos|--verbose)
    VERBOSE=1
    shift ;;
esac

while true
do
	if [ "$verbose" = 1 ]; then
		bash $PATH_TO_SEND_WEATHER
	else
		bash $PATH_TO_SEND_WEATHER >> /dev/null 2>&1
	fi
	sleep 1
done
