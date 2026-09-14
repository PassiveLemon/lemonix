#!/bin/sh

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  install -m 600 /dev/null ~/.cache/passivelemon/loginauth
  exec startx > /dev/null 2>&1
fi

