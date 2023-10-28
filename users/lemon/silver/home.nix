{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
    ../../../common/modules/gaming.nix
    ../../../common/modules/picom.nix
    ../../../common/modules/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      i3lock-fancy-rapid
      firefox pcmanfm gparted pavucontrol helvum
      tym lite-xl rofi hilbish vscodium github-desktop webcord-vencord imhex tauon
      haruna feh gimp authy xarchiver filezilla easytag easyeffects soundux flowblade audacity qbittorrent
      eza bat trashy fd ripgrep
      pamixer playerctl appimage-run neofetch ventoy-bin act maim headsetcontrol
      libsForQt5.kruler
      mullvad-vpn

      # Development
      (python311.withPackages(ps: with ps; [ pip pillow evdev pyyaml pynput colorama ]))
      jq
      stdenvNoCC gnumake gnat13 nodejs_16 rustup
      go
      dotnet-sdk
      libtifiles2 libticonv libticalcs2 libticables2
      maim slop xdotool

      # Custom
      (callPackage ../../../pkgs/corrupter { })
      (callPackage ../../../pkgs/slavartdl { })
      (callPackage ../../../pkgs/tilp2 { gfm = callPackage ../../../pkgs/gfm { }; })
      (callPackage ../../../pkgs/xclicker { })
      (python3Packages.callPackage ../../../pkgs/animdl { anchor-kr = python3Packages.callPackage ../../../pkgs/anchor-kr { }; anitopy = python3Packages.callPackage ../../../pkgs/anitopy { }; })
      (python3Packages.callPackage ../../../pkgs/onthespot { music-tag = python3Packages.callPackage ../../../pkgs/music-tag { }; })
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
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
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
  };
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";
      };
    };
    desktopEntries = {
      discord = { # Launcher Webcord with CSS theme as a Discord alias
        name = "Discord";
        exec = "webcord -- --add-css-theme=/home/lemon/.config/BetterDiscord/themes/Lemon.theme.css";
        icon = "/home/lemon/.icons/Papirus/32x32/apps/webcord.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
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

