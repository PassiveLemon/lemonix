#!/bin/sh

pgrep -x picom > /dev/null || picom -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &

