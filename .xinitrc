#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all of X sessions started by xinit (startx)

# invoke global X session script
. /etc/X11/Xsession
xsetroot -cursor_name left_ptr &
xrdb -merge ~/.Xresources &
sxhkd &
exec bspwm
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
xrandr --addmode Virtual1 "1920x1080_60.00"
xrandr --output Virtual1 --mode "1920x1080_60.00"
