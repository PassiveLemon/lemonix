{ config, pkgs, ... }: {
  imports = [
    ./config/desktop.nix
    ../../modules/gtk.nix
    ../../modules/kitty.nix
    ../../modules/picom.nix     
    ../../modules/spicetify.nix
    ../../modules/vscode.nix
  ];

  nixpkgs.config = { allowUnfree = true; };

  home.username = "lemon";
  home.homeDirectory = "/home/lemon";
  home.stateVersion = "22.11";

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
  home = {
    file = {
      ".config/" = {
        source = ../../modules/config;
        recursive = true;
      };
    };
  };
  stateVersion = "22.11";
  programs.home-manager.enable = true;
}