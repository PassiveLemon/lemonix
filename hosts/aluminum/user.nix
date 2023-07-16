{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../modules/xorg.nix
  ];

  # Overlay
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  environment.systemPackages = with pkgs; [
    lite-xl rofi hilbish vscodium github-desktop
    haruna feh gimp obs-studio authy xarchiver filezilla easytag easyeffects soundux openshot-qt qbittorrent
    pamixer playerctl appimage-run neofetch ventoy-bin
    libsForQt5.kruler
    i3lock-fancy-rapid
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      #videoDrivers = [ "intel" ];
      displayManager = {
        startx.enable = true;
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
}
