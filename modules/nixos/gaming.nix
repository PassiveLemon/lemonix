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
            adb shell am start -a android.intent.action.VIEW -d "wivrn+tcp://localhost" org.meumeu.wivrn.github
          '';
        };
        wivrn = let
          # Overriden until I somehow fix the cudaSupport stuff
          wivrnPackage = inputs.lemonake.packages.${pkgs.system}.wivrn.override { cudaSupport = true; };
        in {
          enable = true;
          package = wivrnPackage;
          openFirewall = false;
          defaultRuntime = true;
          autoStart = true;
          monadoEnvironment = {
            XRT_LOG = "warning";
            XRT_COMPOSITOR_LOG = "warning";
            XRT_PRINT_OPTIONS = "off";
            PROBER_LOG = "warning";
          };
          extraPackages = [
            # Commented out until they fix the build
            # pkgs.linuxKernel.packages.linux_zen.nvidia_x11
            (config.boot.kernelPackages.nvidiaPackages.mkDriver {
              version = "555.58.02";
              sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
              sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
              openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
              settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
              persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
            })
            pkgs.procps
            pkgs.bash
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
            };
          };
        };
      };

      hardware.opengl.extraPackages = [
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

