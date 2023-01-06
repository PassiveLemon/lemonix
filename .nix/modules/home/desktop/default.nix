{ config, pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    xorg.xrandr
    gnome.gdm
    bspwm sxhkd picom-jonaburg feh
    polybar dunst
    kitty rofi
#    pkgs.linuxKernel.packages.linux_zen.rtl8821ce
  ];
}