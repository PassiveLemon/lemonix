{ inputs, ... }: {
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.nix-xl.homeModules.nix-xl
  ];

  services = {
    autorandr.enable = true;
  };

  programs = {
    autorandr.enable = true;
    home-manager.enable = true;
    obs-studio.enable = true;
    lite-xl = {
      enable = true;
      plugins = {
        enableList = [
          "autoinsert" "autowrap" "bracketmatch" "colorpicker" "colorpreview"
          "eofnewline" "ephemeral_tabs" "editorconfig" "evergreen"
          "extend_selection_line" "force_syntax" "gitdiff_highlight" "gitstatus"
          "indentguide" "lfautoinsert" "lintplus" "litemark" "lsp" "lsp_snippets" "open_ext"
          "openfilelocation" "selectionhighlight" "terminal" "treeview-extender"
        ];
        customEnableList = {
          "exterm" = ../home/.config/lite-xl/plugins/exterm.lua;
          "nerdicons" = ../home/.config/lite-xl/plugins/nerdicons.lua;
        };
        languages = {
          enableList = [ "diff" "env" "ignore" "go" "json" "nim" "sh" "toml" "zig" ]; 
          customEnableList = {
            "containerfile" = ../home/.config/lite-xl/plugins/languages/language_containerfile.lua;
            "nix" = ../home/.config/lite-xl/plugins/languages/language_nix.lua;
            "yaml" = ../home/.config/lite-xl/plugins/languages/language_yaml.lua;
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
            "amazon".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "ddg".metaData.hidden = false;
            "ebay".metaData.hidden = true;
            "google".metaData.hidden = true;
            "perplexity".metaData.hidden = true;
            "wikipedia".metaData.hidden = true;
          };
        };
        settings = {
          "accessibility.typeaheadfind.enablesound" = false;
          "gfx.webrender.all" = true;
          "gfx.webrender.compositor" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "toolkit.telemetry.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
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
          "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/refs/heads/master/Themes/DiscordRecolor/DiscordRecolor.css"
          "https://raw.githubusercontent.com/MaiRiosIPla/unshittify-discord/refs/heads/main/RoundIconsSource.theme.css"
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/Lemon.theme.css"
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/LemonTweaks.theme.css"
        ];
        plugins = {
          anonymiseFileNames = {
            enable = true;
            anonymiseByDefault = true;
          };
          betterRoleContext.enable = true;
          ClearURLs.enable = true;
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
          noBlockedMessages.enable = true;
          noReplyMention.enable = true;
          normalizeMessageLinks.enable = true;
          roleColorEverywhere.enable = true;
          shikiCodeblocks = {
            enable = true;
            customTheme = "https://raw.githubusercontent.com/PassiveLemon/lemonix/master/users/lemon/common/home/.vscode/extensions/lemon-color-theme/themes/lemon-color-theme.json";
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
}

