{ inputs, system, pkgs, ... }: {
  imports = [
    inputs.lemonake.homeModules.somewm
  ];

  home = {
    file = {
      ".winitrc" = {
        source = ../home/.winitrc;
      };
      ".xinitrc" = {
        source = ../home/.xinitrc;
      };
    };
  };

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = inputs.lemonake.packages.${system}.awesome-luajit-git;
      luaModules = with pkgs; [
        luajitPackages.luafilesystem
      ];
    };
  };

  wayland = {
    windowManager.somewm = let
      somewm = (inputs.lemonake.packages.${system}.somewm-git.override {
        extraLuaModules = with pkgs.luajitPackages; [
          luafilesystem
        ];
        extraSearchPaths = [
          inputs.lemonake.packages.${system}.lua-pam-luajit-git
        ];
        extraGITypeLibPaths = with pkgs; [
          networkmanager upower playerctl
        ];
      });
    in {
      enable = true;
      package = somewm;
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
        source = "${inputs.lemonake.packages.${system}.lua-pam-luajit-git}/lib/lua/5.1/liblua_pam.so";
      };
    };
  };
}

