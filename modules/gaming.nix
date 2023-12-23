{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    r2modman
    lunar-client prismlauncher (callPackage ../pkgs/gdlauncher-carbon-appimg { })
    vinegar
    yuzu-mainline
    bottles lutris
    wineWowPackages.stagingFull gamemode protonup-ng dxvk
    ludusavi
    #sidequest
  ];
}
