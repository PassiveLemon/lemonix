#!/usr/bin/env bash

rofi_command="rofi -show drun -theme $HOME/.config/rofi/powermenu.rasi"

lock="󰌾"
power_off="󰐥"
reboot="󰑓"

options="$lock\n$power_off\n$reboot"

chosen="$(echo -e "$options" | $rofi_command -dmenu)"
case $chosen in
  $lock)
    dm-tool switch-to-greeter
    ;; 
  $power_off)
    systemctl poweroff
    ;;
  $reboot)
    systemctl reboot
    ;;
esac