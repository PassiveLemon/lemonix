{ inputs, pkgs, ... }: {
  home = {
    packages = with pkgs; [
      xss-lock
      networkmanagerapplet trayscale
      resources baobab
      gparted qdiskinfo
      ffmpegthumbnailer # https://github.com/NixOS/nixpkgs/pull/509742
    ];
  };

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = pkgs.lemonake.awesome-luajit-git.override {
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
    picom = {
      enable = true;
      extraArgs = [ "--config ${../home/.config/picom/picom.conf}" ];
    };
    snixembed.enable = true;
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
      "awesome/libraries/bling" = {
        source = inputs.awesomewm-bling;
        recursive = true;
      };
      "awesome/liblua_pam.so" = {
        source = "${pkgs.lemonake.lua-pam-luajit-git}/lib/lua/5.1/liblua_pam.so";
      };
    };
  };
}

