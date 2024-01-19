{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    r2modman
    lunar-client prismlauncher (callPackage ../../pkgs/gdlauncher-carbon-appimg { }) (callPackage ../../pkgs/gdlauncher { })
    vinegar
    yuzu-mainline
    bottles lutris
    wineWowPackages.stagingFull gamemode protonup-ng dxvk
    ludusavi
    #sidequest
  ];
  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
      };
    };
  };
}
