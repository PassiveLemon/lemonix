{ inputs, config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
  wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn.override { cudaSupport = true; };
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
        enable = true;
        openvrRuntimeOverride = {
          enable = true;
          config = "path";
          path = "${inputs.lemonake.packages.${pkgs.system}.opencomposite-git}/lib/opencomposite";
          # path = "${inputs.lemonake.packages.${pkgs.system}.xrizer}/lib";
          # path = "${inputs.lemonake.packages.${pkgs.system}.vapor-git}/lib";
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
          # openvrRuntime = "xrizer";
          # openvrRuntimePackage = inputs.lemonake.packages.${pkgs.system}.xrizer;
          # openvrRuntime = "vapor";
          # openvrRuntimePackage = inputs.lemonake.packages.${pkgs.system}.vapor-git;
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

