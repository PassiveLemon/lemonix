#!/usr/bin/env bash

rofi_command="rofi -show drun -theme $HOME/.config/rofi/playermenu.rasi"

pr="󰙣"
ne="󰙡"

pp="󰏥"
if [ "`playerctl status`" = "Paused" ]; then
  pp="󰐌"
fi

prompt="`playerctl metadata title`"

options="$pr\n$pp\n$ne"

chosen="$(echo -e "$options" | $rofi_command -dmenu -p "$prompt" )"
case $chosen in
  $pr)
    playerctl previous
    ;; 
  $pp)
    playerctl play-pause
    ;;
  $ne)
    playerctl next
    ;;
esac