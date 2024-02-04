{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
    ../../../modules/home-manager/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      tym rofi i3lock-fancy-rapid pcmanfm xarchiver gparted
      firefox master.webcord-vencord freetube authy
      lite-xl vscode github-desktop imhex
      obsidian onlyoffice-bin drawio
      old.easyeffects pavucontrol helvum mpv tauon feishin audacity
      scrot libsForQt5.kdenlive haruna feh gimp
      filezilla qbittorrent
      hilbish eza bat thefuck trashy fd ripgrep
      pamixer playerctl appimage-run ventoy-bin
      libsForQt5.kruler localsend old.mullvad-vpn
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ../../../common/dots/.config;
        recursive = true;
      };
      ".vscode/" = {
        source = ../../../common/dots/.vscode;
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
        "General" = {
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
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/zip" = "xarchiver.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/matroska" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/opus" = "mpv.desktop";
        "audio/vorbis" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "audio/x-opus+ogg" = "mpv.desktop";
        "image/bmp" = "feh.desktop";
        "image/gif" = "firefox.desktop";
        "image/heic" = "feh.desktop";
        "image/heif" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        "image/svg+xml" = "feh.desktop";
        "inode/directory" = "pcmanfm.desktop";
        "text/html" = "firefox.desktop";
        "video/matroska" = "org.kde.haruna.desktop";
        "video/mp4" = "org.kde.haruna.desktop";
        "video/mpeg" = "org.kde.haruna.desktop";
        "video/MPV" = "org.kde.haruna.desktop";
        "video/ogg" = "org.kde.haruna.desktop";
        "video/quicktime" = "org.kde.haruna.desktop";
        "video/webm" = "org.kde.haruna.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
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
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };
}

