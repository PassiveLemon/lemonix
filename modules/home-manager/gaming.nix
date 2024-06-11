{ inputs, pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
  wivrn = pkgs.callPackage ../../pkgs/wivrn { };
  opencomp = pkgs.callPackage ../../pkgs/opencomposite { };
in
{
  options = {
    lemonix.gaming = {
      enable = mkEnableOption "desktop gaming";

      vr = {
        enable = mkEnableOption "vr gaming";
      };
    };
  };

  imports = [
    inputs.lemonake.homeManagerModules.steamvr
  ];

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        protonup-ng
        gamemode dxvk
        r2modman
        lunar-client prismlauncher
        inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon-unstable
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
        master.wlx-overlay-s
        sidequest autoadb
        BeatSaberModManager
        xrgears
        #(callPackage ../../pkgs/sphvr { gulkan = pkgs.callPackage ../../pkgs/sphvr/gulkan.nix { }; })
        #(callPackage ../../pkgs/vr-video-player { })
      ];

      services.steamvr = {
        runtimeOverride = {
          enable = true;
          #path = "/home/lemon/.local/share/Steam/steamapps/common/SteamVR";
          #path = "${pkgs.unstable.opencomposite}/lib/opencomposite";
          path = "${opencomp}/lib/opencomposite";
        };
        activeRuntimeOverride = {
          enable = true;
          #path = "/home/lemon/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";
          path = "${wivrn}/share/openxr/1/openxr_wivrn.json";
        };
      };

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/beatsaver" = "BeatSaberModManager-url-beatsaver.desktop";
        "x-scheme-handler/bsplaylist" = "BeatSaberModManager-url-bsplaylist.desktop";
        "x-scheme-handler/modelsaber" = "BeatSaberModManager-url-modelsaber.desktop";
      };
    })
  ];
}
