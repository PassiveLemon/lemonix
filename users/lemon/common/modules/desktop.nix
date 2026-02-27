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

