{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    /home/lemon/.nix/modules
#    /home/lemon/.nix/pkgs
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}