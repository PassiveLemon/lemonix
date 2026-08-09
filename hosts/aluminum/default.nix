{ inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  lemonix = {
    system = {
      mobile.enable = true;
      hibernation.enable = true;
    };
    agenix.enable = true;
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
    };
    ssh = {
      enable = true;
      openFirewall = false;
    };
    swap = {
      enable = true;
      device = "/dev/nvme0n1p6";
      zswap = {
        enable = true;
        memoryPercent = 25;
      };
    };
    syncthing.enable = true;
    tailscale.enable = true;
  };
}

