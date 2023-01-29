{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager.nix
    #../../modules/gdlauncher.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [ 
    # Desktop
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    lightdm bspwm sxhkd picom-jonaburg feh polybar
    kora-icon-theme

    # Apps & Programs
    kitty rofi firefox gparted pavucontrol appimage-run distrobox lutris spotify filezilla
    gimp obs-studio github-desktop discord steam vscode jellyfin-media-player vlc megasync
    wine winetricks lxappearance htop neofetch authy grapejuice
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    material-design-icons fira (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" ]; })
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce+bspwm";
        lightdm.enable = true;
        };
      desktopManager = {
        xfce = {
          enable = true;
          noDesktop = true;
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
      videoDrivers = [ "nvidia" ];
      libinput.mouse.middleEmulation = false;
      libinput.touchpad.middleEmulation = false;
    };
    gnome.gnome-keyring.enable = true;
  };
  programs = {
    dconf.enable = true;
    steam.enable = true;
    seahorse.enable = true;
  };
  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
  security.pam.services.lemon.enableGnomeKeyring = true;

  # Overlays
  nixpkgs.overlays =
  let
    myOverlay = self: super: {
      discord = super.discord.override { withOpenASAR = true; };
    };
  in
  [ myOverlay ];
}
