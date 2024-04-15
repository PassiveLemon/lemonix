#!/bin/sh

# Hardware
headsetcontrol -l 0 -s 110

# Other
mkdir -p $HOME/.cache/passivelemon/lemonix/media/

# Programs
pgrep -x picom > /dev/null || picom -b &
pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
pgrep -x nm-applet > /dev/null || nm-applet &
pgrep -x megasync > /dev/null || megasync &
