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

  system.stateVersion = "22.11";
}