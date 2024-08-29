#!/bin/sh 

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	eval "$(dbus-launch --exit-with-session --sh-syntax)"
fi

systemctl --user import-environment DISPLAY XAUTHORITY

if command -v dbus-update-activation-environment > /dev/null 2>&1; then
  dbus-update-activation-environment DISPLAY XAUTHORITY
fi

systemctl --user start nixos-fake-graphical-session.target

awesome

systemctl --user stop nixos-fake-graphical-session.target

# If AWM crashes or is killed, we kill the user to prevent unauthorized access.
pkill -KILL -u lemon

