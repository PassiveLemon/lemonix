{ config, pkgs, ... }: {
  imports = [
    ./colors.nix
    ./modules.nix
  ];
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { alsaSupport = true; };
    script = ''
      polybar lemon-left &
      polybar lemon-right &
    '';
    config = {
      "bar/lemon-left" = {
        monitor = "DP-2";
        width = "100%";
        height = 26;
        fixed-center = true;
        wm-restack = "bspwm";
        override-redirect = false;
        enable-ipc = true;

        top = true;
        background = "\${colors.odBac}";
        foreground = "\${colors.odFor}";
        border-bottom-size = 0;

        font-0 = "FiraCode Nerd Font Mono Ret:style=Medium:size=10;2";
        font-1 = "FiraCode Nerd Font Mono Ret:style=Medium:size=12;1";
        font-2 = "FiraCode Nerd Font Mono Ret:style=Medium:size=12;2";
        font-3 = "FiraCode Nerd Font Mono Ret:style=Medium:size=10;5";

        modules-left = "sep nix sep bar sep cpu sep bar sep memory sep bar sep title sep";
        modules-center = "bspwm";
        modules-right = "sep date sep bar sep time sep bar sep volume sep bar";

        tray-position = "right";
      };
      "bar/lemon-right" = {
        monitor = "DP-0";
        width = "100%";
        height = 26;
        fixed-center = true;
        wm-restack = "bspwm";
        override-redirect = false;
        enable-ipc = true;

        top = true;
        background = "\${colors.odBac}";
        foreground = "\${colors.odFor}";
        border-bottom-size = 0;

        font-0 = "FiraCode Nerd Font Mono Ret:style=Medium:size=10;2";
        font-1 = "FiraCode Nerd Font Mono Ret:style=Medium:size=10;1";
        font-2 = "FiraCode Nerd Font Mono Ret:style=Medium:size=12;2";

        modules-left = "sep cpu sep bar sep memory sep bar sep title sep";
        modules-center = "bspwm";
        modules-right = "sep date sep bar sep time sep bar sep volume sep bar sep powermenu sep sep";
      };
    };
  };
}
