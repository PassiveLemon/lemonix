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
    # Current issues with AWM config on SomeWM:
    # Lockscreen does not work at all, unsure if the call to lua-pam works, but it also does not go away when unlock() is called. Will need to test if it's the signals causing problems or wayland not liking the idea of a popup for a lockscreen
    # Generally noticable delay when switching tags
    # # Not sure how much of that is an issue with SomeWM vs Nvidia + a user with zero Wayland experience
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

