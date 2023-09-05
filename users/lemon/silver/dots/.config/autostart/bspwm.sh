#!/usr/bin/env bash

# Killalls. Kill Picom because it sometimes has bugs
killall -q polybar picom

# Bspwm
bspc monitor DP-2 -d 1 2 3
bspc monitor DP-0 -d 4 5 6

# Display
xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0
xrandr --output DP-0 --gamma 1.0:0.92:0.92 --output DP-2 --gamma 1.0:0.92:0.92

# Hardware
headsetcontrol -l 0 &
headsetcontrol -s 100 &

# Programs
picom --experimental-backend -b &

while pgrep -u $UID -x polybar > /dev/null; do
  sleep 1
done

polybar lemon-left &
polybar lemon-right &

pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x megasync > /dev/null || megasync &
