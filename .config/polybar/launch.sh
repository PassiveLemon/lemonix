#!/usr/bin/env bash

# Add this script to your wm startup file.

#DIR="$HOME/.config/polybar"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
polybar lemon-right &
polybar lemon-left &

#2ndmoni=$(xrandr --query | grep 'DP-0')
#if [[ $2ndmoni = *connected* ]]; then
#    polybar lemon-left &
#fi

#polybar lemon 2>&1 | tee -a /tmp/polybar.log &

echo "Polybar launched..."
