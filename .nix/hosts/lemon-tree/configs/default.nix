{ config, pkgs, ... }: {
  imports = [
    ./picom.nix
    ./dunst.nix
    ./sxhkd.nix
  ];
}