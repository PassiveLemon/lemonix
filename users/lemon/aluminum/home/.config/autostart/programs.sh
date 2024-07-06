#!/bin/sh

#pgrep -x picom > /dev/null || picom -b &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x blueman-applet > /dev/null || blueman-applet &
