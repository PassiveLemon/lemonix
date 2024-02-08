{ inputs, outputs, pkgs, config, lib, ... }: {
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
      easytag #soundux #onthespot

      # Testing
      rsync syncthing

      # Development
      act nvfetcher nixpkgs-review jq dotnet-sdk_8

      # Custom
      inputs.lemonake.packages.${pkgs.system}.animdl
      inputs.lemonake.packages.${pkgs.system}.poepyautopot
      inputs.lemonake.packages.${pkgs.system}.tilp2
      inputs.lemonake.packages.${pkgs.system}.xclicker

      (callPackage ../../../pkgs/envision { })
      #(callPackage ../../../pkgs/adbforwarder { })
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
        exec = "/home/lemon/Documents/GitHub/private/Scripts/alvr-autoadb.sh";
        terminal = false;
      };
      "sd-comfy" = {
        name = "sd-comfy";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/sd-comfy.sh";
        terminal = true;
      };
      "sd-auto" = {
        name = "sd-auto";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/sd-auto.sh";
        terminal = true;
      };
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6" # Feishin
    "electron-25.9.0"
  ];
}

