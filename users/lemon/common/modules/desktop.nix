{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      xss-lock
      networkmanagerapplet trayscale
      resources baobab
      gparted qdiskinfo
      ffmpegthumbnailer # https://github.com/NixOS/nixpkgs/pull/509742
    ];
  };

  wayland = {
    # windowManager.somewm = {
    #   enable = true;
    #   package = pkgs.lemonake.somewm-git;
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
      package = pkgs.lemonake.somewm-git.override {
        extraGITypeLibPaths = with pkgs.astal; [
          brightness wireplumber
        ];
        extraLuaModules = with pkgs.luajitPackages; [
          luafilesystem
        ];
        extraSearchPaths = [
          pkgs.lemonake.lua-pam-luajit-git
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
  xdg = {
    enable = true;
    configFile = {
      "awesome/liblua_pam.so" = {
        source = "${pkgs.lemonake.lua-pam-luajit-git}/lib/lua/5.1/liblua_pam.so";
      };
    };
  };
}

