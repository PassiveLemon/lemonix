{ inputs, pkgs, ... }: {
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
      # https://github.com/lite-xl/lite-xl/issues/2209
      package = pkgs.lite-xl.override {
        freetype = pkgs.freetype.overrideAttrs (finalAttrs: prevAttrs: {
          version = "2.14.1";
          src = pkgs.fetchurl {
            url = "mirror://savannah/freetype/freetype-${finalAttrs.version}.tar.xz";
            hash = "sha256-MkJ+jEcawJWFMhKjeu+BbGC0IFLU2eSCMLqzvfKTbMw=";
          };
        });
      };
      fonts.enable = true;
      plugins = {
        enableList = [
          "autoinsert" "autowrap" "bracketmatch" "colorpicker" "colorpreview"
          "eofnewline" "ephemeral_tabs" "editorconfig" "extend_selection_line"
          "force_syntax" "gitdiff_highlight" "gitstatus" "indentguide" "ipc"
          "lfautoinsert" "litemark" "nerdicons" "open_ext" "openfilelocation"
          "selectionhighlight" "terminal" "treeview-extender"
        ];
        customEnableList = {
          "exterm" = ../home/.config/lite-xl/plugins/exterm.lua;
          "nerdicons" = ../home/.config/lite-xl/plugins/nerdicons.lua;
        };
        languages = {
          enableList = [ "diff" "env" "lua" "go" "html" "json" "nim" "python" "sh" "toml" ]; 
          customEnableList = {
            "containerfile" = ../home/.config/lite-xl/plugins/languages/language_containerfile.lua;
            "nix" = ../home/.config/lite-xl/plugins/languages/language_nix.lua;
            "yaml" = ../home/.config/lite-xl/plugins/languages/language_yaml.lua;
          };
        };
        evergreen.copyLanguages.enable = true;
        lsp = {
          enableList = [ "bash_ls" "dockerfile_ls_nodejs" "nil_ls" "nimlsp" "pyright" "lua_ls" "yaml_ls" ];
          addPackages = true;
        };
        lintplus = {
          enableList = [ "luacheck" "shellcheck" ];
          addPackages = true;
          copyLanguages.enable = true;
        };
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
          roleColorEverywhere.enable = true;
          shikiCodeblocks.enable = true;
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

