{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    unstable.wineWowPackages.stable winetricks
    gamemode protonup-ng dxvk
    unstable.bottles
    unstable.lunar-client yuzu-early-access
  ];
  programs = {
    steam = {
      enable = true;
      package = pkgs.unstable.steam;
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