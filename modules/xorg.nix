{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Desktop functionality
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol networkmanagerapplet
    lxappearance matcha-gtk-theme kora-icon-theme
  ];
}