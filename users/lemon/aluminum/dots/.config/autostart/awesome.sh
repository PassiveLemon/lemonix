#!/bin/sh

# Display
xrandr --output xxxxxx --primary --mode 1920x1080 --rate xxxxxx --rotate normal
xrandr --output xxxxxx --gamma 1.0:0.92:0.92

# Programs
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x blueman-applet > /dev/null || blueman-applet &

# Other
mkdir -p /tmp/mediamenu
