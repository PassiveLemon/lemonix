{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    agenix.enable = true;
    ssh.enable = true;
    system.headless = true;
    swap = {
      enable = false;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
  };
}
