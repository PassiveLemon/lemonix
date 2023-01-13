{ config, pkgs, ... }:

{
  # Systems. Uncomment the one to use. Only one at a time for ideal results.
  imports = [
    ./hosts/lemon-tree
#    ./hosts/lime-tree
#    ./hosts/server
  ];
}
