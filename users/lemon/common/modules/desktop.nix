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

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = pkgs.lemonake.awesome-luajit-git.override {
        # pkgs.astal exposed by flake overlay. It was removed from Nixpkgs
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

  programs.rofi = {
    enable = true;
    theme = ../home/.config/rofi/theme.rasi;
    settings = {
      modes = [ "drun" "ssh" ];
      show-icons = true;
      drun-display-format = "{name}";
      terminal = "tym";
      ssh-command = "{terminal} {ssh-client} {host} [-p {port}]";
      "drun,ssh" = {
        display-name = "> ";
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
}

