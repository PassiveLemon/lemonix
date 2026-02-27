{ inputs, lib, pkgs, ... }:
let
  inherit (lib) genAttrs genAttrs' nameValuePair mergeAttrsList;
  genBoolAttrs = bool: list: genAttrs list (name: bool);
  genBoolAttrs' = cb: bool: list: genAttrs' list (name: nameValuePair name (cb bool));
in {
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.nix-xl.homeModules.nix-xl
  ];

  programs = {
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
          engines = mergeAttrsList [
            (genBoolAttrs' (b: { metaData.hidden = b; }) true [
              "amazon"
              "amazon.com"
              "bing"
              "ebay"
              "google"
              "perplexity"
              "wikipedia"
            ])
            { "ddg".metaData.hidden = false; }
          ];
        };
        # https://firefox-admin-docs.mozilla.org/reference/policies/
        settings = mergeAttrsList [
          (genBoolAttrs true [
            "gfx.webrender.all"
            "gfx.webrender.compositor"
            "layers.acceleration.force-enabled"
            "media.ffmpeg.vaapi.enabled"
          ])
          (genBoolAttrs false [
            "accessibility.typeaheadfind.enablesound"
            "browser.newtabpage.activity-stream.feeds.telemetry"
            "browser.tabs.groups.enabled"
            "browser.tabs.splitView.enabled"
            "datareporting.healthreport.uploadEnabled"
            "extensions.pocket.enabled"
            "layers.acceleration.disabled"
            "sidebar.verticalTabs"
            "signon.rememberSignons"
            "toolkit.telemetry.enabled"
          ])
          {
            "sidebar.visibility" = "hide-sidebar";
          }
        ];
      };
    };
    nixcord = {
      enable = true;
      discord.vencord.enable = true;
      config = {
        frameless = true;
        disableMinSize = true;
        themeLinks = [
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/Lemon.css"
          "https://raw.githubusercontent.com/PassiveLemon/lemonix/refs/heads/master/users/lemon/common/home/.config/Vencord/themes/LemonTweaks.css"
          "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/refs/heads/master/Themes/DiscordRecolor/DiscordRecolor.css"
          "https://raw.githubusercontent.com/MaiRiosIPla/unshittify-discord/refs/heads/main/RoundIconsSource.theme.css"
        ];
        plugins = mergeAttrsList [
          (genBoolAttrs' (b: { enable = b; }) true [
            "betterRoleContext"
            "clearUrls"
            "crashHandler"
            "fakeNitro"
            "fixSpotifyEmbeds"
            "messageLinkEmbeds"
            "noBlockedMessages"
            "noReplyMention"
            "roleColorEverywhere"
            "shikiCodeblocks"
            "showConnections"
            "validReply"
            "viewIcons"
            "voiceMessages"
            "youtubeAdblock"
          ])
          {
            anonymiseFileNames = {
              enable = true;
              anonymiseByDefault = true;
            };
            imageZoom = {
              enable = true;
              saveZoomValues = false;
              size = 800.0;
            };
            messageClickActions = {
              enable = true;
              requireModifier = true;
            };
            messageLogger = {
              enable = true;
              ignoreBots = true;
              ignoreSelf = true;
            };
          }
        ];
      };
    };
    obsidian = {
      enable = true;
      vaults."Lemon" = {
        enable = true;
        target = "Documents/Obsidian/Lemon";
        settings = {
          appearance = {
            accentColor = "#61b8ff";
            baseFontSize = 16;
            cssTheme = "Lemon";
          };
          corePlugins = [
            "canvas"
            "file-explorer"
            "outgoing-link"
            "word-count"
          ];
          communityPlugins = with pkgs.nix-obsidian.obsidianPlugins; [
            meld-encrypt
            obsidian-kanban
            obsidian-latex-suite
            obsidian-livesync
          ];
        };
      };
    };
  };
}

