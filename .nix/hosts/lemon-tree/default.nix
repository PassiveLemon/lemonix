{ config, lib, nixpkgs, ... }: {
  imports = [
    ./system.nix
    ./lemon.nix
  ];

  # Hard Drive
  fileSystems."/home/lemon/HDD2TB" = {
    device = "/dev/disk/by-uuid/F05212295211F4D6";
    fsType = "ntfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/c99f7496-c915-4dc4-89e5-a6690a3d93f1"; }
  ];

  system.stateVersion = "22.11";
}