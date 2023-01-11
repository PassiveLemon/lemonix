{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    material-design-icons fira (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" ]; })
  ];
}