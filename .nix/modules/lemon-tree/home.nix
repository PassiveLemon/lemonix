{ config, pkgs, ... }: {
  imports = [
    #../home-manager
    ../home-manager/spicetify
  ];

  # Home Manager
  home.username = "lemon";
    home.homeDirectory = "/home/lemon";
    home.stateVersion = "22.11";
    programs.home-manager.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    # Desktop
    xorg.xrandr libsecret gnome.seahorse gnome.gnome-keyring
    lightdm bspwm sxhkd picom feh polybar dunst
    kora-icon-theme nordic

    # Apps & Programs
    kitty rofi firefox gparted pavucontrol
    gimp obs-studio spotify github-desktop discord steam heroic vscode jellyfin-media-player vlc qbittorrent megasync
    wine winetricks lxappearance htop neofetch 
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    material-design-icons fira (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" ]; })
  ];

  # Configs
  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  programs.spicetify = {
    enable = true;
    #theme = spicePkgs.themes.catppuccin-mocha;
    #colorScheme = "flamingo";
  };

  #home-manager.users.lemon = {
  #  home.packages = [
  #  ];
  #};
}