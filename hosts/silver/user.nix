{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

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
      lowLatency = { # Module of Nix-gaming
        enable = true;
        quantum = 128;
        rate = 48000;
      };
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    udev.extraRules = ''
      ACTION!="add|change", GOTO="headset_end"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a51", TAG+="uaccess"
      LABEL="headset_end"
    ''; # Headsetcontrol udev rule
    mullvad-vpn.enable = true;
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
  };
  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
  };
}
