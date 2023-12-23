{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
    ../../../modules/gaming.nix
    ../../../modules/picom.nix
  ];

  home = {
    packages = with pkgs; [
      headsetcontrol

      # Testing
      freecad openscad solvespace prusa-slicer cura meshlab
      rsync syncthing

      # Development
      jq
      dotnet-sdk

      # Custom
      (callPackage ../../../pkgs/corrupter { })
      (callPackage ../../../pkgs/xclicker { })
      (callPackage ../../../pkgs/tilp2 { gfm = callPackage ../../../pkgs/gfm { }; })
      (python3Packages.callPackage ../../../pkgs/pulsemeeter { })
      (python3Packages.callPackage ../../../pkgs/poepyautopot { })
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
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";
      };
    };
    desktopEntries = {
      "sd-comfyui" = {
        name = "sd-comfyui";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/ComfyUI.sh";
        terminal = true;
      };
      "sd-auto" = {
        name = "sd-auto";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/Auto.sh";
        terminal = true;
      };
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    permittedInsecurePackages = [
      "electron-24.8.6" # Feishin
      "electron-25.9.0"
    ];
  };
}

