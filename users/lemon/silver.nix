{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ../../modules/customization.nix
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
    packages = with pkgs; [
      (callPackage ../../pkgs/gdlauncher.nix {})
    ];
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
      gdlauncher = {
        name = "GDLauncher-hm";
        exec = "appimage-run /home/lemon/Standalone/GDLauncher-linux-setup.AppImage --no-sandbox";
        terminal = false;
      };
      xclicker = {
        name = "xclicker";
        exec = "appimage-run /home/lemon/Standalone/xclicker_amd64.AppImage";
        terminal = false;
      };
      r2modman = {
        name = "r2modman";
        exec = "appimage-run /home/lemon/Standalone/r2modman.AppImage --no-sandbox";
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
