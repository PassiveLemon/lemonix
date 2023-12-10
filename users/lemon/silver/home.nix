{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
    ../../../common/modules/gaming.nix
    ../../../common/modules/picom.nix
    ../../../common/modules/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      i3lock-fancy-rapid firefox pcmanfm xarchiver gparted
      tym hilbish lite-xl rofi vscodium obsidian github-desktop imhex act
      old.easyeffects pavucontrol helvum soundux mpv tauon feishin audacity easytag
      flowblade haruna feh gimp
      master.webcord-vencord authy filezilla qbittorrent
      eza bat trashy fd ripgrep
      pamixer playerctl appimage-run neofetch ventoy-bin headsetcontrol
      libsForQt5.kruler
      mullvad-vpn
      scrot maim slop xdotool
      freetube animdl
      rsync

      # Development
      jq
      (python311.withPackages(ps: with ps; [ pip pillow evdev pyyaml pynput colorama ]))
      (luajit.withPackages (ps: with ps; [ luarocks ]))
      cmake
      dotnet-sdk
      libtifiles2 libticonv libticalcs2 libticables2

      # Custom
      (callPackage ../../../pkgs/corrupter { })
      (callPackage ../../../pkgs/slavartdl { })
      (callPackage ../../../pkgs/tilp2 { gfm = callPackage ../../../pkgs/gfm { }; })
      (callPackage ../../../pkgs/xclicker { })
      (python3Packages.callPackage ../../../pkgs/pulsemeeter { })
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
        "audio/flac" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "video/mp4" = "org.kde.haruna.desktop";
        "video/quicktime" = "org.kde.haruna.desktop";
        "video/webm" = "org.kde.haruna.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";
      };
    };
    desktopEntries = {
      discord = { # Alias Discord to Webcord with CSS skin
        name = "Discord";
        exec = "webcord -- --add-css-theme=/home/lemon/.config/BetterDiscord/themes/Lemon.theme.css";
        icon = "/home/lemon/.icons/Papirus/64x64/apps/webcord.svg";
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
      "electron-24.8.6" # Feishin
    ];
  };
}

