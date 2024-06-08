{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./system.nix
    ../../modules/nixos/lanzaboote.nix
    ../../modules/nixos/swap.nix

    ./user.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/gaming/desktop.nix
  ];
}
