{ config, lib, nixpkgs, ... }: {
  imports = [
    ./system.nix
    ./user.nix
  ];

  # 4 Gb
#  swapDevices = [
#    { device = "/dev/disk/by-uuid/########"; }
#  ];

  system.stateVersion = "22.11";
}
