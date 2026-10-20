{ pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager.startx.enable = true;
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
    pipewire.enable = true;
    printing.enable = true;
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;
  };

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
    ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = [ "gtk" ];
    extraPortals = with pkgs; [
      gnome-keyring
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
}

