{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    agenix.enable = true;
    lanzaboote.enable = true;
    bluetooth.enable = true;
    ssh.enable = true;
    swap = {
      enable = true;
      size = 16;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
      streaming.enable = true;
    };
  };
}
