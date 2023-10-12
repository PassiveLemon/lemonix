{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    lunar-client prismlauncher
    xonotic runelite
    yuzu-mainline
    bottles lutris
    pkgs.master.wineWowPackages.staging winetricks gamemode protonup-ng dxvk
    ludusavi
  ];
  #services.archisteamfarm = {
  #  enable = true;
  #  web-ui.enable = true;
  #};
}
