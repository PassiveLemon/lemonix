{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Xorg
    xorg.xf86videovesa xorg.xf86videofbdev
    xorg.xinit xorg.xrandr xorg.xhost

    # Base packages
    libsecret gnome.seahorse gnome.gnome-keyring
    firefox pcmanfm gparted pavucontrol networkmanagerapplet
  ];
}