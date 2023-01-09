{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    fira (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "Iosevka" ]; })
  ];
}
