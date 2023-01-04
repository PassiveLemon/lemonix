{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    /home/lemon/.nix/system/
    /home/lemon/.nix/utility/
    /home/lemon/.nix/program/
    /home/lemon/.nix/customization/
    /home/lemon/.nix/custom/
  ];

  nixpkgs.config.allowUnfree = true;


  system.stateVersion = "22.11";
}