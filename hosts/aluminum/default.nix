{ inputs, pkgs, config, lib, ... }: {
  lemonix = {
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
    };
    swap = {
      enable = true;
      device = "/dev/nvme0n1p3";
    };
    system.hibernation.enable = true;
  };
}
