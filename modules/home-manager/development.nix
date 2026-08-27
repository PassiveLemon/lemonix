{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.development;
in
{
  options = {
    lemonix.development = {
      enable = mkEnableOption "development modules";
      circuits.enable = mkEnableOption "circuit analysis utilities";
      printing.enable = mkEnableOption "printing utilities";
      modeling.enable = mkEnableOption "modeling utilities";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.circuits.enable {
      home.packages = with pkgs; [
        ltspice
        qucs-s xyce # Try out
        ngspice # Integrates with kicad?
        # scilab-bin
        # Kicad packaging is kind of a mess so it's going to stay disabled until I need it
        # (kicad-small.override { stable = true; })
      ];

      xdg = {
        mimeApps.defaultApplications = {
          "application/asc" = "ltspice.desktop";
        };
        desktopEntries = {
          "scilab-cli" = {
            name = "Scilab CLI";
            noDisplay = true;
          };
          "scilab-adv-cli" = {
            name = "Scilab advanced CLI";
            noDisplay = true;
          };
          "scinotes" = {
            name = "Scinotes";
            noDisplay = true;
          };
          "xcos" = {
            name = "Xcos";
            noDisplay = true;
          };
        };
      };
    })
    (mkIf cfg.printing.enable {
      home.packages = with pkgs; [
        freecad
        prusa-slicer
      ];

      xdg = {
        mimeApps.defaultApplications = {
          "text/x-gcode" = "PrusaGcodeviewer.desktop";
        };
        desktopEntries = {
          "PrusaGcodeviewer" = {
            name = "Prusa GCode viewer";
            noDisplay = true;
          };
        };
      };
    })
    (mkIf cfg.modeling.enable {
      home.packages = with pkgs; [
        blender
        unityhub
        lemonake.alcom-tag
      ];

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/unityhub" = "unityhub.desktop";
      };
    })
  ]);
}

