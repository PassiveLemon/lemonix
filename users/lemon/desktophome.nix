{ config, pkgs, ... }: {
  imports = [
    ./config/desktop.nix
    ../../modules/gtk.nix
    ../../modules/kitty.nix
    ../../modules/picom.nix
    ../../modules/vscode.nix
    ../../modules/spicetify.nix
    #../../modules/gdlauncher.nix
    #../../modules/gdlauncherold.nix
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
    stateVersion = "23.05";
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
    megasync.enable = true;
  };
  programs.home-manager.enable = true;
}
