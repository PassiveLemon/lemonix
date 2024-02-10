{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
    ../../../modules/home-manager/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      tym rofi i3lock-fancy-rapid gparted
      pcmanfm xarchiver ffmpegthumbnailer filezilla
      firefox master.webcord-vencord authy freetube
      lite-xl vscode github-desktop imhex
      obsidian onlyoffice-bin drawio
      pavucontrol old.easyeffects mpv helvum tauon feishin audacity
      loupe feh gimp libsForQt5.kdenlive scrot
      hilbish eza bat thefuck trashy fd ripgrep python3
      pamixer playerctl appimage-run ventoy-bin
      qbittorrent libsForQt5.kruler old.mullvad-vpn localsend
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ./dots/.config;
        recursive = true;
      };
      ".vscode/" = {
        source = ./dots/.vscode;
        recursive = true;
      };
      ".xinitrc" = {
        source = ./dots/.xinitrc;
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
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/heic" = "org.gnome.Loupe.desktop";
        "image/heif" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "inode/directory" = "pcmanfm.desktop";
        "text/html" = "firefox.desktop";
        "video/matroska" = "mpv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/MPV" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
    desktopEntries = {
      "Discord" = { # Alias Discord to Webcord with CSS skin
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

