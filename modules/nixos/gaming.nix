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

  disabledModules = [ "services/video/wivrn.nix" ];

  imports = [
    inputs.lemonake.nixosModules.wivrn
    inputs.lemonake.nixosModules.autoadb
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
          command = ''
            adb reverse tcp:9757 tcp:9757
            adb shell monkey -p org.meumeu.wivrn.github 1
          '';
        };
        wivrn = let
          # Overriden until I somehow fix the cudaSupport stuff
          wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn.override { cudaSupport = true; };
          # wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn;
        in {
          enable = true;
          package = wivrnPackage;
          openFirewall = false;
          defaultRuntime = true;
          autoStart = true;
          highPriority = true;
          monadoEnvironment = {
            XRT_LOG = "warning";
            XRT_COMPOSITOR_LOG = "warning";
            XRT_PRINT_OPTIONS = "off";
            PROBER_LOG = "warning";
          };
          extraServerFlags = [ "--no-publish-service" ];
          extraPackages = with pkgs; [
            pkgs.linuxKernel.packages.linux_zen.nvidia_x11
            systemd
            bash
            procps
            gawk
          ];
          config = {
            enable = true;
            json = {
              bitrate = 100000000;
              encoders = [
                {
                  encoder = "nvenc";
                  codec = "h264";
                  width = 0.5;
                  height = 0.25;
                  offset_x = 0;
                  offset_y = 0;
                  group = 0;
                }
                {
                  encoder = "nvenc";
                  codec = "h264";
                  width = 0.5;
                  height = 0.75;
                  offset_x = 0;
                  offset_y = 0.25;
                  group = 0;
                }
                {
                  encoder = "nvenc";
                  codec = "h264";
                  width = 0.5;
                  height = 1;
                  offset_x = 0.5;
                  offset_y = 0;
                  group = 0;
                }
              ];
              application = inputs.nixpkgs-xr.packages.${pkgs.system}.wlx-overlay-s;
              tcp_only = true;
            };
          };
        };
      };

      # Wlx-overlay-s config has some stuff that needs it
      # systemd.user.services.wivrn.serviceConfig.ProtectProc = lib.mkForce "default";

      hardware.graphics.extraPackages = with pkgs; [
        inputs.lemonake.packages.${pkgs.system}.monado-vulkan-layers-git
        vulkan-validation-layers
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

