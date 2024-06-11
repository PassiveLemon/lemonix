{ inputs, pkgs, config, lib, ... }: {
  lemonix = {
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
    };
    swap = {
      enable = true;
      partition = "/dev/nvme0n1p3";
    };
    system.hibernation.enable = true;
  };
}
