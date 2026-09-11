#!/bin/sh

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  export XDG_SESSION_TYPE=x11
  export XDG_SESSION_DESKTOP=awesome

  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --exit-with-session --sh-syntax)"
  fi

  systemctl --user import-environment DISPLAY XAUTHORITY

  if command -v dbus-update-activation-environment > /dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
  fi

  systemctl --user start nixos-fake-graphical-session.target

  autorandr -l Default
  install -m 600 /dev/null ~/.cache/awesome/loginauth
  exec awesome > ~/.cache/awesome/session-output.log 2>  ~/.cache/awesome/session-error.log
fi

