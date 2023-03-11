{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Desktop functionality
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol feh rofi
    lxappearance matcha-gtk-theme kora-icon-theme
  ];
}