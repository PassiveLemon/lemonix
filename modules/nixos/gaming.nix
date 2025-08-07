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

  imports = [
    inputs.lemonake.nixosModules.wivrn
    inputs.lemonake.nixosModules.autoadb
  ];

  # Importing my own WiVRn module so we disable the offical to avoid conflicts
  disabledModules = [ "services/video/wivrn.nix" ];

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.desktop.enable {
      # environment.systemPackages = with pkgs; [
      #   master.lsfg-vk master.lsfg-vk-ui
      # ];

      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
          inputs.lemonake.packages.${pkgs.system}.proton-ge-rtsp
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
          wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn.override {
            cudaSupport = true;
            opencomposite = "${inputs.lemonake.packages.${pkgs.system}.opencomposite-git}";
          };
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
            IPC_EXIT_WHEN_IDLE = "on";
            IPC_EXIT_WHEN_IDLE_DELAY_MS = "900000"; # 15 minutes
          };
          extraServerFlags = [ "--no-publish-service" ];
          extraPackages = with pkgs; [
            systemd # systemctl
            bash # for the below
            (config.hardware.nvidia.package) # nvidia-smi
            procps # top
            gawk # awk
          ];
          config = {
            enable = true;
            json = {
              application = inputs.lemonake.packages.${pkgs.system}.wlx-overlay-s-git;
              bitrate = 100000000;
              tcp_only = true;
            };
          };
        };
      };

      # Wlx-overlay-s config has some stuff that needs it
      systemd.user.services.wivrn.serviceConfig.ProtectProc = lib.mkForce "default";

      hardware.graphics.extraPackages = [
        inputs.lemonake.packages.${pkgs.system}.monado-vulkan-layers-git
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

