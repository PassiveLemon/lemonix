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
    inputs.lemonake.homeModules.steamvr
    inputs.steam-config.homeModules.default
  ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      home.packages = with pkgs; [
        r2modman nexusmods-app
        heroic (bottles.override { removeWarningPopup = true; })
        lunar-client
        inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
        ludusavi
      ];

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
      };
    })
    (mkIf cfg.vr.enable {
      home.packages = with pkgs; [
        bs-manager
      ];

      programs = {
        # Lemonake
        steamvr = {
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
        # Steam-config
        steam.config = {
          enable = true;
          closeSteam = true;
          apps = with lib; let
            # Generate a defaut attrset with typical VR game settings and override as needed
            vrApps = [ "620980" "629730""1592190" "823500" "863960" "450540" "617830" "801550" "843390" "1318090" ];
            vrAppDefaults = genAttrs vrApps (id: {
              compatTool = "Proton 9.0-4";
              launchOptions = "vr-helper %command%";
            });
          in recursiveUpdate vrAppDefaults {
            "963930" = {
              compatTool = "Proton 8.0-5";
              launchOptions = "vr-helper %command%";
            };
            "438100" = {
              compatTool = "GE-Proton-rtsp"; # Lemonake
              launchOptions = "PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%";
            };
          };
        };
      };

      xdg = {
        configFile = let
          yaml = pkgs.formats.yaml { };
        in {
          "wlxoverlay/wayvr.conf.d/wayvr.yaml".source = yaml.generate "wayvr.yaml" {
            dashboard = {
              exec = (lib.getExe inputs.lemonake.packages.${pkgs.system}.wayvr-dashboard-git);
              env = [
                "WEBKIT_DISABLE_DMABUF_RENDERER=1"
                "WEBKIT_DISABLE_COMPOSITING_MODE=1"
              ];
            };
          };
          "openxr/1/active_runtime.json".force = true;
          "openvr/openvrpaths.vrpath".force = true;
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

