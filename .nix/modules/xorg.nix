{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Desktop functionality
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol feh rofi networkmanagerapplet
    lxappearance matcha-gtk-theme kora-icon-theme unstable.volantes-cursors
  ];

  # Unstable
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