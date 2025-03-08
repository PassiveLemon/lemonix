{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      xss-lock gtk3 snixembed
      networkmanagerapplet
      tailscale-systray
    ];
  };

  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager = {
        startx.enable = true;
      };
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
        additionalOptions = ''
          Option "ScrollPixelDistance" "50"
        '';
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
      nssmdns4 = true;
      openFirewall = true;
    };
    gnome.gnome-keyring.enable = true;
  };

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
    nix-ld.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
      ];
    };
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = [ "gtk" ];
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };
  };
}

