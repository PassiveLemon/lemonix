#!/usr/bin/env bash

set -e

echo "|| Starting AutoADB... ||"
autoadb sh -c "adb forward tcp:9944 tcp:9944 ; adb forward tcp:9943 tcp:9943" &
echo "|| Starting ALVR... ||"
alvr
echo "|| ALVR stopped. Stopping AutoADB... ||"
kill $(pgrep autoadb)
echo "|| AutoADB stopped. ||"
