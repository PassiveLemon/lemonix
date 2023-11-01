{ inputs, outputs, pkgs, config, lib, ... }: {
  # Packages
  environment.systemPackages = with pkgs; [
    xorg.xorgserver xorg.xinit xorg.xrandr xorg.xhost
    xorg.xf86videovesa xorg.xf86videofbdev xorg.xf86inputevdev xorg.xf86inputsynaptics xorg.xf86inputlibinput xorg.xf86videointel
    networkmanagerapplet blueman
  ];

  # Configs
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
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
          buttonMapping = "1 1 3 4 5 6 7";
          middleEmulation = false;
          accelProfile = "flat";
          naturalScrolling = true;
        };
      };
    };
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=60m
    '';
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
    mullvad-vpn.enable = true;
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
