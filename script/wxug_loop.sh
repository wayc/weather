#!/bin/bash

PATH_TO_SEND_WEATHER=$(pwd)/wxug_send_weather.sh

while true
do
	bash $PATH_TO_SEND_WEATHER >> /dev/null 2>&1
	sleep 1
done
