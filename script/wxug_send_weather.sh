#!/bin/bash

# Upload Protocol Guide at:
# http://wiki.wunderground.com/index.php/PWS_-_Upload_Protocol

source /etc/weather/config.cfg

PATH_TO_READ_SENSOR=$PATH_TO_READ_SENSOR
READ_INTERVAL=$READ_INTERVAL
WXUG_PASSWORD=$WXUG_PASSWORD
WXUG_ID=$WXUG_ID
WXUG_ACTION=$WXUG_ACTION
WXUG_DATEUTC=$WXUG_DATEUTC

CELSIUS=""
RH=""

for i in 1 2 3
do
	sleep $READ_INTERVAL
	TEMP_RH_SAMPLE=$($PATH_TO_READ_SENSOR)
	echo $TEMP_RH_SAMPLE

	if [[ -z $TEMP_RH_SAMPLE ]]; then
		continue
	fi

	IFS=" "
	TEMP_RH_ARR=($TEMP_RH_SAMPLE)

	CELSIUS_SAMPLE=${TEMP_RH_ARR[0]}
	echo $CELSIUS_SAMPLE
	
	RH_SAMPLE=${TEMP_RH_ARR[1]}
	echo $RH_SAMPLE
	
	# Validate RH
	if [[ ! $(echo "scale=3; $RH_SAMPLE <= 100" | bc) -eq 1 ]]; then
		continue
	fi

	# Store first read
	# For second and third reads, if lower than existing, use new reading
	if [[ -z $CELSIUS ]] || [[ $(echo "scale=3; $CELSIUS_SAMPLE <= $CELSIUS" | bc) -eq 1 ]]; then
		CELSIUS=$CELSIUS_SAMPLE
		RH=$RH_SAMPLE
	fi
done

# Exit if missing a reading
if [[ -z $CELSIUS ]]; then
	echo "No valid reading. Exiting."
	exit
fi

FAHRENHEIT=$(echo "scale=2;((9/5) * $CELSIUS) + 32" | bc)

# Calculate Dew Point F
DEWPTC=$(echo "243.04*(l($RH/100)+((17.625*$CELSIUS)/(243.04+$CELSIUS)))/(17.625-l($RH/100)-((17.625*$CELSIUS)/(243.04+$CELSIUS)))" | bc -l)
DEWPTF=$(echo "scale=2; ($DEWPTC*1.8/1)+32" | bc)	# Divide by 1 to round to scale

echo "$FAHRENHEIT  tempf"
echo "$RH% humidity"
echo "$DEWPTF  dew point"

# Get recent nearby reading
EPOCH_NOW=$(date -d '5 minutes ago' +%s)
#NEARBY_TEMP_F=$(echo "select temp_f from db.table WHERE timestamp_utc > $EPOCH_NOW ORDER BY timestamp_utc DESC LIMIT 1" | mysql -sN -u user -ppass)

# Check to see if sensor's reading confirms nearby readings
if [ ! -z $NEARBY_TEMP_F ]; then	# Not Undefined
	DIFFERENCE=$(echo "$NEARBY_TEMP_F - $FAHRENHEIT" | bc)
	DIFFERENCE_ABSOLUTE=${DIFFERENCE#-}
	# Within threshold of x degrees?
	TEMP_IS_ACCEPTABLE=$(echo "$DIFFERENCE_ABSOLUTE < 10" | bc)
	if [ $TEMP_IS_ACCEPTABLE -eq 0 ]; then
		exit # Possible anamoly reading - do nothing
	fi
fi

echo "Sending..."
REQUEST="http://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?action=updateraw&PASSWORD=$WXUG_PASSWORD&ID=$WXUG_ID&dateutc=$WXUG_DATEUTC&tempf=$FAHRENHEIT&humidity=$RH&dewptf=$DEWPTF"
echo $REQUEST
curl $REQUEST
