#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all of X sessions started by xinit (startx)

# invoke global X session script
. /etc/X11/Xsession
sxhkd &
exec bspwm
