{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    freecad openscad
    prusa-slicer
  ];
  xdg = {
    mimeApps = {
      defaultApplications = {
        "text/x-gcode" = "userapp-prusa-slicer-GEUUG2.desktop";
      };
    };
  };
}
