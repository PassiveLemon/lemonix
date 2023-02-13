{ config, pkgs, ... }: {
  imports = [
    ./bspwm.nix
    ./dunst.nix
    ./gtk.nix
    ./kitty.nix
    ./picom.nix
    ./polybar
    ./sxhkd.nix
  ];
}