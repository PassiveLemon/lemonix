{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    system = {
      server.enable = true;
      specs = {
        cpu = 12;
        gpu = "nvidia";
        memory = 32;
      };
    };
  
    agenix.enable = true;
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
    };
    ssh.enable = true;
    swap = {
      enable = true;
      size = 16;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
  };
}

