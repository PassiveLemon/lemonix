#!/usr/bin/env bash

rofi_command="rofi -show drun -theme $HOME/.config/rofi/volumemenu.rasi"

i1="+1%"
mu="Mute"
d1="-1%"
25='25%'
50='50%'
75='75%'

options="$d1\n$25\n$mu\n$50\n$i1\n$75"

chosen="$(echo -e "$options" | $rofi_command -dmenu)"
case $chosen in
  $i1)
    pamixer -i 1
    ;; 
  $mu)
    pamixer -t
    ;;
  $d1)
    pamixer -d 1
    ;;
  $25)
    pamixer --set-volume 25
    ;;
  $50)
    pamixer --set-volume 50
    ;;
  $75)
    pamixer --set-volume 75
    ;;
esac