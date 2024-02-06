{ inputs, outputs, pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    xorg.xorgserver xorg.xinit xorg.xrandr xorg.xhost
    xorg.xf86videovesa xorg.xf86videofbdev xorg.xf86inputevdev xorg.xf86inputsynaptics xorg.xf86inputlibinput xorg.xf86videointel
    networkmanagerapplet
  ];

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
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    mullvad-vpn.enable = true;
    gnome.gnome-keyring.enable = true;
  };
  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
