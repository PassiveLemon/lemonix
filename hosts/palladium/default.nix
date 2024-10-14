{ ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    system = {
      server.enable = true;
      headless.enable = true;
      specs = {
        cpu = 4;
        gpu = "none";
        memory = 4;
      };
    };
    agenix.enable = true;
    ssh.enable = true;
    swap = {
      enable = false;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
  };
}

