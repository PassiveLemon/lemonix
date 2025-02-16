{ inputs, config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
  wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn.override {
    cudaSupport = true;
    opencomposite = "${openCompPackage}";
  };
  openCompPackage = inputs.lemonake.packages.${pkgs.system}.opencomposite-git;
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
        nexusmods-app
        (callPackage ../../pkgs/bs-manager.nix { })
        xrgears
      ];

      programs.steamvr = {
        enable = true;
        openvrRuntimeOverride = {
          enable = true;
          config = "path";
          path = "${openCompPackage}/lib/opencomposite";
          # path = "${inputs.lemonake.packages.${pkgs.system}.xrizer}/lib/xrizer";
        };
        openxrRuntimeOverride = {
          enable = true;
          config = "path";
          path = "${wivrnPackage}/share/openxr/1/openxr_wivrn.json";
        };
        helperScript = {
          enable = true;
          openvrRuntime = "opencomposite";
          openvrRuntimePackage = openCompPackage;
          # openvrRuntime = "xrizer";
          # openvrRuntimePackage = inputs.lemonake.packages.${pkgs.system}.xrizer;
          openxrRuntime = "wivrn";
          openxrRuntimePackage = wivrnPackage;
        };
      };

      xdg = {
        configFile = {
          "wlxoverlay/conf.d/wayvr.yaml" = {
            text = ''
              dashboard:
                exec: "${inputs.lemonake.packages.${pkgs.system}.wayvr-dashboard-git}/bin/wayvr_dashboard"
                args: ""
                env: [ "GDK_BACKEND=wayland", "WEBKIT_DISABLE_DMABUF_RENDERER=1" ]
            '';
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

