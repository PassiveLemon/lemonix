{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../modules/xorg.nix
    ../../modules/gaming.nix
    ../../modules/customization.nix
  ];

  # Overlay
  nixpkgs.overlays = [ (final: prev: {
    awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
  } ) ];

  # Packages
  environment.systemPackages = with pkgs; [
    lite-xl rofi hilbish vscodium github-desktop firefox betterdiscordctl (discord.override { withOpenASAR = true; })
    haruna feh gimp obs-studio authy xarchiver filezilla easytag easyeffects qpwgraph openshot-qt qbittorrent
    pamixer playerctl appimage-run neofetch ventoy-bin
    libsForQt5.kruler
    i3lock-fancy-rapid
    wireplumber
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
      displayManager = {
        defaultSession = "none+awesome";
        startx.enable = true;
      };
      windowManager.awesome = {
        enable = true;
      };
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
      wireplumber.enable = true;
      jack.enable = true;
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
    nm-applet.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
  security = {
    pam.services.lemon.enableGnomeKeyring = true;
    rtkit.enable = true;
  };
  xdg = {
    portal.enable = true;
    mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
      };
    };
  };
}
