#!/bin/sh

# Other
mkdir -p $HOME/.cache/lemonix/mediamenu/

# Display
sleep 0.5
xrandr --output eDP-1 --primary --mode 1920x1080 --rate 60.01 --rotate normal
xrandr --output eDP-1 --gamma 1.0:0.92:0.92

# Programs
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x blueman-applet > /dev/null || blueman-applet &
