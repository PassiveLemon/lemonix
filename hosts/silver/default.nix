{ ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    system = {
      server.enable = true;
    };
    agenix.enable = true;
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
    };
    ssh = {
      enable = true;
      openFirewall = true;
    };
    swap = {
      enable = true;
      size = 16;
      zram = {
        enable = true;
        memoryPercent = 25;
      };
    };
    syncthing.enable = true;
    tailscale.enable = true;
  };
}

