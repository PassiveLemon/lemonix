#!/usr/bin/env bash

DEVICE='Glorious Model O'
enabled=$(xinput list-props "$DEVICE" | awk '/^\tDevice Enabled \([0-9]+\):\t[01]/ {print $NF}')
if [ $enabled == "1" ]; then
  xinput set-prop 'Glorious Model O' 'Device Enabled' 0 && sleep 2 && xset dpms force off
fi
if [ $enabled == "0" ]; then
  xinput set-prop 'Glorious Model O' 'Device Enabled' 1 && xset dpms force on
fi