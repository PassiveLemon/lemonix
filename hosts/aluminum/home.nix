{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../modules/customization.nix
    ../../modules/kitty.nix
    ../../modules/vscode.nix
    ../../modules/spicetify.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  home = {
    packages = with pkgs; [
      webcord-vencord
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ../../shareddots/.config;
        recursive = true;
      };
      ".local/" = {
        source = ../../shareddots/.local;
        recursive = true;
      };
      ".vscode-oss/" = {
        source = ../../shareddots/.vscode-oss;
        recursive = true;
      };
      ".xinitrc" = {
        source = ../../shareddots/.xinitrc;
      };
    };
    stateVersion = "to be added";
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
  programs.home-manager.enable = true;

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
      };
    };
    desktopEntries = {
      discord = {
        name = "Discord";
        exec = "webcord -- --add-css-theme=/home/lemon/.config/BetterDiscord/themes/Lemon.theme.css";
        icon = "/home/lemon/.icons/Papirus/32x32/apps/webcord.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
      };
    };
  };
}
