{ config, pkgs, ... }:

{
  # Config
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce+bspwm";
        lightdm.enable = true;
        };
      desktopManager = {
        xfce = {
          enable = true;
          noDesktop = true;
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
      excludePackages = [ pkgs.xterm pkgs.xfce.xfce4-terminal pkgs.xfce.xfwm4 pkgs.xfce.mousepad ];
      videoDrivers = [ "nvidia" ];
    };
    picom.enable = true;
    gnome.gnome-keyring.enable = true;
  };
}
