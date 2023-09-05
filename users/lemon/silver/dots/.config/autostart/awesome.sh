#!/usr/bin/env bash

# Display
xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0
xrandr --output DP-0 --gamma 1.0:0.92:0.92 --output DP-2 --gamma 1.0:0.92:0.92

# Hardware
headsetcontrol -l 0
headsetcontrol -s 100

# Programs
picom --experimental-backend -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x megasync > /dev/null || megasync &

# Other
mkdir -p /tmp/mediamenu
