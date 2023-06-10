{ config, pkgs, ... }: {
  imports = [
    ../../modules/gtk.nix
    ../../modules/kitty.nix
    ../../modules/vscode.nix
    ../../modules/spicetify.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  home = {
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ../../dots/.config;
        recursive = true;
      };
      ".local/" = {
        source = ../../dots/.local;
        recursive = true;
      };
      ".vscode-oss/" = {
        source = ../../dots/.vscode-oss;
        recursive = true;
      };
      ".xinitrc" = {
        source = ../../dots/.xinitrc;
      };
    };
    stateVersion = "to be added";
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
  programs.home-manager.enable = true;
}
