{ inputs, pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
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
    inputs.lemonake.homeManagerModules.tmodloader-dotnetfix
  ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      home.packages = with pkgs; [
        protonup-ng protontricks
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
        sidequest
        nexusmods-app beatsabermodmanager
        xrgears
        #(callPackage ../../pkgs/sphvr { gulkan = pkgs.callPackage ../../pkgs/sphvr/gulkan.nix { }; })
        #(callPackage ../../pkgs/vr-video-player { })
      ];

      services.steamvr = let
        wivrn = pkgs.callPackage ../../pkgs/wivrn-personal { };
      in {
        runtimeOverride = {
          enable = true;
          path = "${pkgs.unstable.opencomposite}/lib/opencomposite";
        };
        activeRuntimeOverride = {
          enable = true;
          path = "${wivrn}/share/openxr/1/openxr_wivrn.json";
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
