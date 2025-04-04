{ ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    system = {
      server.enable = true;
      headless.enable = true;
    };
    agenix.enable = true;
    ssh = {
      enable = true;
      openFirewall = true;
    };
    swap = {
      enable = false;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
  };
}

