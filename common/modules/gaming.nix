{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    lunar-client prismlauncher (callPackage ../../pkgs/gdlauncher { })
    (callPackage ../../pkgs/vinegar { })
    xonotic runelite
    yuzu-mainline
    bottles lutris
    master.wineWowPackages.stagingFull gamemode protonup-ng dxvk
    ludusavi
  ];
  #services.archisteamfarm = {
  #  enable = true;
  #  web-ui.enable = true;
  #};
}
