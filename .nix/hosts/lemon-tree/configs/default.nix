{ config, pkgs, ... }: {
  imports = [
    ./bspwm.nix
    ./desktop.nix
    ./dunst.nix
    ./gtk.nix
    ./kitty.nix
    ./picom.nix
    ./polybar
    ./sxhkd.nix
  ];
}