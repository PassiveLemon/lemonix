{ config, lib, pkgs, ... }:
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
        gale limo lemonake.gdlauncher
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
        desktopEntries = {
          "Gale" = { # https://github.com/tauri-apps/tauri/issues/9394
            name = "Gale";
            icon = "gale";
            exec = "env WEBKIT_DISABLE_DMABUF_RENDERER=1 WEBKIT_DISABLE_COMPOSITING_MODR=1 gale";
          };
        };
      };
    })
    (mkIf cfg.vr.enable {
      home.packages = with pkgs; [
        lemonake.wayvr
        bs-manager
      ];

      # WiVRn manages OpenXR and OpenVR runtimes

      systemd.user.tmpfiles.rules = [
        "L /home/lemon/Pictures/VRChat - - - - /home/lemon/.steam/steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat"
      ];

      xdg = {
        dataFile = {
          "Steam/compatibilitytools.d/proton-ge-rtsp" = {
            source = "${pkgs.lemonake.proton-ge-rtsp.steamcompattool}";
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

