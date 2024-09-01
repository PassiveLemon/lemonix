{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.modeling;
in
{
  options = {
    lemonix.modeling = {
      enable = mkEnableOption "modeling modules";
      design.enable = mkEnableOption "design utilities";
      printing.enable = mkEnableOption "printing utilities";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.design.enable {
      home.packages = with pkgs; [
        # Freecad has a build failure
        master.freecad openscad blender #kicad
      ];

      xdg.mimeApps.defaultApplications = {
        "text/x-gcode" = "userapp-prusa-slicer-GEUUG2.desktop";
      };
    })
    (mkIf cfg.printing.enable {
      home.packages = with pkgs; [
        prusa-slicer #super-slicer
      ];
    })
  ]);
}

