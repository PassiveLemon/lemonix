{ config, lib, nixpkgs, ... }: {
  imports = [
    ./system.nix
    ./user.nix
  ];

# Set to 4 gigs
#  swapDevices = [
#    { device = "/dev/disk/by-uuid/########"; }
#  ];

  system.stateVersion = "22.11";
}
