{ config, pkgs, ... }: {
  imports = [
    ../../modules/gtk.nix
    ../../modules/kitty.nix
    ../../modules/picom.nix
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
    stateVersion = "22.11";
    file = {
      ".config/" = {
        source = ../../modules/config;
        recursive = true;
      };
      ".xinitrc" = {
        source = ./.xinitrc;
      };
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
  programs.home-manager.enable = true;
}
