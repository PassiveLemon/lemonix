{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../modules/xorg.nix
    ../../modules/gaming.nix
  ];

  # Overlay
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    i3lock-fancy-rapid
    tym lite-xl rofi hilbish vscodium github-desktop
    haruna feh gimp obs-studio authy xarchiver filezilla easytag easyeffects soundux openshot-qt qbittorrent
    pamixer playerctl appimage-run neofetch ventoy-bin
    libsForQt5.kruler

    jq stdenvNoCC gnumake gnat13 husky nodejs_16 python2 rustup (python311.withPackages(ps: with ps; [ pillow-simd evdev pyyaml pynput]))
    #(callPackage ../../pkgs/gdlauncher { })
    go
    dotnet-sdk dotnet-runtime
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
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
    blueman.enable = true;
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
