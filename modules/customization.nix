{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    lxappearance matcha-gtk-theme kora-icon-theme papirus-icon-theme
  ];

  fonts = {
    fonts = with pkgs; [
      material-design-icons fira (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      allowBitmaps = true;
      hinting = {
        enable = true;
        autohint = true;
        style = "hintfull";
      };
      subpixel.lcdfilter = "default";
    };
  };
}