{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kora-icon-theme nordic
  ];

  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
}