{ config, pkgs, ... }: {
  # Packages
  environment.systemPackages = with pkgs; [
    # Desktop
    xorg.xrandr libsecret gnome.seahorse gnome.gnome-keyring
    lightdm bspwm sxhkd picom feh polybar dunst
    kora-icon-theme nordic

    # Apps & Programs
    kitty rofi firefox gparted pavucontrol
    gimp obs-studio github-desktop discord steam heroic vscode jellyfin-media-player vlc qbittorrent megasync
    wine winetricks lxappearance htop neofetch
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
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
      excludePackages = [ pkgs.xterm pkgs.xfce.xfce4-terminal pkgs.xfce.xfwm4 pkgs.xfce.mousepad ];
      videoDrivers = [ "nvidia" ];
    };
    picom.enable = true;
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
  };

  programs = {
    dconf.enable = true;
    steam.enable = true;
    seahorse.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  security.pam.services.lemon.enableGnomeKeyring = true;
  hardware.opengl.enable = true;
}