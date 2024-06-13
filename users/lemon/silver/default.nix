{ inputs, pkgs, config, lib, ... }: {
  lemonix = {
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
    };
    picom = {
      enable = true;
      shadows.enable = true;
      animations.enable = true;
    };
    printing.enable = true;
  };
}
