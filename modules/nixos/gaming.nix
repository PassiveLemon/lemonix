{ inputs, config, pkgs, lib, ... }:
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
    inputs.lemonake.nixosModules.autoadb
    ./wivrn.nix
  ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    })
    (mkIf cfg.vr.enable {
      services = {
        autoadb = {
          enable = true;
          command = "adb reverse tcp:9757 tcp:9757 && adb shell am start -a android.intent.action.VIEW -d 'wivrn://localhost' org.meumeu.wivrn";
        };
        wivrn = {
          enable = true;
          package = pkgs.callPackage ../../pkgs/wivrn-personal { };
          openFirewall = false;
          highPriority = false;
          defaultRuntime = true;
          monadoEnvironment = {
            XRT_LOG = "warning";
            XRT_COMPOSITOR_LOG = "warning";
            XRT_PRINT_OPTIONS = "off";
            PROBER_LOG = "warning";
          };
          config = {
            enable = true;
            json = {
              scale = 0.8;
              bitrate = 100000000;
              encoders = [
                {
                  encoder = "nvenc";
                  codec = "h264";
                  width = 0.5;
                  height = 1.0;
                  offset_x = 0.0;
                  offset_y = 0.0;
                  group = 0;
                }
                {
                  encoder = "nvenc";
                  codec = "h264";
                  width = 0.5;
                  height = 1.0;
                  offset_x = 0.5;
                  offset_y = 0.0;
                  group = 0;
                }
              ];
              application = pkgs.master.wlx-overlay-s;
              tcp_only = true;
            };
          };
        };
      };

      programs.alvr = {
        enable = true;
        package = pkgs.callPackage ../../pkgs/alvr { };
      };

      hardware.opengl.extraPackages = with pkgs; [
        inputs.lemonake.packages.${pkgs.system}.monado-vulkan-layers
      ];
    })
    (mkIf cfg.streaming.enable {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    })
  ]);
}
