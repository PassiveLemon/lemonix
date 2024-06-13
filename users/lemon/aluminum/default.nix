{ inputs, pkgs, config, lib, ... }: {
  lemonix = {
    picom.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
      streaming.enable = true;
    };
  };
}
