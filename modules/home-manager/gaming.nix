{ inputs, system, config, lib, pkgs, ... }:
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

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      home.packages = with pkgs; [
        steam heroic (bottles.override { removeWarningPopup = true; })
        r2modman limo
        inputs.lemonake.packages.${system}.gdlauncher-carbon
        ludusavi
      ];

      xdg = {
        dataFile = {
          "Steam/compatibilitytools.d/proton-ge" = {
            source = "${pkgs.proton-ge-bin.steamcompattool}";
            recursive = true;
          };
        };
        mimeApps.defaultApplications = {
          "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
          "x-scheme-handler/ror2mm" = "r2modman.desktop";
          "x-scheme-handler/nxm" = "limo.desktop";
        };
      };
    })
    (mkIf cfg.vr.enable {
      home.packages = with pkgs; [
        inputs.lemonake.packages.${system}.wayvr
        bs-manager
      ];

      # WiVRn manages OpenXR and OpenVR runtimes

      xdg = {
        dataFile = {
          "Steam/compatibilitytools.d/proton-ge-rtsp" = {
            source = "${inputs.lemonake.packages.${system}.proton-ge-rtsp.steamcompattool}";
            recursive = true;
          };
        };
        mimeApps.defaultApplications = {
          "x-scheme-handler/beatsaver" = "BeatSaberModManager-url-beatsaver.desktop";
          "x-scheme-handler/bsplaylist" = "BeatSaberModManager-url-bsplaylist.desktop";
          "x-scheme-handler/modelsaber" = "BeatSaberModManager-url-modelsaber.desktop";
        };
      };
    })
    (mkIf cfg.streaming.enable {
      home.packages = with pkgs; [
        moonlight-qt
      ];
    })
  ]);
}

