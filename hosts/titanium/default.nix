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
    lanzaboote.enable = true;
    ssh = {
      enable = true;
      openFirewall = true;
    };
    swap = {
      enable = true;
      size = 32;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
    syncthing.enable = true;
    tailscale.enable = true;
  };
}

