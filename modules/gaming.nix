{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gamemode protonup-ng dxvk
    bottles lutris ludusavi
    lunar-client
    yuzu-mainline
  ];
  programs = {
    steam = {
      enable = true;
    };
  };
  #services.archisteamfarm = {
  #  enable = true;
  #  web-ui.enable = true;
  #};
}
