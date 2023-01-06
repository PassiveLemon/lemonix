{ config, pkgs, ... }:

{
  imports = [
#   ./configs
    ./customs
    ./desktop
    ./fonts
  ];

  environment.systemPackages = with pkgs; [
    gimp obs-studio github-desktop spotify discord steam vscode firefox gparted vlc lxappearance pavucontrol protonvpn-gui megasync htop neofetch
  ];
}