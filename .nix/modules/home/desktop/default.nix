{ config, pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    bspwm sxhkd picom-jonaburg feh
    polybar dunst
    kitty rofi
  ];
}
