{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    unstable.wineWowPackages.stable winetricks
    gamemode protonup-ng dxvk
    unstable.bottles lutris
    unstable.lunar-client
  ];
  programs = {
    steam = {
      enable = true;
      package = pkgs.unstable.steam;
    };
  };
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