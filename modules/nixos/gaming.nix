{ inputs, system, config, lib, ... }:
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
    inputs.lemonake.nixosModules.wivrn
    inputs.lemonake.nixosModules.autoadb
  ];

  # Importing my own WiVRn module so we disable the offical to avoid conflicts
  disabledModules = [ "services/video/wivrn.nix" ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable { })
    (mkIf cfg.vr.enable {
      services = {
        autoadb = {
          enable = true;
          command = ''
            adb reverse tcp:9757 tcp:9757
            adb shell monkey -p org.meumeu.wivrn.github 1
          '';
        };
        wivrn = {
          enable = true;
          package = inputs.lemonake.packages.${system}.wivrn.override { cudaSupport = true; };
          openFirewall = false;
          defaultRuntime = true;
          autoStart = true;
          highPriority = true;
          monadoEnvironment = {
            XRT_LOG = "warning";
            XRT_COMPOSITOR_LOG = "warning";
            XRT_PRINT_OPTIONS = "off";
            PROBER_LOG = "warning";
            IPC_EXIT_WHEN_IDLE = "on";
            IPC_EXIT_WHEN_IDLE_DELAY_MS = "900000"; # 15 minutes
          };
          steam.importOXRRuntimes = true;
          config = {
            enable = true;
            json = {
              application = inputs.lemonake.packages.${system}.wayvr;
              bitrate = 100000000;
              encoders = [{
                encoder = "nvenc";
                codec = "h264";
                width = 1.0;
                height = 1.0;
                offset_x = 0;
                offset_y = 0;
              }];
              tcp_only = true;
            };
          };
        };
      };
    })
    (mkIf cfg.streaming.enable {
      services.sunshine = {
        enable = true;
        autoStart = false; # We can start it from ssh
        capSysAdmin = true;
        openFirewall = true;
      };
    })
  ]);
}

