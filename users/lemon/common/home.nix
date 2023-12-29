{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
    ../../../modules/home-manager/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      tym i3lock-fancy-rapid pcmanfm xarchiver gparted
      firefox master.webcord-vencord freetube authy
      lite-xl rofi vscodium github-desktop imhex act
      obsidian libreoffice drawio
      old.easyeffects pavucontrol helvum soundux mpv tauon feishin audacity easytag
      scrot flowblade haruna feh gimp animdl
      filezilla qbittorrent
      hilbish eza bat thefuck trashy fd ripgrep
      pamixer playerctl appimage-run ventoy-bin
      libsForQt5.kruler localsend old.mullvad-vpn onthespot
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
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
        "audio/matroska" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/opus" = "mpv.desktop";
        "audio/vorbis" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "image/bmp" = "feh.desktop";
        "image/gif" = "firefox.desktop";
        "image/heic" = "feh.desktop";
        "image/heif" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        "image/svg+xml" = "feh.desktop";
        "video/matroska" = "org.kde.haruna.desktop";
        "video/mp4" = "org.kde.haruna.desktop";
        "video/mpeg" = "org.kde.haruna.desktop";
        "video/MPV" = "org.kde.haruna.desktop";
        "video/ogg" = "org.kde.haruna.desktop";
        "video/quicktime" = "org.kde.haruna.desktop";
        "video/webm" = "org.kde.haruna.desktop";
      };
    };
    desktopEntries = {
      "discord" = { # Alias Discord to Webcord with CSS skin
        name = "Discord";
        exec = "webcord -- --add-css-theme=/home/lemon/.config/BetterDiscord/themes/Lemon.theme.css";
        icon = "/home/lemon/.icons/Papirus/64x64/apps/webcord.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
      };
    };
  };
}

