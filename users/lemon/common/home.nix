{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./modules/customization.nix
    inputs.nixcord.homeManagerModules.nixcord
  ];

  home = {
    packages = with pkgs; [
      # Terminal
      tym hilbish comma fend thefuck trashy pamixer playerctl imagemagick appimage-run ventoy-bin
      eza bat fd ripgrep jq nh
      # File/storage management
      pcmanfm xarchiver filezilla gparted
      ffmpegthumbnailer
      # Development
      lite-xl vscode github-desktop
      shellcheck luajitPackages.luacheck python312Packages.flake8
      nil nimlsp pyright lua-language-server bash-language-server dockerfile-language-server-nodejs yaml-language-server
      # Office
      obsidian onlyoffice-desktopeditors onlyoffice-documentserver drawio
      # Audio
      feishin audacity
      pwvucontrol easyeffects helvum
      # Image/Video
      loupe flameshot gimp scrot krita
      mpv kdePackages.kdenlive
      # Miscellaneous
      picom ente-auth localsend xclicker kdePackages.kruler
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ./home/.config;
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
    windowManager.awesome = {
      enable = true;
      package = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-luajit-git;
      luaModules = with pkgs; [
        luajitPackages.luafilesystem
      ] ++ (with astal; [
        auth battery mpris network wireplumber
        # bluetooth powerprofiles # Some stuff to experiment with in the future?
      ]);
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
    firefox = {
      enable = true;
      profiles."lemon" = {
        id = 0;
        isDefault = true;
        search = {
          default = "DuckDuckGo";
          privateDefault = "DuckDuckGo";
          order = [ "DuckDuckGo" ];
          force = true;
          engines = {
            "Bing".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = false;
            "Google".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
          };
        };
        settings = {
          "accessibility.typeaheadfind.enablesound" = false;
        };
      };
      policies = {
        "DisablePocket" = true;
        "DisableTelemetry" = true;
        "HardwareAcceleration" = true;
      };
    };
    nixcord = {
      enable = true;
      config = {
        frameless = true;
        disableMinSize = true;
        themeLinks = [
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/Lemon.theme.css"
        ];
        plugins = {
          anonymiseFileNames = {
            enable = true;
            anonymiseByDefault = true;
          };
          betterRoleContext.enable = true;
          clearURLs.enable = true;
          crashHandler.enable = true;
          fakeNitro.enable = true;
          fixSpotifyEmbeds.enable = true;
          fixYoutubeEmbeds.enable = true;
          imageZoom = {
            # Currently crashes Discord
            enable = false;
            saveZoomValues = false;
            size = 800.0;
          };
          messageClickActions = {
            enable = true;
            requireModifier = true;
          };
          messageLinkEmbeds.enable = true;
          messageLogger = {
            enable = true;
            ignoreBots = true;
            ignoreSelf = true;
          };
          moreCommands.enable = true;
          moreKaomoji.enable = true;
          noBlockedMessages.enable = true;
          noReplyMention.enable = true;
          normalizeMessageLinks.enable = true;
          roleColorEverywhere.enable = true;
          shikiCodeblocks = {
            enable = true;
            theme = "https://raw.githubusercontent.com/PassiveLemon/lemonix/master/users/lemon/common/home/.vscode/extensions/lemon-color-theme/themes/lemon-color-theme.json";
          };
          showConnections.enable = true;
          validReply.enable = true;
          viewIcons.enable = true;
          voiceMessages.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "awesome/libraries/bling" = {
        source = inputs.awesomewm-bling;
        recursive = true;
      };
      "awesome/liblua_pam.so" = {
        source = "${inputs.lemonake.packages.${pkgs.system}.lua-pam-git}/lib/liblua_pam.so";
      };
      "lite-xl/libraries/widget" = {
        source = inputs.lite-xl-widget;
        recursive = true;
      };
      "lite-xl/plugins/editorconfig" = {
        source = inputs.lite-xl-plugins + "/plugins/editorconfig";
        recursive = true;
      };
      "lite-xl/plugins/lintplus" = {
        source = inputs.lite-xl-lintplus;
        recursive = true;
      };
      "lite-xl/plugins/evergreen" = {
        source = inputs.lite-xl-evergreen;
        recursive = true;
      };
      "lite-xl/plugins/treeview-extender" = {
        source = inputs.lite-xl-treeview-extender;
        recursive = true;
      };
      "lite-xl/plugins/lsp" = {
        source = inputs.lite-xl-lsp;
        recursive = true;
      };
      "mimeapps.list".force = true;
    };
    dataFile = {
      "hilbish/libs/promptua" = {
        source = inputs.hilbish-promptua;
      };
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
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
      "pcmanfm-desktop-pref" = {
        name = "Desktop Preferences";
        noDisplay = true;
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    overlays = [
      outputs.overlays.packages
    ];
  };

  news.display = "silent";
}

