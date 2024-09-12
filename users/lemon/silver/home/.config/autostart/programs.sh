#!/bin/sh

pgrep -x picom > /dev/null || picom --realtime -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &

