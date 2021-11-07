#!/bin/bash

#
# Upstart monitoring script for oracle missed votes.
# Run with "setuid root" to be able to restart the feeder service
#
# E.g.
#   ./oracle-monitoring.sh terravaloper1rjmzlljxwu2q https://lcd.terra.dev
#

VALIDATOR=$1 # terravaloper address of your validator
LCD_HOST=$2 # url to lcd, ex "http://sentry-node:1317" (with quotes)
echo "Starting oracle-monitoring script..."

# Check every 60 seconds if the missing vote count increases. If more than 2 misses votes in 60 sec, restart the process
while (true); do
    missed_votes=$(curl -s $LCD_HOST/oracle/voters/$VALIDATOR/miss  | jq ".result" | sed s/\"//g)
    sleep 60

    last_missed_votes=$(curl -s $LCD_HOST/oracle/voters/$VALIDATOR/miss  | jq ".result" | sed s/\"//g)
    difference=$(expr $last_missed_votes - $missed_votes + 2)

    echo -n "$(date +'%Y-%m-%d %T'): "
    if [[ $difference -gt 2 ]]
    then
                echo 'Missed votes! -> ' $difference
                sudo systemctl restart feeder.service
                #su -c "restart terra-price-feeder"
                sleep 60 # wait for stabilisation
    else
                echo 'Oracle feeder ok'
    fi
done;