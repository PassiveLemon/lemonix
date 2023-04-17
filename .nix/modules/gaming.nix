{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gamemode protonup-ng dxvk
    bottles
    unstable.lunar-client
    yuzu-mainline
  ];
  programs = {
    steam = {
      enable = true;
    };
  };
  #services.archisteamfarm = {
  #  enable = true;
  #  web-ui.enable = true;
  #};
  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        unstable = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) {
          config = config.nixpkgs.config;
        };
      };
    };
  };
}