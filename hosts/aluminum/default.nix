{ inputs, pkgs, config, lib, ... }: {
  lemonix = {
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      vr.enable = true;
    };
  };
}
