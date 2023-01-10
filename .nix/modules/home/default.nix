{ config, pkgs, ... }:

{
  imports = [
#   ./configs
    ./customs
    ./desktop
    ./fonts
    ./programs
  ];

  environment.systemPackages = with pkgs; [
    xfce.thunar-archive-plugin xfce.thunar xfce.thunar-volman lxappearance archiver
    gimp obs-studio github-desktop spotify discord steam heroic vscode firefox gparted vlc pavucontrol protonvpn-gui qbittorrent htop neofetch megasync
    #nvtop-nvidia
  ];
}
