{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    steam lunar-client yuzu-mainline
    bottles lutris
    wineWowPackages.staging winetricks gamemode protonup-ng dxvk
    ludusavi
  ];
  #services.archisteamfarm = {
  #  enable = true;
  #  web-ui.enable = true;
  #};
}
