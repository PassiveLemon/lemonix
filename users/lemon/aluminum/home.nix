{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      brightnessctl
      cloudflare-warp
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

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
    };
  };
  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
        };
      };
    };
  };
  programs = {
    home-manager.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    permittedInsecurePackages = [
      "electron-24.8.6" # Feishin
    ];
  };
}
