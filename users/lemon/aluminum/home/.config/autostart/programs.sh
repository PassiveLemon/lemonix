#!/bin/sh

pgrep -x fusuma > /dev/null || fusuma -d &
pgrep -x picom > /dev/null || picom --realtime -b &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x blueman-applet > /dev/null || blueman-applet &

