{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    steam
    lunar-client prismlauncher (callPackage ../../pkgs/gdlauncher { })
    (callPackage ../../pkgs/vinegar { wine = inputs.nix-gaming.packages.${pkgs.system}.wine-ge; })
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
