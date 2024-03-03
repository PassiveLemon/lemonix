{ inputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    prusa-slicer #super-slicer
    freecad openscad
  ];
  xdg = {
    mimeApps = {
      defaultApplications = {
        "text/x-gcode" = "userapp-prusa-slicer-GEUUG2.desktop";
      };
    };
  };
}
