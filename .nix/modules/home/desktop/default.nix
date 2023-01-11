{ config, pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    xorg.xrandr libsecret gnome.seahorse gnome.gnome-keyring
    lightdm
    bspwm sxhkd picom feh
    polybar dunst
    kitty rofi
  ];
}
