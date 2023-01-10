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
    lxappearance gimp obs-studio spotify github-desktop discord steam heroic vscode jellyfin-media-player firefox gparted vlc pavucontrol qbittorrent htop neofetch megasync
    #nvtop-nvidia
  ];
}
