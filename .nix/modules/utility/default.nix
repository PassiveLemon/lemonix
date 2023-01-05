{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        lxappearance pavucontrol docker protonvpn-gui p7zip megasync psmisc wget unzip git curl htop neofetch feh rofi networkmanager
    ];
}