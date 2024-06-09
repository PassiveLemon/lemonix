{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.printing;
in
{
  options = {
    lemonix.printing = {
      enable = mkEnableOption "3D printing utilities";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prusa-slicer #super-slicer
      freecad openscad
    ];

    xdg.mimeApps.defaultApplications = {
      "text/x-gcode" = "userapp-prusa-slicer-GEUUG2.desktop";
    };
  };
}
