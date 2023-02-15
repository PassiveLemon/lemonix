{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [ 
    # Desktop functionality
    xorg.xrandr xorg.xhost libsecret gnome.seahorse gnome.gnome-keyring
    pcmanfm gparted pavucontrol feh rofi lxappearance
    matcha-gtk-theme kora-icon-theme

    # Apps and programs
    gamemode protonup-ng dxvk lutris grapejuice
    firefox jellyfin-media-player vlc discord
    appimage-run distrobox filezilla r2mod_cli
    gimp obs-studio github-desktop
    wine winetricks htop neofetch authy qpwgraph ventoy-bin
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
        lightdm = {
          enable = true;           
        };
      };
      windowManager.bspwm = {
        enable = true;
      };
      videoDrivers = [ "nvidia" ];
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
    steam.enable = true;
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
        vscode = {
          enable = true;
          package = pkgs.vscodium;
          enableUpdateCheck = false;
          userSettings = {
            "workbench.colorTheme" = "One Dark Pro";
            "workbench.iconTheme" = "material-icon-theme";
            "glassit.alpha" = 80;
            "editor.minimap.enabled" = false;
            "editor.tabSize" = 2;
            "workbench.welcomePage.extraAnnouncements" = false;
            "workbench.startupEditor" = "none";
            "security.workspace.trust.untrustedFiles" = "open";
            "editor.bracketPairColorization.enabled" = false;
          };
        };
        # Disabled until I actually set it up
        #eww = {
        #  enable = true;
        #  configDir = ../../../.config/eww;
        #};
      };
      services = {
        easyeffects = {
          enable = true;
          preset = "Lemon";
        };
        flameshot = {
          enable = true;
          settings = {
            General = {
              disabledTrayIcon = true;
            };
          };
        };
        megasync.enable = true;
      };
      home.stateVersion = "22.11";
    };
  };

  # Overlays
  nixpkgs.overlays =
  let
    myOverlay = self: super: {
      discord = super.discord.override { withOpenASAR = true; };
    };
  in
  [ myOverlay ];
}
