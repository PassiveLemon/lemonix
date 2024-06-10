#!/usr/bin/env bash

set -e

echo "|| Starting AutoADB... ||"
autoadb sh -c "adb forward tcp:9944 tcp:9944 ; adb forward tcp:9943 tcp:9943" &
AUTOADBPID=$!
echo "|| Starting ALVR... ||"
alvr_dashboard
echo "|| ALVR stopped. Stopping AutoADB... ||"
kill $AUTOADBPID
echo "|| AutoADB stopped. ||"
