{ inputs, pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
  # Overriden until I somehow fix the cudaSupport stuff
  wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn-git.override { cudaSupport = true; };
  # wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn;
in
{
  options = {
    lemonix.gaming = {
      enable = mkEnableOption "gaming modules";
      desktop.enable = mkEnableOption "desktop gaming";
      vr.enable = mkEnableOption "vr gaming";
      streaming.enable = mkEnableOption "game streaming";
    };
  };

  imports = [
    inputs.lemonake.homeManagerModules.steamvr
  ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      home.packages = with pkgs; [
        protonup-ng protontricks
        gamemode dxvk
        r2modman
        heroic
        lunar-client prismlauncher
        inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
        bottles
        ludusavi
      ];

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
      };
    })
    (mkIf cfg.vr.enable {
      home.packages = with pkgs; [
        sidequest
        nexusmods-app beatsabermodmanager
        xrgears
      ];

      programs.steamvr = {
        openvrRuntimeOverride = {
          enable = true;
          config = "json";
          json = {
            config = [
              "${config.home.homeDirectory}/.local/share/Steam/config"
            ];
            external_drivers = [ ];
            jsonid = "vrpathreg";
            log = [
              "${config.home.homeDirectory}/.local/share/Steam/logs"
            ];
            runtime = [
              "${inputs.lemonake.packages.${pkgs.system}.opencomposite-git}/lib/opencomposite"
            ];
            version = 1;
          };
        };
        openxrRuntimeOverride = {
          enable = true;
          config = "path";
          path = "${wivrnPackage}/share/openxr/1/openxr_wivrn.json";
        };
        helperScript = {
          enable = true;
          openvrRuntime = "opencomposite";
          openvrRuntimePackage = inputs.lemonake.packages.${pkgs.system}.opencomposite-git;
          openxrRuntime = "wivrn";
          openxrRuntimePackage = wivrnPackage;
        };
      };

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/beatsaver" = "BeatSaberModManager-url-beatsaver.desktop";
        "x-scheme-handler/bsplaylist" = "BeatSaberModManager-url-bsplaylist.desktop";
        "x-scheme-handler/modelsaber" = "BeatSaberModManager-url-modelsaber.desktop";
      };
    })
    (mkIf cfg.streaming.enable {
      home.packages = with pkgs; [
        moonlight-qt
      ];
    })
  ]);
}

