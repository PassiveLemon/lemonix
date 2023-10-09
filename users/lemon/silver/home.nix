{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../../../common/usermodules/customization.nix
    ../../../common/usermodules/gaming.nix
    ../../../common/usermodules/picom.nix
    ../../../common/usermodules/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      i3lock-fancy-rapid
      firefox pcmanfm gparted pavucontrol
      tym lite-xl rofi hilbish vscodium github-desktop webcord-vencord imhex tauon sonixd
      haruna feh gimp obs-studio authy xarchiver filezilla easytag easyeffects soundux flowblade audacity qbittorrent
      exa bat trashy fd ripgrep
      pamixer playerctl appimage-run neofetch ventoy-bin act scrot headsetcontrol
      libsForQt5.kruler
      xonotic

      # Development
      (python311.withPackages(ps: with ps; [ pip pillow evdev pyyaml pynput colorama ]))
      jq
      stdenvNoCC gnumake gnat13 nodejs_16 rustup
      go
      dotnet-sdk
      libtifiles2 libticonv libticalcs2 libticables2

      # Custom
      (callPackage ../../../pkgs/gdlauncher2 { }) # Use appimage wrapper version for now
      (callPackage ../../../pkgs/corrupter { })
      (callPackage ../../../pkgs/slavartdl { })
      (callPackage ../../../pkgs/tilp2 { })
      (callPackage ../../../pkgs/xclicker2 { }) # Use appimage wrapper version for now
      (callPackage ../../../pkgs/vinegar { wine = pkgs.master.wineWowPackages.staging; })
      (python3Packages.callPackage ../../../pkgs/animdl { })
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/autostart/" = {
        source = ./dots/.config/autostart;
        recursive = true;
      };
      ".config/" = {
        source = ../../../common/dots/.config;
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
    windowManager = {
      awesome = {
        enable = true;
        package = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-luajit-git;
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
    megasync.enable = true;
  };
  programs = {
    home-manager.enable = true;
  };
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
      gdlauncher = {
        name = "GDLauncher";
        exec = "gdlauncher-1.1.30";
        icon = "/home/lemon/.icons/Papirus/32x32/apps/gdlauncher.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
      };
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
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    permittedInsecurePackages = [
      "openssl-1.1.1u"
      "nodejs-16.20.2"
      "nodejs-16.20.0"
      "python-2.7.18.6"
      "electron-19.0.7"
    ];
  };
}

