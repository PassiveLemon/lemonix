{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    master.r2modman
    lunar-client prismlauncher (callPackage ../../pkgs/gdlauncher-carbon-appimg { })
    (master.vinegar.override { wine = pkgs.wineWowPackages.staging.overrideDerivation (oldAttrs: { patches = (oldAttrs.patches) ++ [(pkgs.fetchpatch { url = "https://raw.githubusercontent.com/flathub/io.github.vinegarhq.Vinegar/4f2d744c80477e54426299aa171c1f0ea8282d27/patches/wine/segregrevert.patch"; hash = "sha256-GTOBKnvk3JUuoykvQlOYDLt/ohCeqJfugnQnn7ay5+w="; }) ]; }); })
    yuzu-mainline
    bottles lutris
    wineWowPackages.stagingFull gamemode protonup-ng dxvk
    ludusavi
  ];
}
