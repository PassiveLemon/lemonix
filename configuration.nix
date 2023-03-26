{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    # Host selection is manual until I set up flakes.
    /home/lemon/Documents/GitHub/lemonix/.nix/hosts/lemon
  ];
}