#!/bin/sh

# Killall
killall -q picom

# Hardware
headsetcontrol -l 0
headsetcontrol -s 110

# Other
mkdir -p $HOME/.cache/lemonix/mediamenu/

# Display
sleep 0.5
xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.85 --output DP-2 --mode 1920x1080 --rate 143.85
xrandr --output DP-0 --gamma 1.0:0.92:0.92 --output DP-2 --gamma 1.0:0.92:0.92

# Programs
picom -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x megasync > /dev/null || megasync &
