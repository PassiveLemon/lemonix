{ config, pkgs, ... }: {
  imports = [
    ../../modules/home-manager.nix
    ../../modules/xorg.nix
    ../../modules/gaming.nix
  ];

  environment.systemPackages = with pkgs; [
    unstable.firefox (unstable.discord.override { withOpenASAR = true; })
    vlc gimp unstable.obs-studio authy htop neofetch
    unstable.jellyfin-media-player appimage-run filezilla easytag
    unstable.github-desktop qbittorrent unstable.qpwgraph ventoy-bin
    pamixer playerctl
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
      videoDrivers = [ "nvidia" ];
      displayManager = {
        defaultSession = "none+bspwm";
        #defaultSession = "none+awesome";
        lightdm = {
          enable = true;           
        };
      };
      windowManager.bspwm = {
        enable = true;
      };
      #windowManager.awesome = {
      #  enable = true;
      #  package = (builtins.getFlake "github:fortuneteller2k/nixpkgs-f2k").packages.x86_64-linux.awesome-git
      #  luaModules = with pkgs.luaPackages; [
      #    luarocks
      #  ];
      #};
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
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    printing.enable = true;
    avahi = {
      enable = true;
      openFirewall = true;
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
  security.rtkit.enable = true;
  xdg.portal.enable = true;

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    users.lemon = { config, pkgs, ... }: {
      imports = [
        ./config/desktop.nix
        ./config/polybar.nix
        ../../modules/bspwm.nix
        ../../modules/dunst.nix
        ../../modules/gtk.nix
        ../../modules/kitty.nix
        ../../modules/picom.nix
        ../../modules/spicetify.nix
        ../../modules/sxhkd.nix
        ../../modules/vscode.nix
      ];
      programs = {
        fish.enable = true;
        # Disabled until I actually set it up
        #eww = {
        #  enable = true;
        #  configDir = ../../modules/eww;
        #};
      };
      services = {
        easyeffects = {
          enable = true;
          package = pkgs.unstable.easyeffects;
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
      home = {
        sessionVariables = {
        EDITOR = "codium";
        BROWSER = "firefox";
        };
        stateVersion = "22.11";
        file = {
          ".config/awesome/rc.lua".source = ../../modules/awesome/rc.lua;
          ".config/awesome/default/theme.lua".source = ../../modules/awesome/default/theme.lua;
          ".config/htop/htoprc".source = ../../modules/htop/htoprc;
          ".config/neofetch/config.conf".source = ../../modules/neofetch/config.conf;
          ".config/rofi/lemon.rasi".source = ../../modules/rofi/lemon.rasi;
          ".config/rofi/powermenu.rasi".source = ../../modules/rofi/powermenu.rasi;
          ".config/rofi/powermenu.sh".source = ../../modules/rofi/powermenu.sh;
        };
      };
    };
  };


  # Unstable + Overlay
  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        unstable = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) {
          config = config.nixpkgs.config;
        };
      };
    };
  };
}
