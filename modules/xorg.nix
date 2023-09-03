{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Xorg
    xorg.xorgserver
    xorg.xf86videovesa xorg.xf86videofbdev xorg.xf86inputevdev xorg.xf86inputsynaptics xorg.xf86inputlibinput
    xorg.xinit xorg.xrandr xorg.xhost

    # Base packages
    libsecret gnome.seahorse gnome.gnome-keyring scrot
    firefox pcmanfm gparted pavucontrol networkmanagerapplet
  ];
}
