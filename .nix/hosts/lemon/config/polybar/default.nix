{ config, pkgs, ... }: {
  imports = [
    ./colors.nix
    ./modules.nix
  ];
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { alsaSupport = true; };
    script = ''
      polybar lemon-right &
      polybar lemon-left &
    '';
    config = {
      "bar/lemon-left" = {
        monitor = "DP-2";
        width = "100%";
        height = 25;
        fixed-center = true;
        wm-restack = "bspwm";
        override-redirect = false;
        enable-ipc = true;

        top = true;
        background = "\${colors.odBac}";
        foreground = "\${colors.odFor}";
        border-bottom-size = 2;
        border-bottom-color = "\${colors.dWhi}";

        font-0 = "Fira Code Nerd Font:style=Medium:size=10;2";
        font-1 = "Fira Code Nerd Font:style=Medium:size=10;1";
        font-2 = "Fira Code Nerd Font:style=Medium:size=12;2";

        modules-left = "sep nix sep bar sep cpu sep bar sep memory sep bar sep title sep";
        modules-center = "bspwm";
        modules-right = "sep date sep bar sep time sep bar sep volume sep bar";

        tray-position = "right";
      };
      "bar/lemon-right" = {
        monitor = "DP-0";
        width = "100%";
        height = 25;
        fixed-center = true;
        wm-restack = "bspwm";
        override-redirect = false;
        enable-ipc = true;

        top = true;
        background = "\${colors.odBac}";
        foreground = "\${colors.odFor}";
        border-bottom-size = 2;
        border-bottom-color = "\${colors.dWhi}";

        font-0 = "Fira Code Nerd Font:style=Medium:size=10;2";
        font-1 = "Fira Code Nerd Font:style=Medium:size=10;1";
        font-2 = "Fira Code Nerd Font:style=Medium:size=12;2";

        modules-left = "sep cpu sep bar sep memory sep bar sep title sep";
        modules-center = "bspwm";
        modules-right = "sep date sep bar sep time sep bar sep volume sep bar sep powermenu sep";
      };
    };
  };
}