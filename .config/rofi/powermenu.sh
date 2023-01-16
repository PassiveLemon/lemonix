#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/powermenu.rasi -p "power""

#### Options ###
lock=" Lock"
log_out="﫼 Logout"
power_off="襤 Power off"
reboot="勒 Reboot"
# Variable passed to rofi
options="$lock\n$log_out\n$power_off\n$reboot"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 1)"
case $chosen in
  $lock)
    xflock4
    ;; 
  $log_out)
    xfce4-session-logout --logout
    ;;   
  $power_off)
    systemctl poweroff
    ;;
  $reboot)
    systemctl reboot
    ;;
esac