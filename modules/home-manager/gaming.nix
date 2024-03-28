{ inputs, pkgs, config, lib, ... }:
let
  wivrn = pkgs.callPackage ../../pkgs/wivrn { };
in
{
  imports = [
    inputs.lemonake.homeManagerModules.steamvr
  ];

  home.packages = with pkgs; [
    protonup-ng
    gamemode dxvk
    inputs.nix-gaming.packages.${pkgs.system}.viper
    r2modman
    lunar-client prismlauncher
    inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon
    #(callPackage ../../pkgs/gdlauncher-dw { })
    bottles #vinegar wineWowPackages.stagingFull
    ludusavi
  ];

  services = {
    steamvr = {
      runtimeOverride = {
        enable = true;
        path = "${inputs.nixpkgs-xr.packages.${pkgs.system}.opencomposite}/lib/opencomposite";
      };
      activeRuntimeOverride = {
        enable = true;
        path = "${wivrn}/share/openxr/1/openxr_wivrn.json";
      };
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
