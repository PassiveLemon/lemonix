{ inputs, system, pkgs, ... }: {
  imports = [
    inputs.lemonake.homeModules.somewm
  ];

  home.packages = with pkgs; [
    wlr-randr xhost
    resources baobab
    gparted qdiskinfo
    ffmpegthumbnailer # https://github.com/NixOS/nixpkgs/pull/509742
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

  programs = {
    tofi = {
      enable = true;
      settings = {
        drun-launch = true;
        font = "monospace";
        font-size = 12;
        height = 500;
        width = 350;
        result-spacing = 4;
        prompt-text = ">";
        text-color = "#aaaaaa";
        background-color = "#222222";
        selection-color = "#dcdcdc";
        selection-background = "#363636";
        selection-background-padding = "2, 8, 2, 8";
        selection-background-corner-radius = 12;
        default-result-color = "#aaaaaa";
        default-result-background = "#292929";
        default-result-background-padding = "2, 8, 2, 8";
        default-result-background-corner-radius = 12;
        border-width = 3;
        border-color = "#40454f";
        outline-width = 0;
        padding-left = 8;
        padding-top = 8;
        corner-radius = 12;
      };
    };
  };

  services = {
    trayscale.enable = true;
    network-manager-applet.enable = true;
  };
}

