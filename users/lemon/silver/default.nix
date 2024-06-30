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
    modeling = {
      enable = true;
      design.enable = true;
      printing.enable = true;
    };
  };
}
