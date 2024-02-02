{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    wineWowPackages.stagingFull gamemode protonup-ng dxvk
    steam
    r2modman
    lunar-client prismlauncher
    inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
    #vinegar
    bottles
    ludusavi
    sidequest
  ];
  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/sidequest" = "SideQuest.desktop";
      };
    };
  };
}
