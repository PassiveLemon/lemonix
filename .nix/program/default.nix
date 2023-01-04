{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        gimp obs-studio github-desktop spotify discord steam vscode firefox gparted vlc
    ];
}