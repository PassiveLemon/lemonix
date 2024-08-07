{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      # Terminal
      tym hilbish eza bat thefuck trashy fd ripgrep pamixer playerctl imagemagick appimage-run ventoy-bin
      # Browsing
      firefox freetube
      # Communication
      webcord-vencord vesktop srain teams-for-linux
      # File/storage management
      pcmanfm ffmpegthumbnailer xarchiver filezilla gparted
      # Development
      lite-xl vscode github-desktop imhex
      shellcheck luajitPackages.luacheck python312Packages.flake8
      # Office
      obsidian onlyoffice-bin drawio
      # Audio
      pavucontrol easyeffects helvum tauon feishin audacity
      # Image/Video
      loupe mpv flameshot gimp feh libsForQt5.kdenlive scrot
      # Miscellaneous
      libqalculate libsForQt5.kruler mullvad-vpn localsend xclicker
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ./home/.config;
        recursive = true;
      };
      ".config/awesome/libraries/bling" = {
        source = inputs.awesomewm-bling;
        recursive = true;
      };
      ".config/lite-xl/libraries/widget" = {
        source = inputs.lite-xl-widget;
        recursive = true;
      };
      ".config/lite-xl/plugins/editorconfig" = {
        source = inputs.lite-xl-plugins + "/plugins/editorconfig";
        recursive = true;
      };
      ".config/lite-xl/plugins/lintplus" = {
        source = inputs.lite-xl-lintplus;
        recursive = true;
      };
      ".config/lite-xl/plugins/evergreen" = {
        source = inputs.lite-xl-evergreen;
        recursive = true;
      };
      ".vscode/" = {
        source = ./home/.vscode;
        recursive = true;
      };
      ".xinitrc" = {
        source = ./home/.xinitrc;
      };
      "Documents" = {
        source = ./home/Documents;
        recursive = true;
      };
    };
  };

  xsession = {
    enable = true;
    windowManager = {
      awesome = {
        enable = true;
        package = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-luajit-git;
        luaModules = with pkgs; [
          luajitPackages.luafilesystem
        ];
      };
    };
  };

  services = {
    autorandr.enable = true;
  };

  programs = {
    autorandr.enable = true;
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
    configFile."mimeapps.list".force = true;
    desktopEntries = {
      "Discord" = { # Alias Discord to Webcord with CSS theme. Theme is currently broken.
        # Temporarily aliased to Vesktop until Webcord starts working again.
        name = "Discord";
        exec = "vesktop";
        icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/discord.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  news.display = "silent";
}

