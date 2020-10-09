#!/bin/bash

if [ -z $0 ]
then
  DIRNAME="."
else
  DIRNAME=$(dirname $0})
fi


while :
do
        echo "Getting memcached stats..."
        STATS=$($DIRNAME/telnet.sh | telnet | grep "STAT ")
        while read -r STAT; do
            STAT_ID=$(echo $STAT | cut -d ' ' -f2)
            STAT_VALUE=$(echo $STAT | cut -d ' ' -f3)
            CMD="echo $MONITORING_PREFIX.$STAT_ID:$STAT_VALUE|c | ncat -w 50ms -u $MONITORING_GRAPHITE_HOST 8125"
            echo "$STAT_ID      $STAT_VALUE     $CMD"
            echo "$MONITORING_PREFIX.$STAT_ID:$STAT_VALUE|c" | nc -w 50ms -u $MONITORING_GRAPHITE_HOST 8125
        done <<< $STATS
        echo
        echo
        echo "Waiting for $MONITORING_SLEEP seconds..."
        sleep $MONITORING_SLEEP
done
