{ config, pkgs, ... }:

{
  programs.steam.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin thunar-volman
  ];
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lemon.enableGnomeKeyring = true;
}