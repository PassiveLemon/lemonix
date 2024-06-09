{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../../modules/nixos/lanzaboote.nix
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
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
      vr.enable = true;
    };
  };
}
