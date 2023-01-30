{ config, lib, nixpkgs, ... }: {
  imports = [
    ./system.nix
    ./lemon.nix
  ];

  swapDevices = [
    { device = "/dev/disk/by-uuid/c99f7496-c915-4dc4-89e5-a6690a3d93f1"; }
  ];

  # Hard Drives
  fileSystems."/home/lemon/HDD2TBEXT4" = {
    device = "/dev/disk/by-uuid/c532ca53-130a-46c6-9e06-3aee4fd8b6e2";
    fsType = "ext4";
  };

  fileSystems."/home/lemon/HDD1TBEXT4" = {
    device = "/dev/disk/by-uuid/76946991-d872-4936-82f2-298225ea010b";
    fsType = "ext4";
  };

  system.stateVersion = "22.11";
}
