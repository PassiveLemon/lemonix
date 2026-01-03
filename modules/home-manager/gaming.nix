{ inputs, config, lib, pkgs, ... }:
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
        r2modman limo
        steam heroic (bottles.override { removeWarningPopup = true; })
        inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
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
        bs-manager
      ];

      # WiVRn manages OpenXR and OpenVR runtimes

      xdg = {
        # https://github.com/olekolek1000/wayvr-dashboard/issues/7
        # configFile = let
        #   yaml = pkgs.formats.yaml { };
        # in {
        #   "wlxoverlay/wayvr.conf.d/wayvr.yaml".source = yaml.generate "wayvr.yaml" {
        #     dashboard = {
        #       exec = (lib.getExe inputs.lemonake.packages.${pkgs.system}.wayvr-dashboard-git);
        #       env = [
        #         "WEBKIT_DISABLE_DMABUF_RENDERER=1"
        #         "WEBKIT_DISABLE_COMPOSITING_MODE=1"
        #       ];
        #     };
        #   };
        # };
        dataFile = {
          "Steam/compatibilitytools.d/proton-ge-rtsp" = {
            source = "${inputs.lemonake.packages.${pkgs.system}.proton-ge-rtsp.steamcompattool}";
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

