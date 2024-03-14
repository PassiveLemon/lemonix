{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
    ../../../modules/home-manager/3d-printing.nix
    ../../../modules/home-manager/gaming.nix
    ../../../modules/home-manager/picom.nix
  ];

  home = {
    packages = with pkgs; [
      headsetcontrol
      easytag #onthespot
      xclicker

      # Development
      act nvfetcher nixpkgs-review jq dotnet-sdk_8

      # Custom
      inputs.lemonake.packages.${pkgs.system}.animdl
      inputs.lemonake.packages.${pkgs.system}.hd2pystratmacro
      inputs.lemonake.packages.${pkgs.system}.poepyautopot
      inputs.lemonake.packages.${pkgs.system}.tilp2

      #(callPackage ../../../pkgs/gdlauncher-carbon-src { })
    ];
    file = {
      ".config/autostart/" = {
        source = ./dots/.config/autostart;
        recursive = true;
      };
      ".config/awesome/config" = {
        source = ./dots/.config/awesome/config;
        recursive = true;
      };
      ".config/awesome/signal" = {
        source = ./dots/.config/awesome/signal;
        recursive = true;
      };
      ".config/awesome/ui" = {
        source = ./dots/.config/awesome/ui;
        recursive = true;
      };
      ".local/bin/passivelemon" = {
        source = ./dots/.local/bin/passivelemon;
        recursive = true;
      };
    };
    stateVersion = "23.05";
  };
  services = {
    megasync.enable = true;
  };
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";
      };
    };
    desktopEntries = {
      "alvr-autoadb" = {
        name = "alvr-autoadb";
        exec = "/home/lemon/.local/bin/passivelemon/alvr-autoadb.sh";
        terminal = false;
      };
      "sd-comfy" = {
        name = "sd-comfy";
        exec = "/home/lemon/.local/bin/passivelemon/sd-comfy.sh";
        terminal = true;
      };
      "sd-auto" = {
        name = "sd-auto";
        exec = "/home/lemon/.local/bin/passivelemon/sd-auto.sh";
        terminal = true;
      };
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6" # Feishin
    "electron-25.9.0"
    "freeimage-unstable-2021-11-01"
  ];
}

