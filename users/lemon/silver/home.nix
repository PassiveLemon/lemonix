{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../../modules/customization.nix
    ../../../modules/kitty.nix
    ../../../modules/picom.nix
    ../../../modules/vscode.nix
    ../../../modules/spicetify.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  home = {
    packages = with pkgs; [
      xonotic webcord-vencord tidal-hifi blahaj lolcat go
      (callPackage ../../../pkgs/corrupter { })
      (callPackage ../../../pkgs/xclicker/back.nix { })
      (python3Packages.callPackage ../../../pkgs/animdl { })
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/awesome/config/autostart.lua" = {
        source = ./dots/.config/awesome/config/autostart.lua;
      };
      ".config/" = {
        source = ../../../common/dots/.config;
        recursive = true;
      };
      ".local/" = {
        source = ../../../common/dots/.local;
        recursive = true;
      };
      ".vscode-oss/" = {
        source = ../../../common/dots/.vscode-oss;
        recursive = true;
      };
      ".xinitrc" = {
        source = ../../../common/dots/.xinitrc;
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
    megasync.enable = true;
  };
  programs.home-manager.enable = true;

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
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
      #gdlauncher = {
      #  name = "GDLauncher";
      #  exec = "gdlauncher-1.1.30";
      #  icon = "/home/lemon/.icons/Papirus/32x32/apps/gdlauncher.svg";
      #  terminal = false;
      #  type = "Application";
      #  categories = [ "Application" ];
      #};
      xclicker = {
        name = "XClicker";
        exec = "xclicker";
        terminal = false;
      };
      sd-comfyui = {
        name = "sd-comfyui";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/ComfyUI.sh";
        terminal = true;
      };
      sd-auto = {
        name = "sd-auto";
        exec = "/home/lemon/Documents/GitHub/private/Scripts/Auto.sh";
        terminal = true;
      };
    };
  };
}
