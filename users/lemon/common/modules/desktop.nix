{ inputs, system, pkgs, ... }: {
  imports = [
    inputs.lemonake.homeModules.somewm
  ];

  wayland = {
    # windowManager.somewm = {
    #   enable = true;
    #   package = inputs.lemonake.packages.${system}.somewm-git;
    #   systemd.useService = true;
    #   extraGITypeLibPaths = with pkgs.astal; [
    #     brightness wireplumber
    #   ];
    #   extraLuaModules = with pkgs.luajitPackages; [
    #     luafilesystem
    #   ];
    # };
    windowManager.somewm = {
      enable = true;
      package = inputs.lemonake.packages.${system}.somewm-git.override {
        extraGITypeLibPaths = with pkgs.astal; [
          brightness wireplumber
        ];
        extraLuaModules = with pkgs.luajitPackages; [
          luafilesystem
        ];
      };
    };
  };

  services = {
    trayscale.enable = true;
    network-manager-applet.enable = true;
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
          showDesktopNotification = false;
          filenamePattern = "%Y-%m-%d_%H-%M-%S_%b-%d";
          saveAsFileExtension = "png";
          savePath = "/home/lemon/Pictures/Flameshot";
          captureActiveMonitor = true;
          useX11LegacyScreenshot = true;
        };
      };
    };
  };
}

