{ inputs, config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.gaming;
in
{
  options = {
    lemonix.gaming = {
      enable = mkEnableOption "desktop gaming";

      vr = {
        enable = mkEnableOption "vr gaming";
      };
    };
  };

  imports = [
    ./wivrn.nix
  ];

  config = mkMerge [
    (mkIf cfg.enable {
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
  ];
}
