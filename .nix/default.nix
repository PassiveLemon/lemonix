{ config, pkgs, ... }: {
  # Host selection is manual until I set up flakes.
  imports = [ ./hosts/lemon-tree ];
}