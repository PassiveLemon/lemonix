{ inputs, ... }: {
  imports = [
    # Doesn't currently have a GPU but one may be added in the future for transcoding and whatnot
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./modules/docker.nix
    ./modules/borg.nix
    ./modules/serve.nix
  ];

  lemonix = {
    system = {
      headless.enable = true;
    };
    agenix.enable = true;
    lanzaboote.enable = false;
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

