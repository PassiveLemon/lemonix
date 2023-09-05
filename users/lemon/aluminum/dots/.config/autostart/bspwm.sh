#!/usr/bin/env bash

# Killalls.
killall -q polybar

# Bspwm
bspc monitor xxxxxx -d 1 2 3 4 5

# Display
xrandr --output xxxxxx --primary --mode 1920x1080 --rate xxxxx --rotate normal
xrandr --output xxxxxx --gamma 1.0:0.92:0.92

# Programs
while pgrep -u $UID -x polybar > /dev/null; do
  sleep 1
done

polybar xxx &

pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
