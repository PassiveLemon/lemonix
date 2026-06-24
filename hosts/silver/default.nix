{ inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    agenix.enable = true;
    lanzaboote.enable = false;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
      vr.enable = true;
      streaming.enable = true;
    };
    ssh = {
      enable = true;
      openFirewall = true;
    };
    swap = {
      enable = true;
      size = 32;
      zswap = {
        enable = true;
        memoryPercent = 25;
      };
    };
    syncthing.enable = true;
    tailscale.enable = true;
  };
}

