{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    /home/lemon/.nix
  ];
}