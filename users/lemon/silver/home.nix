{ inputs, system, lib, pkgs, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      # Audio
      easytag
      # Calculator
      cemu-ti
      inputs.lemonake.packages.${system}.tilp2-git
      # Miscellaneous
      xclicker zenity ente-auth filezilla
      inputs.lemonake.packages.${system}.nimpad
      inputs.lemonake.packages.${system}.awmtt-git
    ];
    stateVersion = "26.05"; # Don't change unless you know what you are doing
  };

  programs = {
    obs-studio.package = pkgs.obs-studio.override { cudaSupport = true; };
  };

  services = {
    easyeffects.enable = true;
  };

  systemd = {
    user.services.nimpad =  {
      Unit = {
        Description = "Nimpad";
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${lib.getExe inputs.lemonake.packages.${system}.nimpad} -p=/dev/serial/by-id/usb-Arduino_LLC_Arduino_Micro_HIDLD-if00";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  xdg = {
    desktopEntries."CEmu" = {
      name = "CEmu";
      exec = "${lib.getExe pkgs.cemu-ti}";
    };
    configFile = {
      "." = {
        source = ./home/.config;
        recursive = true;
      };
    };
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
      "libxml2-2.13.8" # Unityhub
    ];
  };
}

