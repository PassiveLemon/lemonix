{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    master.r2modman
    lunar-client prismlauncher (callPackage ../../pkgs/gdlauncher-carbon-appimg { })
    (callPackage ../../pkgs/vinegar { })
    yuzu-mainline
    bottles lutris
    master.wineWowPackages.stagingFull gamemode protonup-ng dxvk
    ludusavi
  ];
}
