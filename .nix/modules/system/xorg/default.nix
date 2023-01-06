{ config, pkgs, ... }:

{
  # Config
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce+bspwm";
        gdm.enable = true;
        };
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
#      videoDrivers = [ "nvidia" ];
    };
    picom.enable = true;
    autorandr = {
      enable = true;
      profiles = {
        "Lemon" = {
          fingerprint.DP1 = "<EDID>";
          config.DP1 = {
            enable = true;
            primary = true;
            mode = "1920x1080";
            rate = "144.00";
          };
        };
        "Lime" = {
          fingerprint.DP2 = "<EDID>";
          config.DP2 = {
            enable = false;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };
  };
}