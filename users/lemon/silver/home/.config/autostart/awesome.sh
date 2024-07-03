#!/bin/sh

# Hardware
headsetcontrol -l 0 -s 110

# Programs
pgrep -x picom > /dev/null || picom -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &

