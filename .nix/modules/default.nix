{ config, pkgs, ... }:

{
  # Systems. Uncomment the one to use. Only one at a time for ideal results.
  imports = [
    ./lemon-tree
#    ./lime-tree
#    ./server
  ];
}
