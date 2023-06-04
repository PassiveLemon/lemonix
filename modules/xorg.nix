{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Desktop functionality
    xorg.xf86videovesa xorg.xf86videofbdev
    xorg.xinit xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol networkmanagerapplet
    lxappearance kora-icon-theme
  ];
}