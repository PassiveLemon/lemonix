{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
    ../../../modules/home-manager/gaming.nix
    ../../../modules/home-manager/picom.nix
  ];

  home = {
    packages = with pkgs; [
      headsetcontrol
      freecad prusa-slicer openscad

      # Testing
      rsync syncthing

      # Development
      jq jdk21
      dotnet-sdk

      # Custom
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
        "text/x-gcode" = "userapp-prusa-slicer-GEUUG2.desktop";
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

