{ config, pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    xorg.xrandr
    lightdm
    bspwm sxhkd picom-jonaburg feh
    polybar dunst
    kitty rofi
  ];
}
