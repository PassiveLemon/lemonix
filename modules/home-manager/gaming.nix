{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    wineWowPackages.stagingFull gamemode dxvk
    r2modman
    lunar-client prismlauncher
    inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
    #vinegar
    bottles
    ludusavi
  ];
  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/beatsaver" = "BeatSaberModManager-url-beatsaver.desktop";
        "x-scheme-handler/bsplaylist" = "BeatSaberModManager-url-bsplaylist.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/modelsaber" = "BeatSaberModManager-url-modelsaber.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
      };
    };
  };
}
