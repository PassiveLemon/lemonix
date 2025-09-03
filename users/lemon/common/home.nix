{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    ./modules/customization.nix
    inputs.nixcord.homeModules.nixcord
    inputs.nix-xl.homeModules.nix-xl
  ];

  home = {
    packages = with pkgs; [
      # Terminal
      tym hilbish comma fend pamixer imagemagick
      nh eza bat trashy fd ripgrep
      #nix-output-monitor dix 
      # File/storage management
      pcmanfm xarchiver gparted
      ffmpegthumbnailer
      # Development
      github-desktop
      shellcheck luajitPackages.luacheck python312Packages.flake8
      nil nimlsp pyright lua-language-server bash-language-server dockerfile-language-server-nodejs yaml-language-server
      # Office
      obsidian onlyoffice-desktopeditors onlyoffice-documentserver drawio
      # Audio
      feishin
      pwvucontrol easyeffects helvum
      # Image/Video
      loupe flameshot papers gimp scrot
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
      "Documents/" = {
        source = ./home/Documents;
        recursive = true;
      };
    };
  };

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = (inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-luajit-git.overrideAttrs (prevAttrs: {
        GI_TYPELIB_PATH = let
          mkTypeLibPath = pkg: "${pkg}/lib/girepository-1.0";
          extraGITypeLibPaths = lib.forEach (with pkgs; [
            networkmanager upower
          ] ++ (with pkgs.astal; [
            auth battery bluetooth mpris network powerprofiles wireplumber
          ])) mkTypeLibPath;
        in
        lib.concatStringsSep ":" (extraGITypeLibPaths ++ [ (mkTypeLibPath pkgs.pango.out) ]);
      }));
      luaModules = with pkgs; [
        luajitPackages.luafilesystem
      ];
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
      # https://github.com/NixOS/nixpkgs/issues/382666 but issue still persists
      package = (pkgs.obs-studio.override { cudaSupport = true; });
    };
    lite-xl = {
      enable = true;
      plugins = {
        enableList = [
          "autoinsert" "autowrap" "bracketmatch" "colorpicker" "colorpreview"
          /*"eofnewline" repo was deleted */ "ephemeral_tabs" "editorconfig" "evergreen" "force_syntax"
          "gitdiff_highlight" "gitstatus" "indentguide" "lfautoinsert" "lintplus"
          "lsp" "lsp_snippets" "open_ext" "selectionhighlight" "terminal"
          "treeview-extender"
        ];
        customEnableList = {
          "exterm" = ./home/.config/lite-xl/plugins/exterm.lua;
          "nerdicons" = ./home/.config/lite-xl/plugins/nerdicons.lua;
        };
        languages = {
          enableList = [ "diff" "env" "ignore" "go" "json" "nim" "sh" "toml" "zig" ]; 
          customEnableList = {
            "containerfile" = ./home/.config/lite-xl/plugins/languages/language_containerfile.lua;
            "nix" = ./home/.config/lite-xl/plugins/languages/language_nix.lua;
            "yaml" = ./home/.config/lite-xl/plugins/languages/language_yaml.lua;
          };
        };
        evergreen.enableList = [ "html" "lua" ];
        # formatter.enableList = [ "black" "ruff" ];
        # lsp.enableList = [ "lua" "yaml" ];
      };
      libraries.enableList = [ "font_symbols_nerdfont_mono_regular" "tree_sitter" "widget" ];
      fonts = {
        font = "FiraCodeNerdFont-Retina";
        # customFont = { name = "FiraCodeNerdFont-Retina"; value = pkgs.nerd-fonts.fira-code + "/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Retina.ttf"; };
        codeFont = "FiraCodeNerdFontMono-Retina";
      };
    };
    firefox = {
      enable = true;
      profiles."lemon" = {
        id = 0;
        isDefault = true;
        search = {
          default = "ddg";
          privateDefault = "ddg";
          order = [ "ddg" ];
          force = true;
          engines = {
            "bing".metaData.hidden = true;
            "ddg".metaData.hidden = false;
            "google".metaData.hidden = true;
            "wikipedia".metaData.hidden = true;
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
          "https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css"
          "https://mairiosipla.github.io/unshittify-discord/UnShittifySource.theme.css"
          "https://mairiosipla.github.io/unshittify-discord/RoundIconsSource.theme.css"
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/Lemon.theme.css"
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/LemonTweaks.theme.css"
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
            enable = true;
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
        "application/pdf" = "org.gnome.Papers.desktop";
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

