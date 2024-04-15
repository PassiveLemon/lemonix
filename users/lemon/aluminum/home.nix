{ inputs, pkgs, config, lib, ... }: {
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
        source = ./home/.config/autostart;
        recursive = true;
      };
      ".config/awesome/config" = {
        source = ./home/.config/awesome/config;
        recursive = true;
      };
      ".config/awesome/signal" = {
        source = ./home/.config/awesome/signal;
        recursive = true;
      };
      ".config/awesome/ui" = {
        source = ./home/.config/awesome/ui;
        recursive = true;
      };
    };
    stateVersion = "23.05";
  };

  services = {
    autorandr.enable = true;
  };

  programs = {
    autorandr = {
      enable = true;
      profiles = {
        "Default" = {
          fingerprint = {
            eDP-1 = "xxxxxx";
          };
          config = {
            "eDP-1" = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "1920x1080";
              rate = "60.01";
              gamma = "1.0:0.92:0.92";
            };
          };
        };
      };
    };
  };

  xsession = {
    windowManager.awesome.noArgb = true;
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
      "electron-24.8.6" # Feishin
      "electron-25.9.0"
    ];
  };
}
