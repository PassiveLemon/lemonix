{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [ 
    # Desktop functionality
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol feh polybar rofi lxappearance
    matcha-gtk-theme kora-icon-theme

    # Apps and programs
    firefox jellyfin-media-player vlc armcord
    appimage-run gimp flameshot vscodium megasync
    htop neofetch authy easyeffects qpwgraph
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    material-design-icons fira (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager = {
        defaultSession = "none+bspwm";
        lightdm.enable = true;
      };
      windowManager.bspwm = {
        enable = true;
      };
      videoDrivers = [ "intel" ];
      libinput = {
        enable = true;
        mouse = {
          middleEmulation = false;
          accelProfile = "flat";
          accelSpeed = "-0.5";
        };
        touchpad = {
          middleEmulation = false;
          accelProfile = "flat";
          accelSpeed = "-0.5";
        };
      };
    };
    gnome.gnome-keyring.enable = true;
  };
  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };
  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
  security.pam.services.lemon.enableGnomeKeyring = true;

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    users.lemon = { config, pkgs, ... }: {
      imports = [
        ./config
        ../../modules/spicetify.nix
      ];
      programs = {
        bash.enable = true;
        #eww = {
        #  enable = true;
        #  configDir = ../../../.config/eww;
        #};
      };
      home.stateVersion = "22.11";
    };
  };
}