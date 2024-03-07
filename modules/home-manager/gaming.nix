{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./steamvr.nix
  ];

  home.packages = with pkgs; [
    gamemode dxvk
    inputs.nix-gaming.packages.${pkgs.system}.viper
    r2modman
    lunar-client prismlauncher inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
    bottles #vinegar wineWowPackages.stagingFull
    ludusavi
  ];
  services = {
    steamvr.runtimeOverride = {
      enable = true;
      package = pkgs.opencomposite;
      packageSubPath = "/lib/opencomposite";
    };
  };
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
