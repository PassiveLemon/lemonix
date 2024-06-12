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
        udev.packages = with pkgs; [
          android-udev-rules
        ];
        wivrn = {
          enable = true;
          package = pkgs.callPackage ../../pkgs/wivrn { };
          openFirewall = true;
          highPriority = true;
          defaultRuntime = true;
          monadoEnvironment = {
            XRT_COMPOSITOR_COMPUTE = "1";
            XRT_COMPOSITOR_LOG = "debug";
            XRT_LOG = "debug";
          };
        };
      };

      programs = {
        adb.enable = true;
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
